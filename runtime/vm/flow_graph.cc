// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "vm/flow_graph.h"

#include "vm/bit_vector.h"
#include "vm/flow_graph_builder.h"
#include "vm/intermediate_language.h"
#include "vm/longjump.h"
#include "vm/growable_array.h"

namespace dart {

DECLARE_FLAG(bool, trace_optimization);
DECLARE_FLAG(bool, verify_compiler);

FlowGraph::FlowGraph(const FlowGraphBuilder& builder,
                     GraphEntryInstr* graph_entry,
                     intptr_t max_block_id)
  : parent_(),
    current_ssa_temp_index_(0),
    max_block_id_(max_block_id),
    parsed_function_(builder.parsed_function()),
    num_copied_params_(builder.num_copied_params()),
    num_non_copied_params_(builder.num_non_copied_params()),
    num_stack_locals_(builder.num_stack_locals()),
    graph_entry_(graph_entry),
    preorder_(),
    postorder_(),
    reverse_postorder_(),
    block_effects_(NULL),
    licm_allowed_(true) {
  DiscoverBlocks();
}


ConstantInstr* FlowGraph::GetConstant(const Object& object) {
  // Check if the constant is already in the pool.
  GrowableArray<Definition*>* pool = graph_entry_->initial_definitions();
  for (intptr_t i = 0; i < pool->length(); ++i) {
    ConstantInstr* constant = (*pool)[i]->AsConstant();
    if ((constant != NULL) && (constant->value().raw() == object.raw())) {
      return constant;
    }
  }
  // Otherwise, allocate and add it to the pool.
  ConstantInstr* constant = new ConstantInstr(object);
  constant->set_ssa_temp_index(alloc_ssa_temp_index());
  AddToInitialDefinitions(constant);
  return constant;
}


void FlowGraph::AddToInitialDefinitions(Definition* defn) {
  // TODO(zerny): Set previous to the graph entry so it is accessible by
  // GetBlock. Remove this once there is a direct pointer to the block.
  defn->set_previous(graph_entry_);
  graph_entry_->initial_definitions()->Add(defn);
}


void FlowGraph::InsertBefore(Instruction* next,
                             Instruction* instr,
                             Environment* env,
                             Definition::UseKind use_kind) {
  InsertAfter(next->previous(), instr, env, use_kind);
}


void FlowGraph::InsertAfter(Instruction* prev,
                            Instruction* instr,
                            Environment* env,
                            Definition::UseKind use_kind) {
  if (use_kind == Definition::kValue) {
    ASSERT(instr->IsDefinition());
    instr->AsDefinition()->set_ssa_temp_index(alloc_ssa_temp_index());
  }
  instr->InsertAfter(prev);
  ASSERT(instr->env() == NULL);
  if (env != NULL) env->DeepCopyTo(instr);
}


void FlowGraph::DiscoverBlocks() {
  // Initialize state.
  preorder_.Clear();
  postorder_.Clear();
  reverse_postorder_.Clear();
  parent_.Clear();
  // Perform a depth-first traversal of the graph to build preorder and
  // postorder block orders.
  graph_entry_->DiscoverBlocks(NULL,  // Entry block predecessor.
                               &preorder_,
                               &postorder_,
                               &parent_,
                               variable_count(),
                               num_non_copied_params());
  // Create an array of blocks in reverse postorder.
  intptr_t block_count = postorder_.length();
  for (intptr_t i = 0; i < block_count; ++i) {
    reverse_postorder_.Add(postorder_[block_count - i - 1]);
  }

  // Block effects are using postorder numbering. Discard computed information.
  block_effects_ = NULL;
}


#ifdef DEBUG
// Debugging code to verify the construction of use lists.

static intptr_t MembershipCount(Value* use, Value* list) {
  intptr_t count = 0;
  while (list != NULL) {
    if (list == use) ++count;
    list = list->next_use();
  }
  return count;
}


static void VerifyUseListsInInstruction(Instruction* instr) {
  ASSERT(instr != NULL);
  ASSERT(!instr->IsJoinEntry());
  for (intptr_t i = 0; i < instr->InputCount(); ++i) {
    Value* use = instr->InputAt(i);
    ASSERT(use->definition() != NULL);
    ASSERT((use->definition() != instr) || use->definition()->IsPhi());
    ASSERT(use->instruction() == instr);
    ASSERT(use->use_index() == i);
    ASSERT(!FLAG_verify_compiler ||
           (1 == MembershipCount(use, use->definition()->input_use_list())));
  }
  if (instr->env() != NULL) {
    intptr_t use_index = 0;
    for (Environment::DeepIterator it(instr->env()); !it.Done(); it.Advance()) {
      Value* use = it.CurrentValue();
      ASSERT(use->definition() != NULL);
      ASSERT((use->definition() != instr) || use->definition()->IsPhi());
      ASSERT(use->instruction() == instr);
      ASSERT(use->use_index() == use_index++);
      ASSERT(!FLAG_verify_compiler ||
             (1 == MembershipCount(use, use->definition()->env_use_list())));
    }
  }
  Definition* defn = instr->AsDefinition();
  if (defn != NULL) {
    // Used definitions must have an SSA name.  We use the name to index
    // into bit vectors during analyses.  Some definitions without SSA names
    // (e.g., PushArgument) have environment uses.
    ASSERT((defn->input_use_list() == NULL) || defn->HasSSATemp());
    Value* prev = NULL;
    Value* curr = defn->input_use_list();
    while (curr != NULL) {
      ASSERT(prev == curr->previous_use());
      ASSERT(defn == curr->definition());
      Instruction* instr = curr->instruction();
      // The instruction should not be removed from the graph.
      ASSERT((instr->IsPhi() && instr->AsPhi()->is_alive()) ||
             (instr->previous() != NULL));
      ASSERT(curr == instr->InputAt(curr->use_index()));
      prev = curr;
      curr = curr->next_use();
    }

    prev = NULL;
    curr = defn->env_use_list();
    while (curr != NULL) {
      ASSERT(prev == curr->previous_use());
      ASSERT(defn == curr->definition());
      Instruction* instr = curr->instruction();
      ASSERT(curr == instr->env()->ValueAtUseIndex(curr->use_index()));
      // BlockEntry instructions have environments attached to them but
      // have no reliable way to verify if they are still in the graph.
      // Thus we just assume they are.
      ASSERT(instr->IsBlockEntry() ||
             (instr->IsPhi() && instr->AsPhi()->is_alive()) ||
             (instr->previous() != NULL));
      prev = curr;
      curr = curr->next_use();
    }
  }
}


bool FlowGraph::VerifyUseLists() {
  // Verify the initial definitions.
  for (intptr_t i = 0; i < graph_entry_->initial_definitions()->length(); ++i) {
    VerifyUseListsInInstruction((*graph_entry_->initial_definitions())[i]);
  }

  // Verify phis in join entries and the instructions in each block.
  for (intptr_t i = 0; i < preorder_.length(); ++i) {
    BlockEntryInstr* entry = preorder_[i];
    JoinEntryInstr* join = entry->AsJoinEntry();
    if (join != NULL) {
      for (PhiIterator it(join); !it.Done(); it.Advance()) {
        PhiInstr* phi = it.Current();
        ASSERT(phi != NULL);
        VerifyUseListsInInstruction(phi);
      }
    }
    for (ForwardInstructionIterator it(entry); !it.Done(); it.Advance()) {
      VerifyUseListsInInstruction(it.Current());
    }
  }
  return true;  // Return true so we can ASSERT validation.
}
#endif  // DEBUG


LivenessAnalysis::LivenessAnalysis(
  intptr_t variable_count,
  const GrowableArray<BlockEntryInstr*>& postorder)
    : variable_count_(variable_count),
      postorder_(postorder),
      live_out_(postorder.length()),
      kill_(postorder.length()),
      live_in_(postorder.length()) {
}


bool LivenessAnalysis::UpdateLiveOut(const BlockEntryInstr& block) {
  BitVector* live_out = live_out_[block.postorder_number()];
  bool changed = false;
  Instruction* last = block.last_instruction();
  ASSERT(last != NULL);
  for (intptr_t i = 0; i < last->SuccessorCount(); i++) {
    BlockEntryInstr* succ = last->SuccessorAt(i);
    ASSERT(succ != NULL);
    if (live_out->AddAll(live_in_[succ->postorder_number()])) {
      changed = true;
    }
  }
  return changed;
}


bool LivenessAnalysis::UpdateLiveIn(const BlockEntryInstr& block) {
  BitVector* live_out = live_out_[block.postorder_number()];
  BitVector* kill = kill_[block.postorder_number()];
  BitVector* live_in = live_in_[block.postorder_number()];
  return live_in->KillAndAdd(kill, live_out);
}


void LivenessAnalysis::ComputeLiveInAndLiveOutSets() {
  const intptr_t block_count = postorder_.length();
  bool changed;
  do {
    changed = false;

    for (intptr_t i = 0; i < block_count; i++) {
      const BlockEntryInstr& block = *postorder_[i];

      // Live-in set depends only on kill set which does not
      // change in this loop and live-out set.  If live-out
      // set does not change there is no need to recompute
      // live-in set.
      if (UpdateLiveOut(block) && UpdateLiveIn(block)) {
        changed = true;
      }
    }
  } while (changed);
}


void LivenessAnalysis::Analyze() {
  const intptr_t block_count = postorder_.length();
  for (intptr_t i = 0; i < block_count; i++) {
    live_out_.Add(new BitVector(variable_count_));
    kill_.Add(new BitVector(variable_count_));
    live_in_.Add(new BitVector(variable_count_));
  }

  ComputeInitialSets();
  ComputeLiveInAndLiveOutSets();
}


static void PrintBitVector(const char* tag, BitVector* v) {
  OS::Print("%s:", tag);
  for (BitVector::Iterator it(v); !it.Done(); it.Advance()) {
    OS::Print(" %"Pd"", it.Current());
  }
  OS::Print("\n");
}


void LivenessAnalysis::Dump() {
  const intptr_t block_count = postorder_.length();
  for (intptr_t i = 0; i < block_count; i++) {
    BlockEntryInstr* block = postorder_[i];
    OS::Print("block @%"Pd" -> ", block->block_id());

    Instruction* last = block->last_instruction();
    for (intptr_t j = 0; j < last->SuccessorCount(); j++) {
      BlockEntryInstr* succ = last->SuccessorAt(j);
      OS::Print(" @%"Pd"", succ->block_id());
    }
    OS::Print("\n");

    PrintBitVector("  live out", live_out_[i]);
    PrintBitVector("  kill", kill_[i]);
    PrintBitVector("  live in", live_in_[i]);
  }
}


// Computes liveness information for local variables.
class VariableLivenessAnalysis : public LivenessAnalysis {
 public:
  explicit VariableLivenessAnalysis(FlowGraph* flow_graph)
      : LivenessAnalysis(flow_graph->variable_count(), flow_graph->postorder()),
        flow_graph_(flow_graph),
        num_non_copied_params_(flow_graph->num_non_copied_params()),
        assigned_vars_() { }

  // For every block (in preorder) compute and return set of variables that
  // have new assigned values flowing out of that block.
  const GrowableArray<BitVector*>& ComputeAssignedVars() {
    // We can't directly return kill_ because it uses postorder numbering while
    // SSA construction uses preorder numbering internally.
    // We have to permute postorder into preorder.
    assigned_vars_.Clear();

    const intptr_t block_count = flow_graph_->preorder().length();
    for (intptr_t i = 0; i < block_count; i++) {
      BlockEntryInstr* block = flow_graph_->preorder()[i];
      BitVector* kill = GetKillSet(block);
      kill->Intersect(GetLiveOutSet(block));
      assigned_vars_.Add(kill);
    }

    return assigned_vars_;
  }

  // Returns true if the value set by the given store reaches any load from the
  // same local variable.
  bool IsStoreAlive(BlockEntryInstr* block, StoreLocalInstr* store) {
    if (store->is_dead()) {
      return false;
    }

    if (store->is_last()) {
      const intptr_t index = store->local().BitIndexIn(num_non_copied_params_);
      return GetLiveOutSet(block)->Contains(index);
    }

    return true;
  }

  // Returns true if the given load is the last for the local and the value
  // of the local will not flow into another one.
  bool IsLastLoad(BlockEntryInstr* block, LoadLocalInstr* load) {
    const intptr_t index = load->local().BitIndexIn(num_non_copied_params_);
    return load->is_last() && !GetLiveOutSet(block)->Contains(index);
  }

 private:
  virtual void ComputeInitialSets();

  const FlowGraph* flow_graph_;
  const intptr_t num_non_copied_params_;
  GrowableArray<BitVector*> assigned_vars_;
};


void VariableLivenessAnalysis::ComputeInitialSets() {
  const intptr_t block_count = postorder_.length();

  BitVector* last_loads = new BitVector(variable_count_);
  for (intptr_t i = 0; i < block_count; i++) {
    BlockEntryInstr* block = postorder_[i];

    BitVector* kill = kill_[i];
    BitVector* live_in = live_in_[i];
    last_loads->Clear();

    // Iterate backwards starting at the last instruction.
    for (BackwardInstructionIterator it(block); !it.Done(); it.Advance()) {
      Instruction* current = it.Current();

      LoadLocalInstr* load = current->AsLoadLocal();
      if (load != NULL) {
        const intptr_t index = load->local().BitIndexIn(num_non_copied_params_);
        live_in->Add(index);
        if (!last_loads->Contains(index)) {
          last_loads->Add(index);
          load->mark_last();
        }
        continue;
      }

      StoreLocalInstr* store = current->AsStoreLocal();
      if (store != NULL) {
        const intptr_t index =
            store->local().BitIndexIn(num_non_copied_params_);
        if (kill->Contains(index)) {
          if (!live_in->Contains(index)) {
            store->mark_dead();
          }
        } else {
          if (!live_in->Contains(index)) {
            store->mark_last();
          }
          kill->Add(index);
        }
        live_in->Remove(index);
        continue;
      }
    }
  }
}


void FlowGraph::ComputeSSA(
    intptr_t next_virtual_register_number,
    ZoneGrowableArray<Definition*>* inlining_parameters) {
  ASSERT((next_virtual_register_number == 0) || (inlining_parameters != NULL));
  current_ssa_temp_index_ = next_virtual_register_number;
  GrowableArray<BitVector*> dominance_frontier;
  ComputeDominators(&dominance_frontier);

  VariableLivenessAnalysis variable_liveness(this);
  variable_liveness.Analyze();

  InsertPhis(preorder_,
             variable_liveness.ComputeAssignedVars(),
             dominance_frontier);

  GrowableArray<PhiInstr*> live_phis;

  // Rename uses to reference inserted phis where appropriate.
  // Collect phis that reach a non-environment use.
  Rename(&live_phis, &variable_liveness, inlining_parameters);

  // Propagate alive mark transitively from alive phis and then remove
  // non-live ones.
  RemoveDeadPhis(&live_phis);
}


// Compute immediate dominators and the dominance frontier for each basic
// block.  As a side effect of the algorithm, sets the immediate dominator
// of each basic block.
//
// dominance_frontier: an output parameter encoding the dominance frontier.
//     The array maps the preorder block number of a block to the set of
//     (preorder block numbers of) blocks in the dominance frontier.
void FlowGraph::ComputeDominators(
    GrowableArray<BitVector*>* dominance_frontier) {
  // Use the SEMI-NCA algorithm to compute dominators.  This is a two-pass
  // version of the Lengauer-Tarjan algorithm (LT is normally three passes)
  // that eliminates a pass by using nearest-common ancestor (NCA) to
  // compute immediate dominators from semidominators.  It also removes a
  // level of indirection in the link-eval forest data structure.
  //
  // The algorithm is described in Georgiadis, Tarjan, and Werneck's
  // "Finding Dominators in Practice".
  // See http://www.cs.princeton.edu/~rwerneck/dominators/ .

  // All arrays are maps between preorder basic-block numbers.
  intptr_t size = parent_.length();
  GrowableArray<intptr_t> idom(size);  // Immediate dominator.
  GrowableArray<intptr_t> semi(size);  // Semidominator.
  GrowableArray<intptr_t> label(size);  // Label for link-eval forest.

  // 1. First pass: compute semidominators as in Lengauer-Tarjan.
  // Semidominators are computed from a depth-first spanning tree and are an
  // approximation of immediate dominators.

  // Use a link-eval data structure with path compression.  Implement path
  // compression in place by mutating the parent array.  Each block has a
  // label, which is the minimum block number on the compressed path.

  // Initialize idom, semi, and label used by SEMI-NCA.  Initialize the
  // dominance frontier output array.
  for (intptr_t i = 0; i < size; ++i) {
    idom.Add(parent_[i]);
    semi.Add(i);
    label.Add(i);
    dominance_frontier->Add(new BitVector(size));
  }

  // Loop over the blocks in reverse preorder (not including the graph
  // entry).  Clear the dominated blocks in the graph entry in case
  // ComputeDominators is used to recompute them.
  preorder_[0]->ClearDominatedBlocks();
  for (intptr_t block_index = size - 1; block_index >= 1; --block_index) {
    // Loop over the predecessors.
    BlockEntryInstr* block = preorder_[block_index];
    // Clear the immediately dominated blocks in case ComputeDominators is
    // used to recompute them.
    block->ClearDominatedBlocks();
    for (intptr_t i = 0, count = block->PredecessorCount(); i < count; ++i) {
      BlockEntryInstr* pred = block->PredecessorAt(i);
      ASSERT(pred != NULL);

      // Look for the semidominator by ascending the semidominator path
      // starting from pred.
      intptr_t pred_index = pred->preorder_number();
      intptr_t best = pred_index;
      if (pred_index > block_index) {
        CompressPath(block_index, pred_index, &parent_, &label);
        best = label[pred_index];
      }

      // Update the semidominator if we've found a better one.
      semi[block_index] = Utils::Minimum(semi[block_index], semi[best]);
    }

    // Now use label for the semidominator.
    label[block_index] = semi[block_index];
  }

  // 2. Compute the immediate dominators as the nearest common ancestor of
  // spanning tree parent and semidominator, for all blocks except the entry.
  for (intptr_t block_index = 1; block_index < size; ++block_index) {
    intptr_t dom_index = idom[block_index];
    while (dom_index > semi[block_index]) {
      dom_index = idom[dom_index];
    }
    idom[block_index] = dom_index;
    preorder_[dom_index]->AddDominatedBlock(preorder_[block_index]);
  }

  // 3. Now compute the dominance frontier for all blocks.  This is
  // algorithm in "A Simple, Fast Dominance Algorithm" (Figure 5), which is
  // attributed to a paper by Ferrante et al.  There is no bookkeeping
  // required to avoid adding a block twice to the same block's dominance
  // frontier because we use a set to represent the dominance frontier.
  for (intptr_t block_index = 0; block_index < size; ++block_index) {
    BlockEntryInstr* block = preorder_[block_index];
    intptr_t count = block->PredecessorCount();
    if (count <= 1) continue;
    for (intptr_t i = 0; i < count; ++i) {
      BlockEntryInstr* runner = block->PredecessorAt(i);
      while (runner != block->dominator()) {
        (*dominance_frontier)[runner->preorder_number()]->Add(block_index);
        runner = runner->dominator();
      }
    }
  }
}


void FlowGraph::CompressPath(intptr_t start_index,
                             intptr_t current_index,
                             GrowableArray<intptr_t>* parent,
                             GrowableArray<intptr_t>* label) {
  intptr_t next_index = (*parent)[current_index];
  if (next_index > start_index) {
    CompressPath(start_index, next_index, parent, label);
    (*label)[current_index] =
        Utils::Minimum((*label)[current_index], (*label)[next_index]);
    (*parent)[current_index] = (*parent)[next_index];
  }
}


void FlowGraph::InsertPhis(
    const GrowableArray<BlockEntryInstr*>& preorder,
    const GrowableArray<BitVector*>& assigned_vars,
    const GrowableArray<BitVector*>& dom_frontier) {
  const intptr_t block_count = preorder.length();
  // Map preorder block number to the highest variable index that has a phi
  // in that block.  Use it to avoid inserting multiple phis for the same
  // variable.
  GrowableArray<intptr_t> has_already(block_count);
  // Map preorder block number to the highest variable index for which the
  // block went on the worklist.  Use it to avoid adding the same block to
  // the worklist more than once for the same variable.
  GrowableArray<intptr_t> work(block_count);

  // Initialize has_already and work.
  for (intptr_t block_index = 0; block_index < block_count; ++block_index) {
    has_already.Add(-1);
    work.Add(-1);
  }

  // Insert phis for each variable in turn.
  GrowableArray<BlockEntryInstr*> worklist;
  for (intptr_t var_index = 0; var_index < variable_count(); ++var_index) {
    // Add to the worklist each block containing an assignment.
    for (intptr_t block_index = 0; block_index < block_count; ++block_index) {
      if (assigned_vars[block_index]->Contains(var_index)) {
        work[block_index] = var_index;
        worklist.Add(preorder[block_index]);
      }
    }

    while (!worklist.is_empty()) {
      BlockEntryInstr* current = worklist.RemoveLast();
      // Ensure a phi for each block in the dominance frontier of current.
      for (BitVector::Iterator it(dom_frontier[current->preorder_number()]);
           !it.Done();
           it.Advance()) {
        int index = it.Current();
        if (has_already[index] < var_index) {
          BlockEntryInstr* block = preorder[index];
          ASSERT(block->IsJoinEntry());
          block->AsJoinEntry()->InsertPhi(var_index, variable_count());
          has_already[index] = var_index;
          if (work[index] < var_index) {
            work[index] = var_index;
            worklist.Add(block);
          }
        }
      }
    }
  }
}


void FlowGraph::Rename(GrowableArray<PhiInstr*>* live_phis,
                       VariableLivenessAnalysis* variable_liveness,
                       ZoneGrowableArray<Definition*>* inlining_parameters) {
  // TODO(fschneider): Support catch-entry.
  if (graph_entry_->SuccessorCount() > 1) {
    Bailout("Catch-entry support in SSA.");
  }

  // Initial renaming environment.
  GrowableArray<Definition*> env(variable_count());

  // Add global constants to the initial definitions.
  constant_null_ = GetConstant(Object::ZoneHandle());

  // Add parameters to the initial definitions and renaming environment.
  if (inlining_parameters != NULL) {
    // Use known parameters.
    ASSERT(parameter_count() == inlining_parameters->length());
    for (intptr_t i = 0; i < parameter_count(); ++i) {
      Definition* defn = (*inlining_parameters)[i];
      defn->set_ssa_temp_index(alloc_ssa_temp_index());  // New SSA temp.
      AddToInitialDefinitions(defn);
      env.Add(defn);
    }
  } else {
    // Create new parameters.
    for (intptr_t i = 0; i < parameter_count(); ++i) {
      ParameterInstr* param = new ParameterInstr(i, graph_entry_);
      param->set_ssa_temp_index(alloc_ssa_temp_index());  // New SSA temp.
      AddToInitialDefinitions(param);
      env.Add(param);
    }
  }

  // Initialize all locals with #null in the renaming environment.
  for (intptr_t i = parameter_count(); i < variable_count(); ++i) {
    env.Add(constant_null());
  }

  BlockEntryInstr* normal_entry = graph_entry_->SuccessorAt(0);
  ASSERT(normal_entry != NULL);  // Must have entry.
  RenameRecursive(normal_entry, &env, live_phis, variable_liveness);
}


void FlowGraph::AttachEnvironment(Instruction* instr,
                                  GrowableArray<Definition*>* env) {
  Environment* deopt_env =
      Environment::From(*env,
                        num_non_copied_params_,
                        parsed_function_.function());
  instr->SetEnvironment(deopt_env);
  for (Environment::DeepIterator it(deopt_env); !it.Done(); it.Advance()) {
    Value* use = it.CurrentValue();
    use->definition()->AddEnvUse(use);
  }
  if (instr->CanDeoptimize()) {
    instr->env()->set_deopt_id(instr->deopt_id());
  }
}


void FlowGraph::RenameRecursive(BlockEntryInstr* block_entry,
                                GrowableArray<Definition*>* env,
                                GrowableArray<PhiInstr*>* live_phis,
                                VariableLivenessAnalysis* variable_liveness) {
  // 1. Process phis first.
  if (block_entry->IsJoinEntry()) {
    JoinEntryInstr* join = block_entry->AsJoinEntry();
    if (join->phis() != NULL) {
      for (intptr_t i = 0; i < join->phis()->length(); ++i) {
        PhiInstr* phi = (*join->phis())[i];
        if (phi != NULL) {
          (*env)[i] = phi;
          phi->set_ssa_temp_index(alloc_ssa_temp_index());  // New SSA temp.
        }
      }
    }
  }

  // Attach environment to the block entry.
  AttachEnvironment(block_entry, env);

  // 2. Process normal instructions.
  for (ForwardInstructionIterator it(block_entry); !it.Done(); it.Advance()) {
    Instruction* current = it.Current();

    // Attach current environment to the instructions that need it.
    if (current->NeedsEnvironment()) {
      AttachEnvironment(current, env);
    }

    // 2a. Handle uses:
    // Update the expression stack renaming environment for each use by
    // removing the renamed value.
    // For each use of a LoadLocal, StoreLocal, or Constant: Replace it with
    // the renamed value.
    for (intptr_t i = current->InputCount() - 1; i >= 0; --i) {
      Value* v = current->InputAt(i);
      // Update expression stack.
      ASSERT(env->length() > variable_count());

      Definition* reaching_defn = env->RemoveLast();
      Definition* input_defn = v->definition();
      if (input_defn->IsLoadLocal() ||
          input_defn->IsStoreLocal() ||
          input_defn->IsConstant()) {
        // Remove the load/store from the graph.
        input_defn->RemoveFromGraph();
        // Assert we are not referencing nulls in the initial environment.
        ASSERT(reaching_defn->ssa_temp_index() != -1);
        v->set_definition(reaching_defn);
        input_defn = reaching_defn;
      }
      input_defn->AddInputUse(v);
    }

    // Drop pushed arguments for calls.
    for (intptr_t j = 0; j < current->ArgumentCount(); j++) {
      env->RemoveLast();
    }

    // 2b. Handle LoadLocal, StoreLocal, and Constant.
    Definition* definition = current->AsDefinition();
    if (definition != NULL) {
      LoadLocalInstr* load = definition->AsLoadLocal();
      StoreLocalInstr* store = definition->AsStoreLocal();
      ConstantInstr* constant = definition->AsConstant();
      if ((load != NULL) || (store != NULL) || (constant != NULL)) {
        intptr_t index;
        Definition* result;
        if (store != NULL) {
          // Update renaming environment.
          index = store->local().BitIndexIn(num_non_copied_params_);
          result = store->value()->definition();

          if (variable_liveness->IsStoreAlive(block_entry, store)) {
            (*env)[index] = result;
          } else {
            (*env)[index] = constant_null();
          }
        } else if (load != NULL) {
          // The graph construction ensures we do not have an unused LoadLocal
          // computation.
          ASSERT(definition->is_used());
          index = load->local().BitIndexIn(num_non_copied_params_);
          result = (*env)[index];

          PhiInstr* phi = result->AsPhi();
          if ((phi != NULL) && !phi->is_alive()) {
            phi->mark_alive();
            live_phis->Add(phi);
          }

          if (variable_liveness->IsLastLoad(block_entry, load)) {
            (*env)[index] = constant_null();
          }
        } else {
          ASSERT(definition->is_used());
          result = GetConstant(constant->value());
        }
        // Update expression stack or remove from graph.
        if (definition->is_used()) {
          ASSERT(result != NULL);
          env->Add(result);
          // We remove load/store/constant instructions when we find their
          // use in 2a.
        } else {
          it.RemoveCurrentFromGraph();
        }
      } else {
        // Not a load, store, or constant.
        if (definition->is_used()) {
          // Assign fresh SSA temporary and update expression stack.
          definition->set_ssa_temp_index(alloc_ssa_temp_index());
          env->Add(definition);
        }
      }
    }

    // 2c. Handle pushed argument.
    PushArgumentInstr* push = current->AsPushArgument();
    if (push != NULL) {
      env->Add(push);
    }
  }

  // 3. Process dominated blocks.
  for (intptr_t i = 0; i < block_entry->dominated_blocks().length(); ++i) {
    BlockEntryInstr* block = block_entry->dominated_blocks()[i];
    GrowableArray<Definition*> new_env(env->length());
    new_env.AddArray(*env);
    RenameRecursive(block, &new_env, live_phis, variable_liveness);
  }

  // 4. Process successor block. We have edge-split form, so that only blocks
  // with one successor can have a join block as successor.
  if ((block_entry->last_instruction()->SuccessorCount() == 1) &&
      block_entry->last_instruction()->SuccessorAt(0)->IsJoinEntry()) {
    JoinEntryInstr* successor =
        block_entry->last_instruction()->SuccessorAt(0)->AsJoinEntry();
    intptr_t pred_index = successor->IndexOfPredecessor(block_entry);
    ASSERT(pred_index >= 0);
    if (successor->phis() != NULL) {
      for (intptr_t i = 0; i < successor->phis()->length(); ++i) {
        PhiInstr* phi = (*successor->phis())[i];
        if (phi != NULL) {
          // Rename input operand.
          Value* use = new Value((*env)[i]);
          phi->SetInputAt(pred_index, use);
        }
      }
    }
  }
}


void FlowGraph::RemoveDeadPhis(GrowableArray<PhiInstr*>* live_phis) {
  while (!live_phis->is_empty()) {
    PhiInstr* phi = live_phis->RemoveLast();
    for (intptr_t i = 0; i < phi->InputCount(); i++) {
      Value* val = phi->InputAt(i);
      PhiInstr* used_phi = val->definition()->AsPhi();
      if ((used_phi != NULL) && !used_phi->is_alive()) {
        used_phi->mark_alive();
        live_phis->Add(used_phi);
      }
    }
  }

  for (BlockIterator it(postorder_iterator()); !it.Done(); it.Advance()) {
    JoinEntryInstr* join = it.Current()->AsJoinEntry();
    if (join != NULL) join->RemoveDeadPhis(constant_null());
  }
}


void FlowGraph::RemoveRedefinitions() {
  // Remove redefinition instructions inserted to inhibit hoisting.
  for (BlockIterator block_it = reverse_postorder_iterator();
       !block_it.Done();
       block_it.Advance()) {
    for (ForwardInstructionIterator instr_it(block_it.Current());
         !instr_it.Done();
         instr_it.Advance()) {
      RedefinitionInstr* redefinition = instr_it.Current()->AsRedefinition();
      if (redefinition != NULL) {
        Definition* original;
        do {
          original = redefinition->value()->definition();
        } while (original->IsRedefinition());
        redefinition->ReplaceUsesWith(original);
        instr_it.RemoveCurrentFromGraph();
      }
    }
  }
}


// Find the natural loop for the back edge m->n and attach loop information
// to block n (loop header). The algorithm is described in "Advanced Compiler
// Design & Implementation" (Muchnick) p192.
static void FindLoop(BlockEntryInstr* m,
                     BlockEntryInstr* n,
                     intptr_t num_blocks) {
  GrowableArray<BlockEntryInstr*> stack;
  BitVector* loop = new BitVector(num_blocks);

  loop->Add(n->preorder_number());
  if (n != m) {
    loop->Add(m->preorder_number());
    stack.Add(m);
  }

  while (!stack.is_empty()) {
    BlockEntryInstr* p = stack.RemoveLast();
    for (intptr_t i = 0; i < p->PredecessorCount(); ++i) {
      BlockEntryInstr* q = p->PredecessorAt(i);
      if (!loop->Contains(q->preorder_number())) {
        loop->Add(q->preorder_number());
        stack.Add(q);
      }
    }
  }
  n->set_loop_info(loop);
  if (FLAG_trace_optimization) {
    for (BitVector::Iterator it(loop); !it.Done(); it.Advance()) {
      OS::Print("  B%"Pd"\n", it.Current());
    }
  }
}


void FlowGraph::ComputeLoops(GrowableArray<BlockEntryInstr*>* loop_headers) {
  ASSERT(loop_headers->is_empty());
  for (BlockIterator it = postorder_iterator();
       !it.Done();
       it.Advance()) {
    BlockEntryInstr* block = it.Current();
    for (intptr_t i = 0; i < block->PredecessorCount(); ++i) {
      BlockEntryInstr* pred = block->PredecessorAt(i);
      if (block->Dominates(pred)) {
        if (FLAG_trace_optimization) {
          OS::Print("Back edge B%"Pd" -> B%"Pd"\n", pred->block_id(),
                    block->block_id());
        }
        FindLoop(pred, block, preorder_.length());
        loop_headers->Add(block);
      }
    }
  }
}


void FlowGraph::Bailout(const char* reason) const {
  const char* kFormat = "FlowGraph Bailout: %s %s";
  const char* function_name = parsed_function_.function().ToCString();
  intptr_t len = OS::SNPrint(NULL, 0, kFormat, function_name, reason) + 1;
  char* chars = Isolate::Current()->current_zone()->Alloc<char>(len);
  OS::SNPrint(chars, len, kFormat, function_name, reason);
  const Error& error = Error::Handle(
      LanguageError::New(String::Handle(String::New(chars))));
  Isolate::Current()->long_jump_base()->Jump(1, error);
}


intptr_t FlowGraph::InstructionCount() const {
  intptr_t size = 0;
  // Iterate each block, skipping the graph entry.
  for (intptr_t i = 1; i < preorder_.length(); ++i) {
    for (ForwardInstructionIterator it(preorder_[i]);
         !it.Done();
         it.Advance()) {
      ++size;
    }
  }
  return size;
}


void FlowGraph::ComputeBlockEffects() {
  block_effects_ = new BlockEffects(this);
}


BlockEffects::BlockEffects(FlowGraph* flow_graph)
    : available_at_(flow_graph->postorder().length()) {
  // We are tracking a single effect.
  ASSERT(EffectSet::kLastEffect == 1);

  const intptr_t block_count = flow_graph->postorder().length();

  // Set of blocks that contain side-effects.
  BitVector* kill = new BitVector(block_count);

  // Per block available-after sets. Block A is available after the block B if
  // and only if A is either equal to B or A is available at B and B contains no
  // side-effects. Initially we consider all blocks available after all other
  // blocks.
  GrowableArray<BitVector*> available_after(block_count);

  // Discover all blocks with side-effects.
  for (BlockIterator it = flow_graph->postorder_iterator();
       !it.Done();
       it.Advance()) {
    available_at_.Add(NULL);
    available_after.Add(NULL);

    BlockEntryInstr* block = it.Current();
    for (ForwardInstructionIterator it(block);
         !it.Done();
         it.Advance()) {
      if (!it.Current()->Effects().IsNone()) {
        kill->Add(block->postorder_number());
        break;
      }
    }
  }

  BitVector* temp = new BitVector(block_count);

  // Recompute available-at based on predecessors' available-after until the fix
  // point is reached.
  bool changed;
  do {
    changed = false;

    for (BlockIterator it = flow_graph->reverse_postorder_iterator();
         !it.Done();
         it.Advance()) {
      BlockEntryInstr* block = it.Current();
      const intptr_t block_num = block->postorder_number();

      if (block->IsGraphEntry()) {
        temp->Clear();  // Nothing is live-in into graph entry.
      } else {
        // Available-at is an intersection of all predecessors' available-after
        // sets.
        temp->SetAll();
        for (intptr_t i = 0; i < block->PredecessorCount(); i++) {
          const intptr_t pred = block->PredecessorAt(i)->postorder_number();
          if (available_after[pred] != NULL) {
            temp->Intersect(available_after[pred]);
          }
        }
      }

      BitVector* current = available_at_[block_num];
      if ((current == NULL) || !current->Equals(*temp)) {
        // Available-at changed: update it and recompute available-after.
        if (available_at_[block_num] == NULL) {
          current = available_at_[block_num] = new BitVector(block_count);
          available_after[block_num] = new BitVector(block_count);
          // Block is always available after itself.
          available_after[block_num]->Add(block_num);
        }
        current->CopyFrom(temp);
        if (!kill->Contains(block_num)) {
          available_after[block_num]->CopyFrom(temp);
          // Block is always available after itself.
          available_after[block_num]->Add(block_num);
        }
        changed = true;
      }
    }
  } while (changed);
}


bool BlockEffects::IsAvailableAt(Instruction* instr,
                                 BlockEntryInstr* block) const {
  return (instr->Dependencies().IsNone()) ||
      IsSideEffectFreePath(instr->GetBlock(), block);
}


bool BlockEffects::CanBeMovedTo(Instruction* instr,
                                BlockEntryInstr* block) const {
  return (instr->Dependencies().IsNone()) ||
      IsSideEffectFreePath(block, instr->GetBlock());
}


bool BlockEffects::IsSideEffectFreePath(BlockEntryInstr* from,
                                        BlockEntryInstr* to) const {
  return available_at_[to->postorder_number()]->Contains(
      from->postorder_number());
}

}  // namespace dart
