// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#include "vm/flow_graph_builder.h"

#include "lib/invocation_mirror.h"
#include "vm/ast_printer.h"
#include "vm/code_descriptors.h"
#include "vm/dart_entry.h"
#include "vm/flags.h"
#include "vm/flow_graph_compiler.h"
#include "vm/il_printer.h"
#include "vm/intermediate_language.h"
#include "vm/longjump.h"
#include "vm/object_store.h"
#include "vm/os.h"
#include "vm/parser.h"
#include "vm/resolver.h"
#include "vm/stub_code.h"
#include "vm/symbols.h"

namespace dart {

DEFINE_FLAG(bool, eliminate_type_checks, true,
            "Eliminate type checks when allowed by static type analysis.");
DEFINE_FLAG(bool, print_ast, false, "Print abstract syntax tree.");
DEFINE_FLAG(bool, print_flow_graph, false, "Print the IR flow graph.");
DEFINE_FLAG(bool, print_flow_graph_optimized, false,
            "Print the IR flow graph when optimizing.");
DEFINE_FLAG(bool, trace_type_check_elimination, false,
            "Trace type check elimination at compile time.");
DECLARE_FLAG(bool, enable_type_checks);


static const String& PrivateCoreLibName(const String& str) {
  const Library& core_lib = Library::Handle(Library::CoreLibrary());
  const String& private_name = String::ZoneHandle(core_lib.PrivateName(str));
  return private_name;
}


FlowGraphBuilder::FlowGraphBuilder(const ParsedFunction& parsed_function,
                                   InlineExitCollector* exit_collector)
  : parsed_function_(parsed_function),
    num_copied_params_(parsed_function.num_copied_params()),
    // All parameters are copied if any parameter is.
    num_non_copied_params_((num_copied_params_ == 0)
        ? parsed_function.function().num_fixed_parameters()
        : 0),
    num_stack_locals_(parsed_function.num_stack_locals()),
    exit_collector_(exit_collector),
    last_used_block_id_(0),  // 0 is used for the graph entry.
    context_level_(0),
    last_used_try_index_(CatchClauseNode::kInvalidTryIndex),
    try_index_(CatchClauseNode::kInvalidTryIndex),
    graph_entry_(NULL) { }


void FlowGraphBuilder::AddCatchEntry(CatchBlockEntryInstr* entry) {
  graph_entry_->AddCatchEntry(entry);
}


void InlineExitCollector::PrepareGraphs(FlowGraph* callee_graph) {
  ASSERT(callee_graph->graph_entry()->SuccessorCount() == 1);
  ASSERT(callee_graph->max_block_id() > caller_graph_->max_block_id());
  ASSERT(callee_graph->max_virtual_register_number() >
         caller_graph_->max_virtual_register_number());

  // Adjust the caller's maximum block id and current SSA temp index.
  caller_graph_->set_max_block_id(callee_graph->max_block_id());
  caller_graph_->set_current_ssa_temp_index(
      callee_graph->max_virtual_register_number());

  // Attach the outer environment on each instruction in the callee graph.
  for (BlockIterator block_it = callee_graph->postorder_iterator();
       !block_it.Done();
       block_it.Advance()) {
    for (ForwardInstructionIterator it(block_it.Current());
         !it.Done();
         it.Advance()) {
      Instruction* instr = it.Current();
      // TODO(zerny): Avoid creating unnecessary environments. Note that some
      // optimizations need deoptimization info for non-deoptable instructions,
      // eg, LICM on GOTOs.
      if (instr->env() != NULL) call_->env()->DeepCopyToOuter(instr);
    }
  }
}


void InlineExitCollector::AddExit(ReturnInstr* exit) {
  Data data = { NULL, exit };
  exits_.Add(data);
}


int InlineExitCollector::LowestBlockIdFirst(const Data* a, const Data* b) {
  return (a->exit_block->block_id() - b->exit_block->block_id());
}


void InlineExitCollector::SortExits() {
  // Assign block entries here because we did not necessarily know them when
  // the return exit was added to the array.
  for (int i = 0; i < exits_.length(); ++i) {
    exits_[i].exit_block = exits_[i].exit_return->GetBlock();
  }
  exits_.Sort(LowestBlockIdFirst);
}


Definition* InlineExitCollector::JoinReturns(BlockEntryInstr** exit_block,
                                             Instruction** last_instruction) {
  // First sort the list of exits by block id (caching return instruction
  // block entries as a side effect).
  SortExits();
  intptr_t num_exits = exits_.length();
  if (num_exits == 0) {
    // TODO(zerny): Add support for non-local exits, such as throw.
    UNREACHABLE();
    return NULL;
  } else if (num_exits == 1) {
    ReturnAt(0)->UnuseAllInputs();
    *exit_block = ExitBlockAt(0);
    *last_instruction = LastInstructionAt(0);
    return call_->HasUses() ? ValueAt(0)->definition() : NULL;
  } else {
    // Create a join of the returns.
    intptr_t join_id = caller_graph_->max_block_id() + 1;
    caller_graph_->set_max_block_id(join_id);
    JoinEntryInstr* join =
        new JoinEntryInstr(join_id, CatchClauseNode::kInvalidTryIndex);
    join->InheritDeoptTarget(call_);

    // The dominator set of the join is the intersection of the dominator
    // sets of all the predecessors.  If we keep the dominator sets ordered
    // by height in the dominator tree, we can also get the immediate
    // dominator of the join node from the intersection.
    //
    // block_dominators is the dominator set for each block, ordered from
    // the immediate dominator to the root of the dominator tree.  This is
    // the order we collect them in (adding at the end).
    //
    // join_dominators is the join's dominators ordered from the root of the
    // dominator tree to the immediate dominator.  This order supports
    // removing during intersection by truncating the list.
    GrowableArray<BlockEntryInstr*> block_dominators;
    GrowableArray<BlockEntryInstr*> join_dominators;
    for (intptr_t i = 0; i < num_exits; ++i) {
      // Add the control-flow edge.
      GotoInstr* goto_instr = new GotoInstr(join);
      goto_instr->InheritDeoptTarget(ReturnAt(i));
      LastInstructionAt(i)->LinkTo(goto_instr);
      ExitBlockAt(i)->set_last_instruction(LastInstructionAt(i)->next());
      join->predecessors_.Add(ExitBlockAt(i));

      // Collect the block's dominators.
      block_dominators.Clear();
      BlockEntryInstr* dominator = ExitBlockAt(i)->dominator();
      while (dominator != NULL) {
        block_dominators.Add(dominator);
        dominator = dominator->dominator();
      }

      if (i == 0) {
        // The initial dominator set is the first predecessor's dominator
        // set.  Reverse it.
        for (intptr_t j = block_dominators.length() - 1; j >= 0; --j) {
          join_dominators.Add(block_dominators[j]);
        }
      } else {
        // Intersect the block's dominators with the join's dominators so far.
        intptr_t last = block_dominators.length() - 1;
        for (intptr_t j = 0; j < join_dominators.length(); ++j) {
          intptr_t k = last - j;  // Corresponding index in block_dominators.
          if ((k < 0) || (join_dominators[j] != block_dominators[k])) {
            // We either exhausted the dominators for this block before
            // exhausting the current intersection, or else we found a block
            // on the path from the root of the tree that is not in common.
            ASSERT(j >= 2);
            join_dominators.TruncateTo(j);
            break;
          }
        }
      }
    }
    // The immediate dominator of the join is the last one in the ordered
    // intersection.
    join->set_dominator(join_dominators.Last());
    join_dominators.Last()->AddDominatedBlock(join);
    *exit_block = join;
    *last_instruction = join;

    // If the call has uses, create a phi of the returns.
    if (call_->HasUses()) {
      // Add a phi of the return values.
      PhiInstr* phi = new PhiInstr(join, num_exits);
      phi->set_ssa_temp_index(caller_graph_->alloc_ssa_temp_index());
      phi->mark_alive();
      for (intptr_t i = 0; i < num_exits; ++i) {
        ReturnAt(i)->RemoveEnvironment();
        phi->SetInputAt(i, ValueAt(i));
      }
      join->InsertPhi(phi);
      return phi;
    } else {
      // In the case that the result is unused, remove the return value uses
      // from their definition's use list.
      for (intptr_t i = 0; i < num_exits; ++i) {
        ReturnAt(i)->UnuseAllInputs();
      }
      return NULL;
    }
  }
}


void InlineExitCollector::ReplaceCall(TargetEntryInstr* callee_entry) {
  ASSERT(call_->previous() != NULL);
  ASSERT(call_->next() != NULL);
  BlockEntryInstr* call_block = call_->GetBlock();

  // Insert the callee graph into the caller graph.
  BlockEntryInstr* callee_exit = NULL;
  Instruction* callee_last_instruction = NULL;
  Definition* callee_result = JoinReturns(&callee_exit,
                                          &callee_last_instruction);
  if (callee_result != NULL) {
    call_->ReplaceUsesWith(callee_result);
  }
  if (callee_last_instruction == callee_entry) {
    // There are no instructions in the inlined function (e.g., it might be
    // a return of a parameter or a return of a constant defined in the
    // initial definitions).
    call_->previous()->LinkTo(call_->next());
  } else {
    call_->previous()->LinkTo(callee_entry->next());
    callee_last_instruction->LinkTo(call_->next());
  }
  if (callee_exit != callee_entry) {
    // In case of control flow, locally update the predecessors, phis and
    // dominator tree.
    //
    // Pictorially, the graph structure is:
    //
    //   Bc : call_block      Bi : callee_entry
    //     before_call          inlined_head
    //     call               ... other blocks ...
    //     after_call         Be : callee_exit
    //                          inlined_foot
    // And becomes:
    //
    //   Bc : call_block
    //     before_call
    //     inlined_head
    //   ... other blocks ...
    //   Be : callee_exit
    //    inlined_foot
    //    after_call
    //
    // For successors of 'after_call', the call block (Bc) is replaced as a
    // predecessor by the callee exit (Be).
    call_block->ReplaceAsPredecessorWith(callee_exit);
    // For successors of 'inlined_head', the callee entry (Bi) is replaced
    // as a predecessor by the call block (Bc).
    callee_entry->ReplaceAsPredecessorWith(call_block);

    // The callee exit is now the immediate dominator of blocks whose
    // immediate dominator was the call block.
    ASSERT(callee_exit->dominated_blocks().is_empty());
    for (intptr_t i = 0; i < call_block->dominated_blocks().length(); ++i) {
      BlockEntryInstr* block = call_block->dominated_blocks()[i];
      block->set_dominator(callee_exit);
      callee_exit->AddDominatedBlock(block);
    }
    // The call block is now the immediate dominator of blocks whose
    // immediate dominator was the callee entry.
    call_block->ClearDominatedBlocks();
    for (intptr_t i = 0; i < callee_entry->dominated_blocks().length(); ++i) {
      BlockEntryInstr* block = callee_entry->dominated_blocks()[i];
      block->set_dominator(call_block);
      call_block->AddDominatedBlock(block);
    }
  }
}


void EffectGraphVisitor::Append(const EffectGraphVisitor& other_fragment) {
  ASSERT(is_open());
  if (other_fragment.is_empty()) return;
  if (is_empty()) {
    entry_ = other_fragment.entry();
    exit_ = other_fragment.exit();
  } else {
    exit()->LinkTo(other_fragment.entry());
    exit_ = other_fragment.exit();
  }
  temp_index_ = other_fragment.temp_index();
}


Value* EffectGraphVisitor::Bind(Definition* definition) {
  ASSERT(is_open());
  DeallocateTempIndex(definition->InputCount());
  definition->set_use_kind(Definition::kValue);
  definition->set_temp_index(AllocateTempIndex());
  if (is_empty()) {
    entry_ = definition;
  } else {
    exit()->LinkTo(definition);
  }
  exit_ = definition;
  return new Value(definition);
}


void EffectGraphVisitor::Do(Definition* definition) {
  ASSERT(is_open());
  DeallocateTempIndex(definition->InputCount());
  definition->set_use_kind(Definition::kEffect);
  if (is_empty()) {
    entry_ = definition;
  } else {
    exit()->LinkTo(definition);
  }
  exit_ = definition;
}


void EffectGraphVisitor::AddInstruction(Instruction* instruction) {
  ASSERT(is_open());
  ASSERT(instruction->IsPushArgument() || !instruction->IsDefinition());
  ASSERT(!instruction->IsBlockEntry());
  DeallocateTempIndex(instruction->InputCount());
  if (is_empty()) {
    entry_ = exit_ = instruction;
  } else {
    exit()->LinkTo(instruction);
    exit_ = instruction;
  }
}


void EffectGraphVisitor::AddReturnExit(intptr_t token_pos, Value* value) {
  ASSERT(is_open());
  ReturnInstr* return_instr = new ReturnInstr(token_pos, value);
  AddInstruction(return_instr);
  InlineExitCollector* exit_collector = owner()->exit_collector();
  if (exit_collector != NULL) {
    exit_collector->AddExit(return_instr);
  }
  CloseFragment();
}


void EffectGraphVisitor::Goto(JoinEntryInstr* join) {
  ASSERT(is_open());
  if (is_empty()) {
    entry_ = new GotoInstr(join);
  } else {
    exit()->Goto(join);
  }
  exit_ = NULL;
}


// Appends a graph fragment to a block entry instruction.  Returns the entry
// instruction if the fragment was empty or else the exit of the fragment if
// it was non-empty (so NULL if the fragment is closed).
//
// Note that the fragment is no longer a valid fragment after calling this
// function -- the fragment is closed at its entry because the entry has a
// predecessor in the graph.
static Instruction* AppendFragment(BlockEntryInstr* entry,
                                   const EffectGraphVisitor& fragment) {
  if (fragment.is_empty()) return entry;
  entry->LinkTo(fragment.entry());
  return fragment.exit();
}


void EffectGraphVisitor::Join(const TestGraphVisitor& test_fragment,
                              const EffectGraphVisitor& true_fragment,
                              const EffectGraphVisitor& false_fragment) {
  // We have: a test graph fragment with zero, one, or two available exits;
  // and a pair of effect graph fragments with zero or one available exits.
  // We want to append the branch and (if necessary) a join node to this
  // graph fragment.
  ASSERT(is_open());

  // 1. Connect the test to this graph.
  Append(test_fragment);

  // 2. Connect the true and false bodies to the test and record their exits
  // (if any).
  BlockEntryInstr* true_entry = test_fragment.CreateTrueSuccessor();
  Instruction* true_exit = AppendFragment(true_entry, true_fragment);

  BlockEntryInstr* false_entry = test_fragment.CreateFalseSuccessor();
  Instruction* false_exit = AppendFragment(false_entry, false_fragment);

  // 3. Add a join or select one (or neither) of the arms as exit.
  if (true_exit == NULL) {
    exit_ = false_exit;  // May be NULL.
    if (false_exit != NULL) temp_index_ = false_fragment.temp_index();
  } else if (false_exit == NULL) {
    exit_ = true_exit;
    temp_index_ = true_fragment.temp_index();
  } else {
    JoinEntryInstr* join =
        new JoinEntryInstr(owner()->AllocateBlockId(), owner()->try_index());
    true_exit->Goto(join);
    false_exit->Goto(join);
    exit_ = join;
    ASSERT(true_fragment.temp_index() == false_fragment.temp_index());
    temp_index_ = true_fragment.temp_index();
  }
}


void EffectGraphVisitor::TieLoop(const TestGraphVisitor& test_fragment,
                                 const EffectGraphVisitor& body_fragment) {
  // We have: a test graph fragment with zero, one, or two available exits;
  // and an effect graph fragment with zero or one available exits.  We want
  // to append the 'while loop' consisting of the test graph fragment as
  // condition and the effect graph fragment as body.
  ASSERT(is_open());

  // 1. Connect the body to the test if it is reachable, and if so record
  // its exit (if any).
  BlockEntryInstr* body_entry = test_fragment.CreateTrueSuccessor();
  Instruction* body_exit = AppendFragment(body_entry, body_fragment);

  // 2. Connect the test to this graph, including the body if reachable and
  // using a fresh join node if the body is reachable and has an open exit.
  if (body_exit == NULL) {
    Append(test_fragment);
  } else {
    JoinEntryInstr* join =
        new JoinEntryInstr(owner()->AllocateBlockId(), owner()->try_index());
    join->LinkTo(test_fragment.entry());
    Goto(join);
    body_exit->Goto(join);
  }

  // 3. Set the exit to the graph to be the false successor of the test, a
  // fresh target node

  exit_ = test_fragment.CreateFalseSuccessor();
}


PushArgumentInstr* EffectGraphVisitor::PushArgument(Value* value) {
  PushArgumentInstr* result = new PushArgumentInstr(value);
  AddInstruction(result);
  return result;
}


Definition* EffectGraphVisitor::BuildStoreTemp(const LocalVariable& local,
                                               Value* value) {
  ASSERT(!local.is_captured());
  return new StoreLocalInstr(local, value);
}


Definition* EffectGraphVisitor::BuildStoreExprTemp(Value* value) {
  return BuildStoreTemp(*owner()->parsed_function().expression_temp_var(),
                        value);
}


Definition* EffectGraphVisitor::BuildLoadExprTemp() {
  return BuildLoadLocal(*owner()->parsed_function().expression_temp_var());
}


Definition* EffectGraphVisitor::BuildStoreLocal(
    const LocalVariable& local, Value* value, bool result_is_needed) {
  if (local.is_captured()) {
    InlineBailout("EffectGraphVisitor::BuildStoreLocal (context)");
    if (result_is_needed) {
      value = Bind(BuildStoreExprTemp(value));
    }

    intptr_t delta =
        owner()->context_level() - local.owner()->context_level();
    ASSERT(delta >= 0);
    Value* context = Bind(new CurrentContextInstr());
    while (delta-- > 0) {
      context = Bind(new LoadFieldInstr(
          context, Context::parent_offset(), Type::ZoneHandle()));
    }

    StoreVMFieldInstr* store =
        new StoreVMFieldInstr(context,
                              Context::variable_offset(local.index()),
                              value,
                              local.type());
    if (result_is_needed) {
      Do(store);
      return BuildLoadExprTemp();
    } else {
      return store;
    }
  } else {
    return new StoreLocalInstr(local, value);
  }
}


Definition* EffectGraphVisitor::BuildLoadLocal(const LocalVariable& local) {
  if (local.is_captured()) {
    InlineBailout("EffectGraphVisitor::BuildLoadLocal (context)");
    intptr_t delta =
        owner()->context_level() - local.owner()->context_level();
    ASSERT(delta >= 0);
    Value* context = Bind(new CurrentContextInstr());
    while (delta-- > 0) {
      context = Bind(new LoadFieldInstr(
          context, Context::parent_offset(), Type::ZoneHandle()));
    }
    return new LoadFieldInstr(context,
                              Context::variable_offset(local.index()),
                              local.type());
  } else {
    return new LoadLocalInstr(local);
  }
}


// Stores current context into the 'variable'
void EffectGraphVisitor::BuildStoreContext(const LocalVariable& variable) {
  Value* context = Bind(new CurrentContextInstr());
  Do(BuildStoreLocal(variable, context, kResultNotNeeded));
}


// Loads context saved in 'context_variable' into the current context.
void EffectGraphVisitor::BuildLoadContext(const LocalVariable& variable) {
  Value* load_saved_context = Bind(BuildLoadLocal(variable));
  AddInstruction(new StoreContextInstr(load_saved_context));
}


void TestGraphVisitor::ConnectBranchesTo(
    const GrowableArray<TargetEntryInstr**>& branches,
    JoinEntryInstr* join) const {
  ASSERT(!branches.is_empty());
  for (intptr_t i = 0; i < branches.length(); i++) {
    TargetEntryInstr* target =
        new TargetEntryInstr(owner()->AllocateBlockId(), owner()->try_index());
    *(branches[i]) = target;
    target->Goto(join);
  }
}


void TestGraphVisitor::IfTrueGoto(JoinEntryInstr* join) const {
  ConnectBranchesTo(true_successor_addresses_, join);
}


void TestGraphVisitor::IfFalseGoto(JoinEntryInstr* join) const {
  ConnectBranchesTo(false_successor_addresses_, join);
}


BlockEntryInstr* TestGraphVisitor::CreateSuccessorFor(
    const GrowableArray<TargetEntryInstr**>& branches) const {
  ASSERT(!branches.is_empty());

  if (branches.length() == 1) {
    TargetEntryInstr* target =
        new TargetEntryInstr(owner()->AllocateBlockId(), owner()->try_index());
    *(branches[0]) = target;
    return target;
  }

  JoinEntryInstr* join =
      new JoinEntryInstr(owner()->AllocateBlockId(), owner()->try_index());
  ConnectBranchesTo(branches, join);
  return join;
}


BlockEntryInstr* TestGraphVisitor::CreateTrueSuccessor() const {
  return CreateSuccessorFor(true_successor_addresses_);
}


BlockEntryInstr* TestGraphVisitor::CreateFalseSuccessor() const {
  return CreateSuccessorFor(false_successor_addresses_);
}


void TestGraphVisitor::ReturnValue(Value* value) {
  if (FLAG_enable_type_checks) {
    value = Bind(new AssertBooleanInstr(condition_token_pos(), value));
  }
  Value* constant_true = Bind(new ConstantInstr(Bool::True()));
  StrictCompareInstr* comp =
      new StrictCompareInstr(Token::kEQ_STRICT, value, constant_true);
  BranchInstr* branch = new BranchInstr(comp);
  AddInstruction(branch);
  CloseFragment();

  true_successor_addresses_.Add(branch->true_successor_address());
  false_successor_addresses_.Add(branch->false_successor_address());
}


void TestGraphVisitor::MergeBranchWithComparison(ComparisonInstr* comp) {
  ControlInstruction* branch;
  if (Token::IsStrictEqualityOperator(comp->kind())) {
    branch = new BranchInstr(new StrictCompareInstr(comp->kind(),
                                                    comp->left(),
                                                    comp->right()));
  } else if (Token::IsEqualityOperator(comp->kind()) &&
             (comp->left()->BindsToConstantNull() ||
              comp->right()->BindsToConstantNull())) {
    branch = new BranchInstr(new StrictCompareInstr(
        (comp->kind() == Token::kEQ) ? Token::kEQ_STRICT : Token::kNE_STRICT,
        comp->left(),
        comp->right()));
  } else {
    branch = new BranchInstr(comp, FLAG_enable_type_checks);
  }
  AddInstruction(branch);
  CloseFragment();
  true_successor_addresses_.Add(branch->true_successor_address());
  false_successor_addresses_.Add(branch->false_successor_address());
}


void TestGraphVisitor::MergeBranchWithNegate(BooleanNegateInstr* neg) {
  ASSERT(!FLAG_enable_type_checks);
  Value* constant_true = Bind(new ConstantInstr(Bool::True()));
  BranchInstr* branch = new BranchInstr(
      new StrictCompareInstr(Token::kNE_STRICT, neg->value(), constant_true));
  AddInstruction(branch);
  CloseFragment();
  true_successor_addresses_.Add(branch->true_successor_address());
  false_successor_addresses_.Add(branch->false_successor_address());
}


void TestGraphVisitor::ReturnDefinition(Definition* definition) {
  ComparisonInstr* comp = definition->AsComparison();
  if (comp != NULL) {
    MergeBranchWithComparison(comp);
    return;
  }
  if (!FLAG_enable_type_checks) {
    BooleanNegateInstr* neg = definition->AsBooleanNegate();
    if (neg != NULL) {
      MergeBranchWithNegate(neg);
      return;
    }
  }
  ReturnValue(Bind(definition));
}


// Special handling for AND/OR.
void TestGraphVisitor::VisitBinaryOpNode(BinaryOpNode* node) {
  // Operators "&&" and "||" cannot be overloaded therefore do not call
  // operator.
  if ((node->kind() == Token::kAND) || (node->kind() == Token::kOR)) {
    TestGraphVisitor for_left(owner(),
                              temp_index(),
                              node->left()->token_pos());
    node->left()->Visit(&for_left);

    TestGraphVisitor for_right(owner(),
                               temp_index(),
                               node->right()->token_pos());
    node->right()->Visit(&for_right);

    Append(for_left);

    if (node->kind() == Token::kAND) {
      AppendFragment(for_left.CreateTrueSuccessor(), for_right);
      true_successor_addresses_.AddArray(for_right.true_successor_addresses_);
      false_successor_addresses_.AddArray(for_left.false_successor_addresses_);
      false_successor_addresses_.AddArray(for_right.false_successor_addresses_);
    } else {
      ASSERT(node->kind() == Token::kOR);
      AppendFragment(for_left.CreateFalseSuccessor(), for_right);
      false_successor_addresses_.AddArray(for_right.false_successor_addresses_);
      true_successor_addresses_.AddArray(for_left.true_successor_addresses_);
      true_successor_addresses_.AddArray(for_right.true_successor_addresses_);
    }
    CloseFragment();
    return;
  }
  ValueGraphVisitor::VisitBinaryOpNode(node);
}


void EffectGraphVisitor::Bailout(const char* reason) {
  owner()->Bailout(reason);
}


void EffectGraphVisitor::InlineBailout(const char* reason) {
  owner()->parsed_function().function().set_is_inlinable(false);
  if (owner()->IsInlining()) owner()->Bailout(reason);
}


// <Statement> ::= Return { value:                <Expression>
//                          inlined_finally_list: <InlinedFinally>* }
void EffectGraphVisitor::VisitReturnNode(ReturnNode* node) {
  ValueGraphVisitor for_value(owner(), temp_index());
  node->value()->Visit(&for_value);
  Append(for_value);

  for (intptr_t i = 0; i < node->inlined_finally_list_length(); i++) {
    InlineBailout("EffectGraphVisitor::VisitReturnNode (exception)");
    EffectGraphVisitor for_effect(owner(), temp_index());
    node->InlinedFinallyNodeAt(i)->Visit(&for_effect);
    Append(for_effect);
    if (!is_open()) return;
  }

  Value* return_value = for_value.value();
  if (FLAG_enable_type_checks) {
    const Function& function = owner()->parsed_function().function();
    const bool is_implicit_dynamic_getter =
        (!function.is_static() &&
        ((function.kind() == RawFunction::kImplicitGetter) ||
         (function.kind() == RawFunction::kConstImplicitGetter)));
    // Implicit getters do not need a type check at return, unless they compute
    // the initial value of a static field.
    // The body of a constructor cannot modify the type of the
    // constructed instance, which is passed in as an implicit parameter.
    // However, factories may create an instance of the wrong type.
    if (!is_implicit_dynamic_getter && !function.IsConstructor()) {
      const AbstractType& dst_type =
          AbstractType::ZoneHandle(
              owner()->parsed_function().function().result_type());
      return_value = BuildAssignableValue(node->value()->token_pos(),
                                          return_value,
                                          dst_type,
                                          Symbols::FunctionResult());
    }
  }

  intptr_t current_context_level = owner()->context_level();
  ASSERT(current_context_level >= 0);
  if (owner()->parsed_function().saved_entry_context_var() != NULL) {
    // CTX on entry was saved, but not linked as context parent.
    BuildLoadContext(*owner()->parsed_function().saved_entry_context_var());
  } else {
    while (current_context_level-- > 0) {
      UnchainContext();
    }
  }

  AddReturnExit(node->token_pos(), return_value);
}


// <Expression> ::= Literal { literal: Instance }
void EffectGraphVisitor::VisitLiteralNode(LiteralNode* node) {
  return;
}


void ValueGraphVisitor::VisitLiteralNode(LiteralNode* node) {
  ReturnDefinition(new ConstantInstr(node->literal()));
}


// Type nodes are used when a type is referenced as a literal. Type nodes
// can also be used for the right-hand side of instanceof comparisons,
// but they are handled specially in that context, not here.
void EffectGraphVisitor::VisitTypeNode(TypeNode* node) {
  return;
}


void ValueGraphVisitor::VisitTypeNode(TypeNode* node) {
  ReturnDefinition(new ConstantInstr(node->type()));
}


// Returns true if the type check can be skipped, for example, if the
// destination type is dynamic or if the compile type of the value is a subtype
// of the destination type.
bool EffectGraphVisitor::CanSkipTypeCheck(intptr_t token_pos,
                                          Value* value,
                                          const AbstractType& dst_type,
                                          const String& dst_name) {
  ASSERT(!dst_type.IsNull());
  ASSERT(dst_type.IsFinalized());

  // If the destination type is malformed, a dynamic type error must be thrown
  // at run time.
  if (dst_type.IsMalformed()) {
    return false;
  }

  // Any type is more specific than the dynamic type and than the Object type.
  if (dst_type.IsDynamicType() || dst_type.IsObjectType()) {
    return true;
  }

  // Do not perform type check elimination if this optimization is turned off.
  if (!FLAG_eliminate_type_checks) {
    return false;
  }

  // If nothing is known about the value, as is the case for passed-in
  // parameters, and since dst_type is not one of the tested cases above, then
  // the type test cannot be eliminated.
  if (value == NULL) {
    return false;
  }

  const bool eliminated = value->Type()->IsAssignableTo(dst_type);
  if (FLAG_trace_type_check_elimination) {
    FlowGraphPrinter::PrintTypeCheck(owner()->parsed_function(),
                                     token_pos,
                                     value,
                                     dst_type,
                                     dst_name,
                                     eliminated);
  }
  return eliminated;
}


// <Expression> :: Assignable { expr:     <Expression>
//                              type:     AbstractType
//                              dst_name: String }
void EffectGraphVisitor::VisitAssignableNode(AssignableNode* node) {
  ValueGraphVisitor for_value(owner(), temp_index());
  node->expr()->Visit(&for_value);
  Append(for_value);
  Definition* checked_value;
  if (CanSkipTypeCheck(node->expr()->token_pos(),
                       for_value.value(),
                       node->type(),
                       node->dst_name())) {
    checked_value = for_value.value()->definition();  // No check needed.
  } else {
    checked_value = BuildAssertAssignable(node->expr()->token_pos(),
                                          for_value.value(),
                                          node->type(),
                                          node->dst_name());
  }
  ReturnDefinition(checked_value);
}


void ValueGraphVisitor::VisitAssignableNode(AssignableNode* node) {
  ValueGraphVisitor for_value(owner(), temp_index());
  node->expr()->Visit(&for_value);
  Append(for_value);
  ReturnValue(BuildAssignableValue(node->expr()->token_pos(),
                                   for_value.value(),
                                   node->type(),
                                   node->dst_name()));
}


// <Expression> :: BinaryOp { kind:  Token::Kind
//                            left:  <Expression>
//                            right: <Expression> }
void EffectGraphVisitor::VisitBinaryOpNode(BinaryOpNode* node) {
  // Operators "&&" and "||" cannot be overloaded therefore do not call
  // operator.
  if ((node->kind() == Token::kAND) || (node->kind() == Token::kOR)) {
    // See ValueGraphVisitor::VisitBinaryOpNode.
    TestGraphVisitor for_left(owner(),
                              temp_index(),
                              node->left()->token_pos());
    node->left()->Visit(&for_left);
    EffectGraphVisitor for_right(owner(), temp_index());
    node->right()->Visit(&for_right);
    EffectGraphVisitor empty(owner(), temp_index());
    if (node->kind() == Token::kAND) {
      Join(for_left, for_right, empty);
    } else {
      Join(for_left, empty, for_right);
    }
    return;
  }
  ValueGraphVisitor for_left_value(owner(), temp_index());
  node->left()->Visit(&for_left_value);
  Append(for_left_value);
  PushArgumentInstr* push_left = PushArgument(for_left_value.value());

  ValueGraphVisitor for_right_value(owner(), temp_index());
  node->right()->Visit(&for_right_value);
  Append(for_right_value);
  PushArgumentInstr* push_right = PushArgument(for_right_value.value());

  ZoneGrowableArray<PushArgumentInstr*>* arguments =
      new ZoneGrowableArray<PushArgumentInstr*>(2);
  arguments->Add(push_left);
  arguments->Add(push_right);
  const String& name = String::ZoneHandle(Symbols::New(node->Name()));
  InstanceCallInstr* call = new InstanceCallInstr(node->token_pos(),
                                                  name,
                                                  node->kind(),
                                                  arguments,
                                                  Array::ZoneHandle(),
                                                  2);
  ReturnDefinition(call);
}


// Special handling for AND/OR.
void ValueGraphVisitor::VisitBinaryOpNode(BinaryOpNode* node) {
  // Operators "&&" and "||" cannot be overloaded therefore do not call
  // operator.
  if ((node->kind() == Token::kAND) || (node->kind() == Token::kOR)) {
    // Implement short-circuit logic: do not evaluate right if evaluation
    // of left is sufficient.
    // AND:  left ? right === true : false;
    // OR:   left ? true : right === true;

    TestGraphVisitor for_test(owner(),
                              temp_index(),
                              node->left()->token_pos());
    node->left()->Visit(&for_test);

    ValueGraphVisitor for_right(owner(), temp_index());
    node->right()->Visit(&for_right);
    Value* right_value = for_right.value();
    if (FLAG_enable_type_checks) {
      right_value =
          for_right.Bind(new AssertBooleanInstr(node->right()->token_pos(),
                                                right_value));
    }
    Value* constant_true = for_right.Bind(new ConstantInstr(Bool::True()));
    Value* compare =
        for_right.Bind(new StrictCompareInstr(Token::kEQ_STRICT,
                                              right_value,
                                              constant_true));
    for_right.Do(BuildStoreExprTemp(compare));

    if (node->kind() == Token::kAND) {
      ValueGraphVisitor for_false(owner(), temp_index());
      Value* constant_false = for_false.Bind(new ConstantInstr(Bool::False()));
      for_false.Do(BuildStoreExprTemp(constant_false));
      Join(for_test, for_right, for_false);
    } else {
      ASSERT(node->kind() == Token::kOR);
      ValueGraphVisitor for_true(owner(), temp_index());
      Value* constant_true = for_true.Bind(new ConstantInstr(Bool::True()));
      for_true.Do(BuildStoreExprTemp(constant_true));
      Join(for_test, for_true, for_right);
    }
    ReturnDefinition(BuildLoadExprTemp());
    return;
  }
  EffectGraphVisitor::VisitBinaryOpNode(node);
}


void EffectGraphVisitor::BuildTypecheckPushArguments(
    intptr_t token_pos,
    PushArgumentInstr** push_instantiator_result,
    PushArgumentInstr** push_instantiator_type_arguments_result) {
  const Class& instantiator_class = Class::Handle(
      owner()->parsed_function().function().Owner());
  // Since called only when type tested against is not instantiated.
  ASSERT(instantiator_class.NumTypeParameters() > 0);
  Value* instantiator_type_arguments = NULL;
  Value* instantiator = BuildInstantiator();
  if (instantiator == NULL) {
    // No instantiator when inside factory.
    *push_instantiator_result = PushArgument(BuildNullValue());
    instantiator_type_arguments =
        BuildInstantiatorTypeArguments(token_pos, instantiator_class, NULL);
  } else {
    instantiator = Bind(BuildStoreExprTemp(instantiator));
    *push_instantiator_result = PushArgument(instantiator);
    Value* loaded = Bind(BuildLoadExprTemp());
    instantiator_type_arguments =
        BuildInstantiatorTypeArguments(token_pos, instantiator_class, loaded);
  }
  *push_instantiator_type_arguments_result =
      PushArgument(instantiator_type_arguments);
}



void EffectGraphVisitor::BuildTypecheckArguments(
    intptr_t token_pos,
    Value** instantiator_result,
    Value** instantiator_type_arguments_result) {
  Value* instantiator = NULL;
  Value* instantiator_type_arguments = NULL;
  const Class& instantiator_class = Class::Handle(
      owner()->parsed_function().function().Owner());
  // Since called only when type tested against is not instantiated.
  ASSERT(instantiator_class.NumTypeParameters() > 0);
  instantiator = BuildInstantiator();
  if (instantiator == NULL) {
    // No instantiator when inside factory.
    instantiator = BuildNullValue();
    instantiator_type_arguments =
        BuildInstantiatorTypeArguments(token_pos, instantiator_class, NULL);
  } else {
    // Preserve instantiator.
    instantiator = Bind(BuildStoreExprTemp(instantiator));
    Value* loaded = Bind(BuildLoadExprTemp());
    instantiator_type_arguments =
        BuildInstantiatorTypeArguments(token_pos, instantiator_class, loaded);
  }
  *instantiator_result = instantiator;
  *instantiator_type_arguments_result = instantiator_type_arguments;
}


Value* EffectGraphVisitor::BuildNullValue() {
  return Bind(new ConstantInstr(Object::ZoneHandle()));
}


// Used for testing incoming arguments.
AssertAssignableInstr* EffectGraphVisitor::BuildAssertAssignable(
    intptr_t token_pos,
    Value* value,
    const AbstractType& dst_type,
    const String& dst_name) {
  // Build the type check computation.
  Value* instantiator = NULL;
  Value* instantiator_type_arguments = NULL;
  if (dst_type.IsInstantiated()) {
    instantiator = BuildNullValue();
    instantiator_type_arguments = BuildNullValue();
  } else {
    BuildTypecheckArguments(token_pos,
                            &instantiator,
                            &instantiator_type_arguments);
  }
  return new AssertAssignableInstr(token_pos,
                                   value,
                                   instantiator,
                                   instantiator_type_arguments,
                                   dst_type,
                                   dst_name);
}


// Used for type casts and to test assignments.
Value* EffectGraphVisitor::BuildAssignableValue(intptr_t token_pos,
                                                Value* value,
                                                const AbstractType& dst_type,
                                                const String& dst_name) {
  if (CanSkipTypeCheck(token_pos, value, dst_type, dst_name)) {
    return value;
  }
  return Bind(BuildAssertAssignable(token_pos, value, dst_type, dst_name));
}


void EffectGraphVisitor::BuildTypeTest(ComparisonNode* node) {
  ASSERT(Token::IsTypeTestOperator(node->kind()));
  EffectGraphVisitor for_left_value(owner(), temp_index());
  node->left()->Visit(&for_left_value);
  Append(for_left_value);
}


void ValueGraphVisitor::BuildTypeTest(ComparisonNode* node) {
  ASSERT(Token::IsTypeTestOperator(node->kind()));
  const AbstractType& type = node->right()->AsTypeNode()->type();
  ASSERT(type.IsFinalized() && !type.IsMalformed());
  const bool negate_result = (node->kind() == Token::kISNOT);
  // All objects are instances of type T if Object type is a subtype of type T.
  const Type& object_type = Type::Handle(Type::ObjectType());
  if (type.IsInstantiated() && object_type.IsSubtypeOf(type, NULL)) {
    // Must evaluate left side.
    EffectGraphVisitor for_left_value(owner(), temp_index());
    node->left()->Visit(&for_left_value);
    Append(for_left_value);
    ReturnDefinition(new ConstantInstr(negate_result ?
                                       Bool::False() : Bool::True()));
    return;
  }

  // Eliminate the test if it can be performed successfully at compile time.
  if ((node->left() != NULL) &&
      node->left()->IsLiteralNode() &&
      type.IsInstantiated()) {
    const Instance& literal_value = node->left()->AsLiteralNode()->literal();
    const Class& cls = Class::Handle(literal_value.clazz());
    ConstantInstr* result = NULL;
    if (cls.IsNullClass()) {
      // A null object is only an instance of Object and dynamic, which has
      // already been checked above (if the type is instantiated). So we can
      // return false here if the instance is null (and if the type is
      // instantiated).
      result = new ConstantInstr(negate_result ? Bool::True() : Bool::False());
    } else {
      Error& malformed_error = Error::Handle();
      if (literal_value.IsInstanceOf(type,
                                     TypeArguments::Handle(),
                                     &malformed_error)) {
        result = new ConstantInstr(negate_result ?
                                   Bool::False() : Bool::True());
      } else {
        result = new ConstantInstr(negate_result ?
                                   Bool::True() : Bool::False());
      }
      ASSERT(malformed_error.IsNull());
    }
    ReturnDefinition(result);
    return;
  }

  ValueGraphVisitor for_left_value(owner(), temp_index());
  node->left()->Visit(&for_left_value);
  Append(for_left_value);
  PushArgumentInstr* push_left = PushArgument(for_left_value.value());
  PushArgumentInstr* push_instantiator = NULL;
  PushArgumentInstr* push_type_args = NULL;
  if (type.IsInstantiated()) {
    push_instantiator = PushArgument(BuildNullValue());
    push_type_args = PushArgument(BuildNullValue());
  } else {
    BuildTypecheckPushArguments(node->token_pos(),
                                &push_instantiator,
                                &push_type_args);
  }
  ZoneGrowableArray<PushArgumentInstr*>* arguments =
      new ZoneGrowableArray<PushArgumentInstr*>(5);
  arguments->Add(push_left);
  arguments->Add(push_instantiator);
  arguments->Add(push_type_args);
  ASSERT(!node->right()->AsTypeNode()->type().IsNull());
  Value* type_arg = Bind(
      new ConstantInstr(node->right()->AsTypeNode()->type()));
  arguments->Add(PushArgument(type_arg));
  const Bool& negate = (node->kind() == Token::kISNOT) ? Bool::True() :
                                                         Bool::False();
  Value* negate_arg = Bind(new ConstantInstr(negate));
  arguments->Add(PushArgument(negate_arg));
  const intptr_t kNumArgsChecked = 1;
  InstanceCallInstr* call = new InstanceCallInstr(
      node->token_pos(),
      PrivateCoreLibName(Symbols::_instanceOf()),
      node->kind(),
      arguments,
      Array::ZoneHandle(),  // No argument names.
      kNumArgsChecked);
  ReturnDefinition(call);
}


void EffectGraphVisitor::BuildTypeCast(ComparisonNode* node) {
  ASSERT(Token::IsTypeCastOperator(node->kind()));
  const AbstractType& type = node->right()->AsTypeNode()->type();
  ASSERT(type.IsFinalized());  // The type in a type cast may be malformed.
  ValueGraphVisitor for_value(owner(), temp_index());
  node->left()->Visit(&for_value);
  const String& dst_name = String::ZoneHandle(
      Symbols::New(Exceptions::kCastErrorDstName));
  if (!CanSkipTypeCheck(node->token_pos(), for_value.value(), type, dst_name)) {
    Append(for_value);
    Do(BuildAssertAssignable(
        node->token_pos(), for_value.value(), type, dst_name));
  }
}


void ValueGraphVisitor::BuildTypeCast(ComparisonNode* node) {
  ASSERT(Token::IsTypeCastOperator(node->kind()));
  ASSERT(!node->right()->AsTypeNode()->type().IsNull());
  const AbstractType& type = node->right()->AsTypeNode()->type();
  ASSERT(type.IsFinalized());  // The type in a type cast may be malformed.
  ValueGraphVisitor for_value(owner(), temp_index());
  node->left()->Visit(&for_value);
  Append(for_value);
  const String& dst_name = String::ZoneHandle(
      Symbols::New(Exceptions::kCastErrorDstName));
  if (type.IsMalformed()) {
    ReturnValue(BuildAssignableValue(node->token_pos(),
                                     for_value.value(),
                                     type,
                                     dst_name));
  } else {
    if (CanSkipTypeCheck(node->token_pos(),
                         for_value.value(),
                         type,
                         dst_name)) {
      ReturnValue(for_value.value());
      return;
    }
    PushArgumentInstr* push_left = PushArgument(for_value.value());
    PushArgumentInstr* push_instantiator = NULL;
    PushArgumentInstr* push_type_args = NULL;
    if (type.IsInstantiated()) {
      push_instantiator = PushArgument(BuildNullValue());
      push_type_args = PushArgument(BuildNullValue());
    } else {
      BuildTypecheckPushArguments(node->token_pos(),
                                  &push_instantiator,
                                  &push_type_args);
    }
    ZoneGrowableArray<PushArgumentInstr*>* arguments =
        new ZoneGrowableArray<PushArgumentInstr*>(4);
    arguments->Add(push_left);
    arguments->Add(push_instantiator);
    arguments->Add(push_type_args);
    Value* type_arg = Bind(new ConstantInstr(type));
    arguments->Add(PushArgument(type_arg));
    const intptr_t kNumArgsChecked = 1;
    InstanceCallInstr* call = new InstanceCallInstr(
        node->token_pos(),
        PrivateCoreLibName(Symbols::_as()),
        node->kind(),
        arguments,
        Array::ZoneHandle(),  // No argument names.
        kNumArgsChecked);
    ReturnDefinition(call);
  }
}


// <Expression> :: Comparison { kind:  Token::Kind
//                              left:  <Expression>
//                              right: <Expression> }
// TODO(srdjan): Implement new equality.
void EffectGraphVisitor::VisitComparisonNode(ComparisonNode* node) {
  if (Token::IsTypeTestOperator(node->kind())) {
    BuildTypeTest(node);
    return;
  }
  if (Token::IsTypeCastOperator(node->kind())) {
    BuildTypeCast(node);
    return;
  }
  if ((node->kind() == Token::kEQ_STRICT) ||
      (node->kind() == Token::kNE_STRICT)) {
    ValueGraphVisitor for_left_value(owner(), temp_index());
    node->left()->Visit(&for_left_value);
    Append(for_left_value);
    ValueGraphVisitor for_right_value(owner(), temp_index());
    node->right()->Visit(&for_right_value);
    Append(for_right_value);
    StrictCompareInstr* comp = new StrictCompareInstr(
        node->kind(), for_left_value.value(), for_right_value.value());
    ReturnDefinition(comp);
    return;
  }

  if ((node->kind() == Token::kEQ) || (node->kind() == Token::kNE)) {
    ValueGraphVisitor for_left_value(owner(), temp_index());
    node->left()->Visit(&for_left_value);
    Append(for_left_value);
    ValueGraphVisitor for_right_value(owner(), temp_index());
    node->right()->Visit(&for_right_value);
    Append(for_right_value);
    if (FLAG_enable_type_checks) {
      EqualityCompareInstr* comp = new EqualityCompareInstr(
          node->token_pos(),
          Token::kEQ,
          for_left_value.value(),
          for_right_value.value());
      if (node->kind() == Token::kEQ) {
        ReturnDefinition(comp);
      } else {
        Value* eq_result = Bind(comp);
        eq_result = Bind(new AssertBooleanInstr(node->token_pos(), eq_result));
        ReturnDefinition(new BooleanNegateInstr(eq_result));
      }
    } else {
      EqualityCompareInstr* comp = new EqualityCompareInstr(
          node->token_pos(),
          node->kind(),
          for_left_value.value(),
          for_right_value.value());
      ReturnDefinition(comp);
    }
    return;
  }

  ValueGraphVisitor for_left_value(owner(), temp_index());
  node->left()->Visit(&for_left_value);
  Append(for_left_value);
  ValueGraphVisitor for_right_value(owner(), temp_index());
  node->right()->Visit(&for_right_value);
  Append(for_right_value);
  RelationalOpInstr* comp = new RelationalOpInstr(node->token_pos(),
                                                  node->kind(),
                                                  for_left_value.value(),
                                                  for_right_value.value());
  ReturnDefinition(comp);
}


void EffectGraphVisitor::VisitUnaryOpNode(UnaryOpNode* node) {
  // "!" cannot be overloaded, therefore do not call operator.
  if (node->kind() == Token::kNOT) {
    ValueGraphVisitor for_value(owner(), temp_index());
    node->operand()->Visit(&for_value);
    Append(for_value);
    Value* value = for_value.value();
    if (FLAG_enable_type_checks) {
      value =
          Bind(new AssertBooleanInstr(node->operand()->token_pos(), value));
    }
    BooleanNegateInstr* negate = new BooleanNegateInstr(value);
    ReturnDefinition(negate);
    return;
  }

  ValueGraphVisitor for_value(owner(), temp_index());
  node->operand()->Visit(&for_value);
  Append(for_value);
  PushArgumentInstr* push_value = PushArgument(for_value.value());
  ZoneGrowableArray<PushArgumentInstr*>* arguments =
      new ZoneGrowableArray<PushArgumentInstr*>(1);
  arguments->Add(push_value);
  InstanceCallInstr* call =
      new InstanceCallInstr(node->token_pos(),
                            String::ZoneHandle(
                                Symbols::New(Token::Str(node->kind()))),
                            node->kind(),
                            arguments,
                            Array::ZoneHandle(),
                            1);
  ReturnDefinition(call);
}


void EffectGraphVisitor::VisitConditionalExprNode(ConditionalExprNode* node) {
  TestGraphVisitor for_test(owner(),
                            temp_index(),
                            node->condition()->token_pos());
  node->condition()->Visit(&for_test);

  // Translate the subexpressions for their effects.
  EffectGraphVisitor for_true(owner(), temp_index());
  node->true_expr()->Visit(&for_true);
  EffectGraphVisitor for_false(owner(), temp_index());
  node->false_expr()->Visit(&for_false);

  Join(for_test, for_true, for_false);
}


void ValueGraphVisitor::VisitConditionalExprNode(ConditionalExprNode* node) {
  TestGraphVisitor for_test(owner(),
                            temp_index(),
                            node->condition()->token_pos());
  node->condition()->Visit(&for_test);

  ValueGraphVisitor for_true(owner(), temp_index());
  node->true_expr()->Visit(&for_true);
  ASSERT(for_true.is_open());
  for_true.Do(BuildStoreExprTemp(for_true.value()));

  ValueGraphVisitor for_false(owner(), temp_index());
  node->false_expr()->Visit(&for_false);
  ASSERT(for_false.is_open());
  for_false.Do(BuildStoreExprTemp(for_false.value()));

  Join(for_test, for_true, for_false);
  ReturnDefinition(BuildLoadExprTemp());
}


// <Statement> ::= If { condition: <Expression>
//                      true_branch: <Sequence>
//                      false_branch: <Sequence> }
void EffectGraphVisitor::VisitIfNode(IfNode* node) {
  TestGraphVisitor for_test(owner(),
                            temp_index(),
                            node->condition()->token_pos());
  node->condition()->Visit(&for_test);

  EffectGraphVisitor for_true(owner(), temp_index());
  EffectGraphVisitor for_false(owner(), temp_index());

  node->true_branch()->Visit(&for_true);
  // The for_false graph fragment will be empty (default graph fragment) if
  // we do not call Visit.
  if (node->false_branch() != NULL) node->false_branch()->Visit(&for_false);
  Join(for_test, for_true, for_false);
}


void EffectGraphVisitor::VisitSwitchNode(SwitchNode* node) {
  EffectGraphVisitor switch_body(owner(), temp_index());
  node->body()->Visit(&switch_body);
  Append(switch_body);
  if ((node->label() != NULL) && (node->label()->join_for_break() != NULL)) {
    if (is_open()) Goto(node->label()->join_for_break());
    exit_ = node->label()->join_for_break();
  }
  // No continue label allowed.
  ASSERT((node->label() == NULL) ||
         (node->label()->join_for_continue() == NULL));
}


// A case node contains zero or more case expressions, can contain default
// and a case statement body.
// Compose fragment as follows:
// - if no case expressions, must have default:
//   a) target
//   b) [ case-statements ]
//
// - if has 1 or more case statements
//   a) target-0
//   b) [ case-expression-0 ] -> (true-target-0, target-1)
//   c) target-1
//   d) [ case-expression-1 ] -> (true-target-1, exit-target)
//   e) true-target-0 -> case-statements-join
//   f) true-target-1 -> case-statements-join
//   g) case-statements-join
//   h) [ case-statements ] -> exit-join
//   i) exit-target -> exit-join
//   j) exit-join
//
// Note: The specification of switch/case is under discussion and may change
// drastically.
void EffectGraphVisitor::VisitCaseNode(CaseNode* node) {
  const intptr_t len = node->case_expressions()->length();
  // Create case statements instructions.
  EffectGraphVisitor for_case_statements(owner(), temp_index());
  // Compute start of statements fragment.
  JoinEntryInstr* statement_start = NULL;
  if ((node->label() != NULL) && node->label()->is_continue_target()) {
    // Since a labeled jump continue statement occur in a different case node,
    // allocate JoinNode here and use it as statement start.
    statement_start = node->label()->join_for_continue();
    if (statement_start == NULL) {
      statement_start = new JoinEntryInstr(owner()->AllocateBlockId(),
                                           owner()->try_index());
      node->label()->set_join_for_continue(statement_start);
    }
  } else {
    statement_start = new JoinEntryInstr(owner()->AllocateBlockId(),
                                         owner()->try_index());
  }
  node->statements()->Visit(&for_case_statements);
  Instruction* statement_exit =
      AppendFragment(statement_start, for_case_statements);
  if (is_open() && (len == 0)) {
    ASSERT(node->contains_default());
    // Default only case node.
    Goto(statement_start);
    exit_ = statement_exit;
    return;
  }

  // Generate instructions for all case expressions.
  TargetEntryInstr* next_target = NULL;
  for (intptr_t i = 0; i < len; i++) {
    AstNode* case_expr = node->case_expressions()->NodeAt(i);
    TestGraphVisitor for_case_expression(owner(),
                                         temp_index(),
                                         case_expr->token_pos());
    case_expr->Visit(&for_case_expression);
    if (i == 0) {
      // Append only the first one, everything else is connected from it.
      Append(for_case_expression);
    } else {
      ASSERT(next_target != NULL);
      AppendFragment(next_target, for_case_expression);
    }
    for_case_expression.IfTrueGoto(statement_start);
    next_target = for_case_expression.CreateFalseSuccessor()->AsTargetEntry();
  }

  // Once a test fragment has been added, this fragment is closed.
  ASSERT(!is_open());

  Instruction* exit_instruction = NULL;
  // Handle last (or only) case: false goes to exit or to statement if this
  // node contains default.
  if (len > 0) {
    ASSERT(next_target != NULL);
    if (node->contains_default()) {
      // True and false go to statement start.
      next_target->Goto(statement_start);
      exit_instruction = statement_exit;
    } else {
      if (statement_exit != NULL) {
        JoinEntryInstr* join = new JoinEntryInstr(owner()->AllocateBlockId(),
                                                  owner()->try_index());
        statement_exit->Goto(join);
        next_target->Goto(join);
        exit_instruction = join;
      } else {
        exit_instruction = next_target;
      }
    }
  } else {
    // A CaseNode without case expressions must contain default.
    ASSERT(node->contains_default());
    Goto(statement_start);
    exit_instruction = statement_exit;
  }

  ASSERT(!is_open());
  exit_ = exit_instruction;
}


// <Statement> ::= While { label:     SourceLabel
//                         condition: <Expression>
//                         body:      <Sequence> }
// The fragment is composed as follows:
// a) loop-join
// b) [ test ] -> (body-entry-target, loop-exit-target)
// c) body-entry-target
// d) [ body ] -> (continue-join)
// e) continue-join -> (loop-join)
// f) loop-exit-target
// g) break-join (optional)
void EffectGraphVisitor::VisitWhileNode(WhileNode* node) {
  TestGraphVisitor for_test(owner(),
                            temp_index(),
                            node->condition()->token_pos());
  node->condition()->Visit(&for_test);
  ASSERT(!for_test.is_empty());  // Language spec.

  EffectGraphVisitor for_body(owner(), temp_index());
  for_body.AddInstruction(
      new CheckStackOverflowInstr(node->token_pos()));
  node->body()->Visit(&for_body);

  // Labels are set after body traversal.
  SourceLabel* lbl = node->label();
  ASSERT(lbl != NULL);
  JoinEntryInstr* join = lbl->join_for_continue();
  if (join != NULL) {
    if (for_body.is_open()) for_body.Goto(join);
    for_body.exit_ = join;
  }
  TieLoop(for_test, for_body);
  join = lbl->join_for_break();
  if (join != NULL) {
    Goto(join);
    exit_ = join;
  }
}


// The fragment is composed as follows:
// a) body-entry-join
// b) [ body ]
// c) test-entry (continue-join or body-exit-target)
// d) [ test-entry ] -> (back-target, loop-exit-target)
// e) back-target -> (body-entry-join)
// f) loop-exit-target
// g) break-join
void EffectGraphVisitor::VisitDoWhileNode(DoWhileNode* node) {
  // Traverse body first in order to generate continue and break labels.
  EffectGraphVisitor for_body(owner(), temp_index());
  for_body.AddInstruction(
      new CheckStackOverflowInstr(node->token_pos()));
  node->body()->Visit(&for_body);

  TestGraphVisitor for_test(owner(),
                            temp_index(),
                            node->condition()->token_pos());
  node->condition()->Visit(&for_test);
  ASSERT(is_open());

  // Tie do-while loop (test is after the body).
  JoinEntryInstr* body_entry_join =
      new JoinEntryInstr(owner()->AllocateBlockId(),
                         owner()->try_index());
  Goto(body_entry_join);
  Instruction* body_exit = AppendFragment(body_entry_join, for_body);

  JoinEntryInstr* join = node->label()->join_for_continue();
  if ((body_exit != NULL) || (join != NULL)) {
    if (join == NULL) {
      join = new JoinEntryInstr(owner()->AllocateBlockId(),
                                owner()->try_index());
    }
    join->LinkTo(for_test.entry());
    if (body_exit != NULL) {
      body_exit->Goto(join);
    }
  }

  for_test.IfTrueGoto(body_entry_join);
  join = node->label()->join_for_break();
  if (join == NULL) {
    exit_ = for_test.CreateFalseSuccessor();
  } else {
    for_test.IfFalseGoto(join);
    exit_ = join;
  }
}


// A ForNode can contain break and continue jumps. 'break' joins to
// ForNode exit, 'continue' joins at increment entry. The fragment is composed
// as follows:
// a) [ initializer ]
// b) loop-join
// c) [ test ] -> (body-entry-target, loop-exit-target)
// d) body-entry-target
// e) [ body ]
// f) continue-join (optional)
// g) [ increment ] -> (loop-join)
// h) loop-exit-target
// i) break-join
void EffectGraphVisitor::VisitForNode(ForNode* node) {
  EffectGraphVisitor for_initializer(owner(), temp_index());
  node->initializer()->Visit(&for_initializer);
  Append(for_initializer);
  ASSERT(is_open());

  // Compose body to set any jump labels.
  EffectGraphVisitor for_body(owner(), temp_index());
  for_body.AddInstruction(
      new CheckStackOverflowInstr(node->token_pos()));
  node->body()->Visit(&for_body);

  // Join loop body, increment and compute their end instruction.
  ASSERT(!for_body.is_empty());
  Instruction* loop_increment_end = NULL;
  EffectGraphVisitor for_increment(owner(), temp_index());
  node->increment()->Visit(&for_increment);
  JoinEntryInstr* join = node->label()->join_for_continue();
  if (join != NULL) {
    // Insert the join between the body and increment.
    if (for_body.is_open()) for_body.Goto(join);
    loop_increment_end = AppendFragment(join, for_increment);
    ASSERT(loop_increment_end != NULL);
  } else if (for_body.is_open()) {
    // Do not insert an extra basic block.
    for_body.Append(for_increment);
    loop_increment_end = for_body.exit();
    // 'for_body' contains at least the stack check.
    ASSERT(loop_increment_end != NULL);
  } else {
    loop_increment_end = NULL;
  }

  // 'loop_increment_end' is NULL only if there is no join for continue and the
  // body is not open, i.e., no backward branch exists.
  if (loop_increment_end != NULL) {
    JoinEntryInstr* loop_start =
        new JoinEntryInstr(owner()->AllocateBlockId(), owner()->try_index());
    Goto(loop_start);
    loop_increment_end->Goto(loop_start);
    exit_ = loop_start;
  }

  if (node->condition() == NULL) {
    // Endless loop, no test.
    JoinEntryInstr* body_entry =
        new JoinEntryInstr(owner()->AllocateBlockId(), owner()->try_index());
    AppendFragment(body_entry, for_body);
    Goto(body_entry);
    if (node->label()->join_for_break() != NULL) {
      // Control flow of ForLoop continues into join_for_break.
      exit_ = node->label()->join_for_break();
    }
  } else {
    TestGraphVisitor for_test(owner(),
                              temp_index(),
                              node->condition()->token_pos());
    node->condition()->Visit(&for_test);
    Append(for_test);

    BlockEntryInstr* body_entry = for_test.CreateTrueSuccessor();
    AppendFragment(body_entry, for_body);

    if (node->label()->join_for_break() == NULL) {
      exit_ = for_test.CreateFalseSuccessor();
    } else {
      for_test.IfFalseGoto(node->label()->join_for_break());
      exit_ = node->label()->join_for_break();
    }
  }
}


void EffectGraphVisitor::VisitJumpNode(JumpNode* node) {
  for (intptr_t i = 0; i < node->inlined_finally_list_length(); i++) {
    EffectGraphVisitor for_effect(owner(), temp_index());
    node->InlinedFinallyNodeAt(i)->Visit(&for_effect);
    Append(for_effect);
    if (!is_open()) return;
  }

  // Unchain the context(s) up to the outer context level of the scope which
  // contains the destination label.
  SourceLabel* label = node->label();
  ASSERT(label->owner() != NULL);
  int target_context_level = 0;
  LocalScope* target_scope = label->owner();
  if (target_scope->num_context_variables() > 0) {
    // The scope of the target label allocates a context, therefore its outer
    // scope is at a lower context level.
    target_context_level = target_scope->context_level() - 1;
  } else {
    // The scope of the target label does not allocate a context, so its outer
    // scope is at the same context level. Find it.
    while ((target_scope != NULL) &&
           (target_scope->num_context_variables() == 0)) {
      target_scope = target_scope->parent();
    }
    if (target_scope != NULL) {
      target_context_level = target_scope->context_level();
    }
  }
  ASSERT(target_context_level >= 0);
  intptr_t current_context_level = owner()->context_level();
  ASSERT(current_context_level >= target_context_level);
  while (current_context_level-- > target_context_level) {
    UnchainContext();
  }

  JoinEntryInstr* jump_target = NULL;
  if (node->kind() == Token::kBREAK) {
    if (node->label()->join_for_break() == NULL) {
      node->label()->set_join_for_break(
          new JoinEntryInstr(owner()->AllocateBlockId(), owner()->try_index()));
    }
    jump_target = node->label()->join_for_break();
  } else {
    if (node->label()->join_for_continue() == NULL) {
      node->label()->set_join_for_continue(
          new JoinEntryInstr(owner()->AllocateBlockId(), owner()->try_index()));
    }
    jump_target = node->label()->join_for_continue();
  }
  Goto(jump_target);
}


void EffectGraphVisitor::VisitArgumentListNode(ArgumentListNode* node) {
  UNREACHABLE();
}


void EffectGraphVisitor::VisitArgumentDefinitionTestNode(
    ArgumentDefinitionTestNode* node) {
  InlineBailout("EffectGraphVisitor::VisitArgumentDefinitionTestNode");
  Definition* load = BuildLoadLocal(node->saved_arguments_descriptor());
  Value* arguments_descriptor = Bind(load);
  ArgumentDefinitionTestInstr* arg_def_test =
      new ArgumentDefinitionTestInstr(node, arguments_descriptor);
  ReturnDefinition(arg_def_test);
}


void EffectGraphVisitor::VisitArrayNode(ArrayNode* node) {
  const AbstractTypeArguments& type_args =
      AbstractTypeArguments::ZoneHandle(node->type().arguments());
  Value* element_type = BuildInstantiatedTypeArguments(node->token_pos(),
                                                       type_args);
  CreateArrayInstr* create = new CreateArrayInstr(node->token_pos(),
                                                  node->length(),
                                                  node->type(),
                                                  element_type);
  Value* array_val = Bind(create);
  Definition* store = BuildStoreTemp(node->temp_local(), array_val);
  Do(store);

  const intptr_t class_id = create->Type()->ToCid();
  const intptr_t deopt_id = Isolate::kNoDeoptId;
  for (int i = 0; i < node->length(); ++i) {
    Value* array = Bind(
        new LoadLocalInstr(node->temp_local()));
    Value* index = Bind(new ConstantInstr(Smi::ZoneHandle(Smi::New(i))));
    ValueGraphVisitor for_value(owner(), temp_index());
    node->ElementAt(i)->Visit(&for_value);
    Append(for_value);
    // No store barrier needed for constants.
    const StoreBarrierType emit_store_barrier =
        for_value.value()->BindsToConstant()
            ? kNoStoreBarrier
            : kEmitStoreBarrier;
    intptr_t index_scale = FlowGraphCompiler::ElementSizeFor(class_id);
    StoreIndexedInstr* store = new StoreIndexedInstr(
        array, index, for_value.value(),
        emit_store_barrier, index_scale, class_id, deopt_id);
    Do(store);
  }

  ReturnDefinition(new LoadLocalInstr(node->temp_local()));
}


void EffectGraphVisitor::VisitClosureNode(ClosureNode* node) {
  const Function& function = node->function();

  if (function.IsImplicitStaticClosureFunction()) {
    Instance& closure = Instance::ZoneHandle();
    closure ^= function.implicit_static_closure();
    if (closure.IsNull()) {
      ObjectStore* object_store = Isolate::Current()->object_store();
      const Context& context = Context::Handle(object_store->empty_context());
      closure ^= Closure::New(function, context, Heap::kOld);
      function.set_implicit_static_closure(closure);
    }
    ReturnDefinition(new ConstantInstr(closure));
    return;
  }
  Value* receiver = NULL;
  if (function.IsNonImplicitClosureFunction()) {
    // The context scope may have already been set by the non-optimizing
    // compiler.  If it was not, set it here.
    if (function.context_scope() == ContextScope::null()) {
      // TODO(regis): Why are we not doing this in the parser?
      const ContextScope& context_scope = ContextScope::ZoneHandle(
          node->scope()->PreserveOuterScope(owner()->context_level()));
      ASSERT(!function.HasCode());
      ASSERT(function.context_scope() == ContextScope::null());
      function.set_context_scope(context_scope);
    }
    receiver = BuildNullValue();
  } else {
    ASSERT(function.IsImplicitInstanceClosureFunction());
    ValueGraphVisitor for_receiver(owner(), temp_index());
    node->receiver()->Visit(&for_receiver);
    Append(for_receiver);
    receiver = for_receiver.value();
  }
  PushArgumentInstr* push_receiver = PushArgument(receiver);
  ZoneGrowableArray<PushArgumentInstr*>* arguments =
      new ZoneGrowableArray<PushArgumentInstr*>(2);
  arguments->Add(push_receiver);
  ASSERT(function.context_scope() != ContextScope::null());

  // The function type of a closure may have type arguments. In that case, pass
  // the type arguments of the instantiator. Otherwise, pass null object.
  const Class& cls = Class::Handle(function.signature_class());
  ASSERT(!cls.IsNull());
  const bool requires_type_arguments = cls.HasTypeArguments();
  Value* type_arguments = NULL;
  if (requires_type_arguments) {
    ASSERT(!function.IsImplicitStaticClosureFunction());
    const Class& instantiator_class = Class::Handle(
        owner()->parsed_function().function().Owner());
    type_arguments = BuildInstantiatorTypeArguments(node->token_pos(),
                                                    instantiator_class,
                                                    NULL);
  } else {
    type_arguments = BuildNullValue();
  }
  PushArgumentInstr* push_type_arguments = PushArgument(type_arguments);
  arguments->Add(push_type_arguments);
  ReturnDefinition(
      new CreateClosureInstr(node->function(), arguments, node->token_pos()));
}


void EffectGraphVisitor::TranslateArgumentList(
    const ArgumentListNode& node,
    ZoneGrowableArray<Value*>* values) {
  for (intptr_t i = 0; i < node.length(); ++i) {
    ValueGraphVisitor for_argument(owner(), temp_index());
    node.NodeAt(i)->Visit(&for_argument);
    Append(for_argument);
    values->Add(for_argument.value());
  }
}


void EffectGraphVisitor::BuildPushArguments(
    const ArgumentListNode& node,
    ZoneGrowableArray<PushArgumentInstr*>* values) {
  for (intptr_t i = 0; i < node.length(); ++i) {
    ValueGraphVisitor for_argument(owner(), temp_index());
    node.NodeAt(i)->Visit(&for_argument);
    Append(for_argument);
    PushArgumentInstr* push_arg = PushArgument(for_argument.value());
    values->Add(push_arg);
  }
}


void EffectGraphVisitor::VisitInstanceCallNode(InstanceCallNode* node) {
  ValueGraphVisitor for_receiver(owner(), temp_index());
  node->receiver()->Visit(&for_receiver);
  Append(for_receiver);
  PushArgumentInstr* push_receiver = PushArgument(for_receiver.value());
  ZoneGrowableArray<PushArgumentInstr*>* arguments =
      new ZoneGrowableArray<PushArgumentInstr*>(
          node->arguments()->length() + 1);
  arguments->Add(push_receiver);

  BuildPushArguments(*node->arguments(), arguments);
  InstanceCallInstr* call = new InstanceCallInstr(
      node->token_pos(),
      node->function_name(), Token::kILLEGAL, arguments,
      node->arguments()->names(), 1);
  ReturnDefinition(call);
}


static intptr_t GetResultCidOfNative(const Function& function) {
  const Class& function_class = Class::Handle(function.Owner());
  if (function_class.library() == Library::TypedDataLibrary()) {
    const String& function_name = String::Handle(function.name());
    if (!String::EqualsIgnoringPrivateKey(function_name, Symbols::_New())) {
      return kDynamicCid;
    }
    switch (function_class.id()) {
      case kTypedDataInt8ArrayCid:
      case kTypedDataUint8ArrayCid:
      case kTypedDataUint8ClampedArrayCid:
      case kTypedDataInt16ArrayCid:
      case kTypedDataUint16ArrayCid:
      case kTypedDataInt32ArrayCid:
      case kTypedDataUint32ArrayCid:
      case kTypedDataInt64ArrayCid:
      case kTypedDataUint64ArrayCid:
      case kTypedDataFloat32ArrayCid:
      case kTypedDataFloat64ArrayCid:
      case kTypedDataFloat32x4ArrayCid:
        return function_class.id();
      default:
        return kDynamicCid;  // Unknown.
    }
  }
  return kDynamicCid;
}


// <Expression> ::= StaticCall { function: Function
//                               arguments: <ArgumentList> }
void EffectGraphVisitor::VisitStaticCallNode(StaticCallNode* node) {
  ZoneGrowableArray<PushArgumentInstr*>* arguments =
      new ZoneGrowableArray<PushArgumentInstr*>(node->arguments()->length());
  BuildPushArguments(*node->arguments(), arguments);
  StaticCallInstr* call =
      new StaticCallInstr(node->token_pos(),
                          node->function(),
                          node->arguments()->names(),
                          arguments);
  if (node->function().is_native()) {
    const intptr_t result_cid = GetResultCidOfNative(node->function());
    call->set_result_cid(result_cid);
  }
  ReturnDefinition(call);
}


ClosureCallInstr* EffectGraphVisitor::BuildClosureCall(
    ClosureCallNode* node) {
  ValueGraphVisitor for_closure(owner(), temp_index());
  node->closure()->Visit(&for_closure);
  Append(for_closure);
  PushArgumentInstr* push_closure = PushArgument(for_closure.value());

  ZoneGrowableArray<PushArgumentInstr*>* arguments =
      new ZoneGrowableArray<PushArgumentInstr*>(node->arguments()->length());
  arguments->Add(push_closure);
  BuildPushArguments(*node->arguments(), arguments);

  // Save context around the call.
  ASSERT(owner()->parsed_function().saved_current_context_var() != NULL);
  BuildStoreContext(*owner()->parsed_function().saved_current_context_var());
  return new ClosureCallInstr(node, arguments);
}


void EffectGraphVisitor::VisitClosureCallNode(ClosureCallNode* node) {
  Do(BuildClosureCall(node));
  // Restore context from saved location.
  ASSERT(owner()->parsed_function().saved_current_context_var() != NULL);
  BuildLoadContext(*owner()->parsed_function().saved_current_context_var());
}


void ValueGraphVisitor::VisitClosureCallNode(ClosureCallNode* node) {
  Value* result = Bind(BuildClosureCall(node));
  // Restore context from temp.
  ASSERT(owner()->parsed_function().saved_current_context_var() != NULL);
  BuildLoadContext(*owner()->parsed_function().saved_current_context_var());
  ReturnValue(result);
}


void EffectGraphVisitor::VisitCloneContextNode(CloneContextNode* node) {
  InlineBailout("EffectGraphVisitor::VisitCloneContextNode (context)");
  Value* context = Bind(new CurrentContextInstr());
  Value* clone = Bind(new CloneContextInstr(node->token_pos(), context));
  AddInstruction(new StoreContextInstr(clone));
}


Value* EffectGraphVisitor::BuildObjectAllocation(
    ConstructorCallNode* node) {
  const Class& cls = Class::ZoneHandle(node->constructor().Owner());
  const bool requires_type_arguments = cls.HasTypeArguments();

  // In checked mode, if the type arguments are uninstantiated, they may need to
  // be checked against declared bounds at run time.
  Definition* allocate_comp = NULL;
  if (FLAG_enable_type_checks &&
      requires_type_arguments &&
      !node->type_arguments().IsNull() &&
      !node->type_arguments().IsInstantiated() &&
      node->type_arguments().IsBounded()) {
    Value* type_arguments = NULL;
    Value* instantiator = NULL;
    BuildConstructorTypeArguments(node, &type_arguments, &instantiator, NULL);

    // The uninstantiated type arguments cannot be verified to be within their
    // bounds at compile time, so verify them at runtime.
    allocate_comp = new AllocateObjectWithBoundsCheckInstr(node,
                                                           type_arguments,
                                                           instantiator);
  } else {
    ZoneGrowableArray<PushArgumentInstr*>* allocate_arguments =
        new ZoneGrowableArray<PushArgumentInstr*>();

    if (requires_type_arguments) {
      BuildConstructorTypeArguments(node, NULL, NULL, allocate_arguments);
    }

    allocate_comp = new AllocateObjectInstr(node, allocate_arguments);
  }
  return Bind(allocate_comp);
}


void EffectGraphVisitor::BuildConstructorCall(
    ConstructorCallNode* node,
    PushArgumentInstr* push_alloc_value) {
  Value* ctor_arg = Bind(
      new ConstantInstr(Smi::ZoneHandle(Smi::New(Function::kCtorPhaseAll))));
  PushArgumentInstr* push_ctor_arg = PushArgument(ctor_arg);

  ZoneGrowableArray<PushArgumentInstr*>* arguments =
      new ZoneGrowableArray<PushArgumentInstr*>(2);
  arguments->Add(push_alloc_value);
  arguments->Add(push_ctor_arg);

  BuildPushArguments(*node->arguments(), arguments);
  Do(new StaticCallInstr(node->token_pos(),
                         node->constructor(),
                         node->arguments()->names(),
                         arguments));
}


// Class that recognizes factories and returns corresponding result cid.
class FactoryRecognizer : public AllStatic {
 public:
  // Return kDynamicCid if factory is not recognized.
  static intptr_t ResultCid(const Function& factory) {
    ASSERT(factory.IsFactory());
    const Class& function_class = Class::Handle(factory.Owner());
    const Library& lib = Library::Handle(function_class.library());
    ASSERT((lib.raw() == Library::CoreLibrary()) ||
        (lib.raw() == Library::TypedDataLibrary()));
    const String& factory_name = String::Handle(factory.name());
#define RECOGNIZE_FACTORY(test_factory_symbol, cid, fp)                        \
    if (String::EqualsIgnoringPrivateKey(                                      \
        factory_name, Symbols::test_factory_symbol())) {                       \
      ASSERT(factory.CheckSourceFingerprint(fp));                              \
      return cid;                                                              \
    }                                                                          \

RECOGNIZED_LIST_FACTORY_LIST(RECOGNIZE_FACTORY);
#undef RECOGNIZE_FACTORY

    return kDynamicCid;
  }
};


static intptr_t GetResultCidOfListFactory(ConstructorCallNode* node) {
  const Function& function = node->constructor();
  const Class& function_class = Class::Handle(function.Owner());

  if ((function_class.library() != Library::CoreLibrary()) &&
      (function_class.library() != Library::TypedDataLibrary())) {
    return kDynamicCid;
  }

  if (node->constructor().IsFactory()) {
    if ((function_class.Name() == Symbols::List().raw()) &&
        (function.name() == Symbols::ListFactory().raw())) {
      // Special recognition of 'new List()' vs 'new List(n)'.
      if (node->arguments()->length() == 0) {
        return kGrowableObjectArrayCid;
      }
      return kArrayCid;
    }
    return FactoryRecognizer::ResultCid(function);
  }
  return kDynamicCid;   // Not a known list constructor.
}


void EffectGraphVisitor::VisitConstructorCallNode(ConstructorCallNode* node) {
  if (node->constructor().IsFactory()) {
    ZoneGrowableArray<PushArgumentInstr*>* arguments =
        new ZoneGrowableArray<PushArgumentInstr*>();
    PushArgumentInstr* push_type_arguments = PushArgument(
        BuildInstantiatedTypeArguments(node->token_pos(),
                                       node->type_arguments()));
    arguments->Add(push_type_arguments);
    ASSERT(arguments->length() == 1);
    BuildPushArguments(*node->arguments(), arguments);
    StaticCallInstr* call =
        new StaticCallInstr(node->token_pos(),
                            node->constructor(),
                            node->arguments()->names(),
                            arguments);
    const intptr_t result_cid = GetResultCidOfListFactory(node);
    if (result_cid != kDynamicCid) {
      call->set_result_cid(result_cid);
      call->set_is_known_list_constructor(true);
      // Recognized fixed length array factory must have two arguments:
      // (0) type-arguments, (1) length.
      ASSERT(!LoadFieldInstr::IsFixedLengthArrayCid(result_cid) ||
             arguments->length() == 2);
    }
    ReturnDefinition(call);
    return;
  }
  // t_n contains the allocated and initialized object.
  //   t_n      <- AllocateObject(class)
  //   t_n+1    <- ctor-arg
  //   t_n+2... <- constructor arguments start here
  //   StaticCall(constructor, t_n+1, t_n+2, ...)
  // No need to preserve allocated value (simpler than in ValueGraphVisitor).
  Value* allocated_value = BuildObjectAllocation(node);
  PushArgumentInstr* push_allocated_value = PushArgument(allocated_value);
  BuildConstructorCall(node, push_allocated_value);
}


Value* EffectGraphVisitor::BuildInstantiator() {
  const Class& instantiator_class = Class::Handle(
      owner()->parsed_function().function().Owner());
  if (instantiator_class.NumTypeParameters() == 0) {
    return NULL;
  }
  Function& outer_function =
      Function::Handle(owner()->parsed_function().function().raw());
  while (outer_function.IsLocalFunction()) {
    outer_function = outer_function.parent_function();
  }
  if (outer_function.IsFactory()) {
    return NULL;
  }

  ASSERT(owner()->parsed_function().instantiator() != NULL);
  ValueGraphVisitor for_instantiator(owner(), temp_index());
  owner()->parsed_function().instantiator()->Visit(&for_instantiator);
  Append(for_instantiator);
  return for_instantiator.value();
}


// 'expression_temp_var' may not be used inside this method if 'instantiator'
// is not NULL.
Value* EffectGraphVisitor::BuildInstantiatorTypeArguments(
    intptr_t token_pos,
    const Class& instantiator_class,
    Value* instantiator) {
  if (instantiator_class.NumTypeParameters() == 0) {
    // The type arguments are compile time constants.
    AbstractTypeArguments& type_arguments = AbstractTypeArguments::ZoneHandle();
    // Type is temporary. Only its type arguments are preserved.
    Type& type = Type::Handle(
        Type::New(instantiator_class, type_arguments, token_pos, Heap::kNew));
    type ^= ClassFinalizer::FinalizeType(
        instantiator_class, type, ClassFinalizer::kFinalize);
    ASSERT(!type.IsMalformed());
    type_arguments = type.arguments();
    type_arguments = type_arguments.Canonicalize();
    return Bind(new ConstantInstr(type_arguments));
  }
  Function& outer_function =
      Function::Handle(owner()->parsed_function().function().raw());
  while (outer_function.IsLocalFunction()) {
    outer_function = outer_function.parent_function();
  }
  if (outer_function.IsFactory()) {
    // No instantiator for factories.
    ASSERT(instantiator == NULL);
    ASSERT(owner()->parsed_function().instantiator() != NULL);
    ValueGraphVisitor for_instantiator(owner(), temp_index());
    owner()->parsed_function().instantiator()->Visit(&for_instantiator);
    Append(for_instantiator);
    return for_instantiator.value();
  }
  if (instantiator == NULL) {
    instantiator = BuildInstantiator();
  }
  // The instantiator is the receiver of the caller, which is not a factory.
  // The receiver cannot be null; extract its AbstractTypeArguments object.
  // Note that in the factory case, the instantiator is the first parameter
  // of the factory, i.e. already an AbstractTypeArguments object.
  intptr_t type_arguments_field_offset =
      instantiator_class.type_arguments_field_offset();
  ASSERT(type_arguments_field_offset != Class::kNoTypeArguments);

  return Bind(new LoadFieldInstr(
      instantiator,
      type_arguments_field_offset,
      Type::ZoneHandle()));  // Not an instance, no type.
}


Value* EffectGraphVisitor::BuildInstantiatedTypeArguments(
    intptr_t token_pos,
    const AbstractTypeArguments& type_arguments) {
  if (type_arguments.IsNull() || type_arguments.IsInstantiated()) {
    return Bind(new ConstantInstr(type_arguments));
  }
  // The type arguments are uninstantiated.
  const Class& instantiator_class = Class::ZoneHandle(
      owner()->parsed_function().function().Owner());
  Value* instantiator_value =
      BuildInstantiatorTypeArguments(token_pos, instantiator_class, NULL);
  return Bind(new InstantiateTypeArgumentsInstr(token_pos,
                                                type_arguments,
                                                instantiator_class,
                                                instantiator_value));
}


void EffectGraphVisitor::BuildConstructorTypeArguments(
    ConstructorCallNode* node,
    Value** type_arguments,
    Value** instantiator,
    ZoneGrowableArray<PushArgumentInstr*>* call_arguments) {
  const Class& cls = Class::ZoneHandle(node->constructor().Owner());
  ASSERT(cls.HasTypeArguments() && !node->constructor().IsFactory());
  if (node->type_arguments().IsNull() ||
      node->type_arguments().IsInstantiated()) {
    Value* type_arguments_val = Bind(new ConstantInstr(node->type_arguments()));
    if (call_arguments != NULL) {
      ASSERT(type_arguments == NULL);
      call_arguments->Add(PushArgument(type_arguments_val));
    } else {
      ASSERT(type_arguments != NULL);
      *type_arguments = type_arguments_val;
    }

    // No instantiator required.
    Value* instantiator_val = Bind(new ConstantInstr(
        Smi::ZoneHandle(Smi::New(StubCode::kNoInstantiator))));
    if (call_arguments != NULL) {
      ASSERT(instantiator == NULL);
      call_arguments->Add(PushArgument(instantiator_val));
    } else {
      ASSERT(instantiator != NULL);
      *instantiator = instantiator_val;
    }
    return;
  }
  // The type arguments are uninstantiated. The generated pseudo code:
  //   t1 = InstantiatorTypeArguments();
  //   t2 = ExtractConstructorTypeArguments(t1);
  //   t1 = ExtractConstructorInstantiator(t1);
  //   t_n   <- t2
  //   t_n+1 <- t1
  // Use expression_temp_var and node->allocated_object_var() locals to keep
  // intermediate results around (t1 and t2 above).
  ASSERT(owner()->parsed_function().expression_temp_var() != NULL);
  const LocalVariable& t1 = *owner()->parsed_function().expression_temp_var();
  const LocalVariable& t2 = node->allocated_object_var();
  const Class& instantiator_class = Class::Handle(
      owner()->parsed_function().function().Owner());
  Value* instantiator_type_arguments = BuildInstantiatorTypeArguments(
      node->token_pos(), instantiator_class, NULL);
  Value* stored_instantiator =
      Bind(BuildStoreTemp(t1, instantiator_type_arguments));
  // t1: instantiator type arguments.

  Value* extract_type_arguments = Bind(
      new ExtractConstructorTypeArgumentsInstr(
          node->token_pos(),
          node->type_arguments(),
          instantiator_class,
          stored_instantiator));

  Do(BuildStoreTemp(t2, extract_type_arguments));
  // t2: extracted constructor type arguments.
  Value* load_instantiator = Bind(BuildLoadLocal(t1));

  Value* extract_instantiator =
      Bind(new ExtractConstructorInstantiatorInstr(node,
                                                   instantiator_class,
                                                   load_instantiator));
  Do(BuildStoreTemp(t1, extract_instantiator));
  // t2: extracted constructor type arguments.
  // t1: extracted constructor instantiator.
  Value* type_arguments_val = Bind(BuildLoadLocal(t2));
  if (call_arguments != NULL) {
    ASSERT(type_arguments == NULL);
    call_arguments->Add(PushArgument(type_arguments_val));
  } else {
    ASSERT(type_arguments != NULL);
    *type_arguments = type_arguments_val;
  }

  Value* instantiator_val = Bind(BuildLoadLocal(t1));
  if (call_arguments != NULL) {
    ASSERT(instantiator == NULL);
    call_arguments->Add(PushArgument(instantiator_val));
  } else {
    ASSERT(instantiator != NULL);
    *instantiator = instantiator_val;
  }
}


void ValueGraphVisitor::VisitConstructorCallNode(ConstructorCallNode* node) {
  if (node->constructor().IsFactory()) {
    EffectGraphVisitor::VisitConstructorCallNode(node);
    return;
  }

  // t_n contains the allocated and initialized object.
  //   t_n      <- AllocateObject(class)
  //   t_n      <- StoreLocal(temp, t_n);
  //   t_n+1    <- ctor-arg
  //   t_n+2... <- constructor arguments start here
  //   StaticCall(constructor, t_n, t_n+1, ...)
  //   tn       <- LoadLocal(temp)

  Value* allocate = BuildObjectAllocation(node);
  Value* allocated_value = Bind(BuildStoreTemp(
      node->allocated_object_var(),
      allocate));
  PushArgumentInstr* push_allocated_value = PushArgument(allocated_value);
  BuildConstructorCall(node, push_allocated_value);
  Definition* load_allocated = BuildLoadLocal(
      node->allocated_object_var());
  allocated_value = Bind(load_allocated);
  ReturnValue(allocated_value);
}


void EffectGraphVisitor::VisitInstanceGetterNode(InstanceGetterNode* node) {
  ValueGraphVisitor for_receiver(owner(), temp_index());
  node->receiver()->Visit(&for_receiver);
  Append(for_receiver);
  PushArgumentInstr* push_receiver = PushArgument(for_receiver.value());
  ZoneGrowableArray<PushArgumentInstr*>* arguments =
      new ZoneGrowableArray<PushArgumentInstr*>(1);
  arguments->Add(push_receiver);
  const String& name =
      String::ZoneHandle(Field::GetterSymbol(node->field_name()));
  InstanceCallInstr* call = new InstanceCallInstr(
      node->token_pos(), name, Token::kGET,
      arguments, Array::ZoneHandle(), 1);
  ReturnDefinition(call);
}


void EffectGraphVisitor::BuildInstanceSetterArguments(
    InstanceSetterNode* node,
    ZoneGrowableArray<PushArgumentInstr*>* arguments,
    bool result_is_needed) {
  ValueGraphVisitor for_receiver(owner(), temp_index());
  node->receiver()->Visit(&for_receiver);
  Append(for_receiver);
  arguments->Add(PushArgument(for_receiver.value()));

  ValueGraphVisitor for_value(owner(), temp_index());
  node->value()->Visit(&for_value);
  Append(for_value);

  Value* value = NULL;
  if (result_is_needed) {
    value = Bind(BuildStoreExprTemp(for_value.value()));
  } else {
    value = for_value.value();
  }
  arguments->Add(PushArgument(value));
}


void EffectGraphVisitor::VisitInstanceSetterNode(InstanceSetterNode* node) {
  ZoneGrowableArray<PushArgumentInstr*>* arguments =
      new ZoneGrowableArray<PushArgumentInstr*>(2);
  BuildInstanceSetterArguments(node, arguments, kResultNotNeeded);
  const String& name =
      String::ZoneHandle(Field::SetterSymbol(node->field_name()));
  InstanceCallInstr* call = new InstanceCallInstr(node->token_pos(),
                                                  name,
                                                  Token::kSET,
                                                  arguments,
                                                  Array::ZoneHandle(),
                                                  2);  // Checked arg count.
  ReturnDefinition(call);
}


void ValueGraphVisitor::VisitInstanceSetterNode(InstanceSetterNode* node) {
  ZoneGrowableArray<PushArgumentInstr*>* arguments =
      new ZoneGrowableArray<PushArgumentInstr*>(2);
  BuildInstanceSetterArguments(node, arguments, kResultNeeded);
  const String& name =
      String::ZoneHandle(Field::SetterSymbol(node->field_name()));
  Do(new InstanceCallInstr(node->token_pos(),
                           name,
                           Token::kSET,
                           arguments,
                           Array::ZoneHandle(),
                           2));  // Checked argument count.
  ReturnDefinition(BuildLoadExprTemp());
}


void EffectGraphVisitor::VisitStaticGetterNode(StaticGetterNode* node) {
  const String& getter_name =
      String::ZoneHandle(Field::GetterSymbol(node->field_name()));
  ZoneGrowableArray<PushArgumentInstr*>* arguments =
      new ZoneGrowableArray<PushArgumentInstr*>();
  Function& getter_function = Function::ZoneHandle();
  if (node->is_super_getter()) {
    // Statically resolved instance getter, i.e. "super getter".
    ASSERT(node->receiver() != NULL);
    getter_function = Resolver::ResolveDynamicAnyArgs(node->cls(), getter_name);
    if (getter_function.IsNull()) {
      // Resolve and call noSuchMethod.
      ArgumentListNode* arguments = new ArgumentListNode(node->token_pos());
      arguments->Add(node->receiver());
      StaticCallInstr* call = BuildStaticNoSuchMethodCall(node->cls(),
                                                          node->receiver(),
                                                          getter_name,
                                                          arguments);
      ReturnDefinition(call);
      return;
    } else {
      ValueGraphVisitor receiver_value(owner(), temp_index());
      node->receiver()->Visit(&receiver_value);
      Append(receiver_value);
      arguments->Add(PushArgument(receiver_value.value()));
    }
  } else {
    getter_function = node->cls().LookupStaticFunction(getter_name);
    if (getter_function.IsNull()) {
      // When the parser encounters a reference to a static field materialized
      // only by a static setter, but no corresponding static getter, it creates
      // a StaticGetterNode ast node referring to the non-existing static getter
      // for the case this field reference appears in a left hand side
      // expression (the parser has not distinguished between left and right
      // hand side yet at this stage). If the parser establishes later that the
      // field access is part of a left hand side expression, the
      // StaticGetterNode is transformed into a StaticSetterNode referring to
      // the existing static setter.
      // However, if the field reference appears in a right hand side
      // expression, no such transformation occurs and we land here with a
      // StaticGetterNode missing a getter function, so we throw a
      // NoSuchMethodError.

      // Throw a NoSuchMethodError.
      StaticCallInstr* call = BuildThrowNoSuchMethodError(
          node->token_pos(),
          node->cls(),
          getter_name,
          InvocationMirror::EncodeType(
              node->cls().IsTopLevel() ?
                  InvocationMirror::kTopLevel :
                  InvocationMirror::kStatic,
              InvocationMirror::kGetter));
      ReturnDefinition(call);
      return;
    }
  }
  ASSERT(!getter_function.IsNull());
  StaticCallInstr* call = new StaticCallInstr(node->token_pos(),
                                              getter_function,
                                              Array::ZoneHandle(),  // No names.
                                              arguments);
  ReturnDefinition(call);
}


void EffectGraphVisitor::BuildStaticSetter(StaticSetterNode* node,
                                           bool result_is_needed) {
  const String& setter_name =
      String::ZoneHandle(Field::SetterSymbol(node->field_name()));
  ZoneGrowableArray<PushArgumentInstr*>* arguments =
      new ZoneGrowableArray<PushArgumentInstr*>(1);
  // A super setter is an instance setter whose setter function is
  // resolved at compile time (in the caller instance getter's super class).
  // Unlike a static getter, a super getter has a receiver parameter.
  const bool is_super_setter = (node->receiver() != NULL);
  Function& setter_function =
      Function::ZoneHandle(is_super_setter
          ? Resolver::ResolveDynamicAnyArgs(node->cls(), setter_name)
          : node->cls().LookupStaticFunction(setter_name));
  StaticCallInstr* call;
  if (setter_function.IsNull()) {
    if (is_super_setter) {
      ASSERT(node->receiver() != NULL);
      // Resolve and call noSuchMethod.
      ArgumentListNode* arguments = new ArgumentListNode(node->token_pos());
      arguments->Add(node->receiver());
      arguments->Add(node->value());
      call = BuildStaticNoSuchMethodCall(node->cls(),
                                         node->receiver(),
                                         setter_name,
                                         arguments);
    } else {
      // Throw a NoSuchMethodError.
      call = BuildThrowNoSuchMethodError(
          node->token_pos(),
          node->cls(),
          setter_name,
          InvocationMirror::EncodeType(
            node->cls().IsTopLevel() ?
                InvocationMirror::kTopLevel :
                InvocationMirror::kStatic,
            InvocationMirror::kGetter));
    }
  } else {
    if (is_super_setter) {
      // Add receiver of instance getter.
      ValueGraphVisitor for_receiver(owner(), temp_index());
      node->receiver()->Visit(&for_receiver);
      Append(for_receiver);
      arguments->Add(PushArgument(for_receiver.value()));
    }
    ValueGraphVisitor for_value(owner(), temp_index());
    node->value()->Visit(&for_value);
    Append(for_value);
    Value* value = NULL;
    if (result_is_needed) {
      value = Bind(BuildStoreExprTemp(for_value.value()));
    } else {
      value = for_value.value();
    }
    arguments->Add(PushArgument(value));

    call = new StaticCallInstr(node->token_pos(),
                               setter_function,
                               Array::ZoneHandle(),  // No names.
                               arguments);
  }
  if (result_is_needed) {
    Do(call);
    ReturnDefinition(BuildLoadExprTemp());
  } else {
    ReturnDefinition(call);
  }
}


void EffectGraphVisitor::VisitStaticSetterNode(StaticSetterNode* node) {
  BuildStaticSetter(node, false);  // Result not needed.
}


void ValueGraphVisitor::VisitStaticSetterNode(StaticSetterNode* node) {
  BuildStaticSetter(node, true);  // Result needed.
}


void EffectGraphVisitor::VisitNativeBodyNode(NativeBodyNode* node) {
  InlineBailout("EffectGraphVisitor::VisitNativeBodyNode");
  NativeCallInstr* native_call = new NativeCallInstr(node);
  ReturnDefinition(native_call);
}


void EffectGraphVisitor::VisitPrimaryNode(PrimaryNode* node) {
  // PrimaryNodes are temporary during parsing.
  UNREACHABLE();
}


// <Expression> ::= LoadLocal { local: LocalVariable }
void EffectGraphVisitor::VisitLoadLocalNode(LoadLocalNode* node) {
  if (node->HasPseudo()) {
    EffectGraphVisitor for_pseudo(owner(), temp_index());
    node->pseudo()->Visit(&for_pseudo);
    Append(for_pseudo);
  }
}


void ValueGraphVisitor::VisitLoadLocalNode(LoadLocalNode* node) {
  EffectGraphVisitor::VisitLoadLocalNode(node);
  Definition* load = BuildLoadLocal(node->local());
  ReturnDefinition(load);
}


// <Expression> ::= StoreLocal { local: LocalVariable
//                               value: <Expression> }
void EffectGraphVisitor::HandleStoreLocal(StoreLocalNode* node,
                                          bool result_is_needed) {
  ValueGraphVisitor for_value(owner(), temp_index());
  node->value()->Visit(&for_value);
  Append(for_value);
  Value* store_value = for_value.value();
  if (FLAG_enable_type_checks) {
    store_value = BuildAssignableValue(node->value()->token_pos(),
                                       store_value,
                                       node->local().type(),
                                       node->local().name());
  }
  Definition* store = BuildStoreLocal(node->local(),
                                      store_value,
                                      result_is_needed);
  ReturnDefinition(store);
}


void EffectGraphVisitor::VisitStoreLocalNode(StoreLocalNode* node) {
  HandleStoreLocal(node, kResultNotNeeded);
}


void ValueGraphVisitor::VisitStoreLocalNode(StoreLocalNode* node) {
  HandleStoreLocal(node, kResultNeeded);
}


void EffectGraphVisitor::VisitLoadInstanceFieldNode(
    LoadInstanceFieldNode* node) {
  ValueGraphVisitor for_instance(owner(), temp_index());
  node->instance()->Visit(&for_instance);
  Append(for_instance);
  LoadFieldInstr* load = new LoadFieldInstr(
      for_instance.value(),
      node->field().Offset(),
      AbstractType::ZoneHandle(node->field().type()));
  ReturnDefinition(load);
}


void EffectGraphVisitor::VisitStoreInstanceFieldNode(
    StoreInstanceFieldNode* node) {
  ValueGraphVisitor for_instance(owner(), temp_index());
  node->instance()->Visit(&for_instance);
  Append(for_instance);
  ValueGraphVisitor for_value(owner(), for_instance.temp_index());
  node->value()->Visit(&for_value);
  Append(for_value);
  Value* store_value = for_value.value();
  if (FLAG_enable_type_checks) {
    const AbstractType& type = AbstractType::ZoneHandle(node->field().type());
    const String& dst_name = String::ZoneHandle(node->field().name());
    store_value = BuildAssignableValue(node->value()->token_pos(),
                                       store_value,
                                       type,
                                       dst_name);
  }

  store_value = Bind(BuildStoreExprTemp(store_value));
  GuardFieldInstr* guard =
      new GuardFieldInstr(store_value,
                          node->field(),
                          Isolate::Current()->GetNextDeoptId());
  AddInstruction(guard);

  store_value = Bind(BuildLoadExprTemp());
  StoreInstanceFieldInstr* store =
      new StoreInstanceFieldInstr(node->field(),
                                  for_instance.value(),
                                  store_value,
                                  kEmitStoreBarrier);
  ReturnDefinition(store);
}


// StoreInstanceFieldNode does not return result.
void ValueGraphVisitor::VisitStoreInstanceFieldNode(
    StoreInstanceFieldNode* node) {
  UNIMPLEMENTED();
}


void EffectGraphVisitor::VisitLoadStaticFieldNode(LoadStaticFieldNode* node) {
  LoadStaticFieldInstr* load = new LoadStaticFieldInstr(node->field());
  ReturnDefinition(load);
}


Definition* EffectGraphVisitor::BuildStoreStaticField(
  StoreStaticFieldNode* node, bool result_is_needed) {
  ValueGraphVisitor for_value(owner(), temp_index());
  node->value()->Visit(&for_value);
  Append(for_value);
  Value* store_value = NULL;
  if (result_is_needed) {
    store_value = Bind(BuildStoreExprTemp(for_value.value()));
  } else {
    store_value = for_value.value();
  }
  if (FLAG_enable_type_checks) {
    const AbstractType& type = AbstractType::ZoneHandle(node->field().type());
    const String& dst_name = String::ZoneHandle(node->field().name());
    store_value = BuildAssignableValue(node->value()->token_pos(),
                                       store_value,
                                       type,
                                       dst_name);
  }
  StoreStaticFieldInstr* store =
      new StoreStaticFieldInstr(node->field(), store_value);

  if (result_is_needed) {
    Do(store);
    return BuildLoadExprTemp();
  } else {
    return store;
  }
}


void EffectGraphVisitor::VisitStoreStaticFieldNode(StoreStaticFieldNode* node) {
  ReturnDefinition(BuildStoreStaticField(node, kResultNotNeeded));
}


void ValueGraphVisitor::VisitStoreStaticFieldNode(StoreStaticFieldNode* node) {
  ReturnDefinition(BuildStoreStaticField(node, kResultNeeded));
}


void EffectGraphVisitor::VisitLoadIndexedNode(LoadIndexedNode* node) {
  Function* super_function = NULL;
  if (node->IsSuperLoad()) {
    // Resolve the load indexed operator in the super class.
    super_function = &Function::ZoneHandle(
          Resolver::ResolveDynamicAnyArgs(node->super_class(),
                                          Symbols::IndexToken()));
    if (super_function->IsNull()) {
      // Could not resolve super operator. Generate call noSuchMethod() of the
      // super class instead.
      ArgumentListNode* arguments = new ArgumentListNode(node->token_pos());
      arguments->Add(node->array());
      arguments->Add(node->index_expr());
      StaticCallInstr* call =
          BuildStaticNoSuchMethodCall(node->super_class(),
                                      node->array(),
                                      Symbols::IndexToken(),
                                      arguments);
      ReturnDefinition(call);
      return;
    }
  }
  ZoneGrowableArray<PushArgumentInstr*>* arguments =
      new ZoneGrowableArray<PushArgumentInstr*>(2);
  ValueGraphVisitor for_array(owner(), temp_index());
  node->array()->Visit(&for_array);
  Append(for_array);
  arguments->Add(PushArgument(for_array.value()));

  ValueGraphVisitor for_index(owner(), temp_index());
  node->index_expr()->Visit(&for_index);
  Append(for_index);
  arguments->Add(PushArgument(for_index.value()));

  if (super_function != NULL) {
    // Generate static call to super operator.
    StaticCallInstr* load = new StaticCallInstr(node->token_pos(),
                                                *super_function,
                                                Array::ZoneHandle(),
                                                arguments);
    ReturnDefinition(load);
  } else {
    // Generate dynamic call to index operator.
    const intptr_t checked_argument_count = 1;
    InstanceCallInstr* load = new InstanceCallInstr(node->token_pos(),
                                                    Symbols::IndexToken(),
                                                    Token::kINDEX,
                                                    arguments,
                                                    Array::ZoneHandle(),
                                                    checked_argument_count);
    ReturnDefinition(load);
  }
}


Definition* EffectGraphVisitor::BuildStoreIndexedValues(
    StoreIndexedNode* node,
    bool result_is_needed) {
  Function* super_function = NULL;
  if (node->IsSuperStore()) {
    // Resolve the store indexed operator in the super class.
    super_function = &Function::ZoneHandle(
        Resolver::ResolveDynamicAnyArgs(node->super_class(),
                                        Symbols::AssignIndexToken()));
    if (super_function->IsNull()) {
      // Could not resolve super operator. Generate call noSuchMethod() of the
      // super class instead.
      ArgumentListNode* arguments = new ArgumentListNode(node->token_pos());
      arguments->Add(node->array());
      arguments->Add(node->index_expr());

      // Even though noSuchMethod most likely does not return,
      // we save the stored value if the result is needed.
      if (result_is_needed) {
        ValueGraphVisitor for_value(owner(), temp_index());
        node->value()->Visit(&for_value);
        Append(for_value);
        Do(BuildStoreExprTemp(for_value.value()));

        const LocalVariable* temp =
            owner()->parsed_function().expression_temp_var();
        AstNode* value = new LoadLocalNode(node->token_pos(), temp);
        arguments->Add(value);
      } else {
        arguments->Add(node->value());
      }
      StaticCallInstr* call =
          BuildStaticNoSuchMethodCall(node->super_class(),
                                      node->array(),
                                      Symbols::AssignIndexToken(),
                                      arguments);
      if (result_is_needed) {
        Do(call);
        return BuildLoadExprTemp();
      } else {
        return call;
      }
    }
  }

  ZoneGrowableArray<PushArgumentInstr*>* arguments =
      new ZoneGrowableArray<PushArgumentInstr*>(3);
  ValueGraphVisitor for_array(owner(), temp_index());
  node->array()->Visit(&for_array);
  Append(for_array);
  arguments->Add(PushArgument(for_array.value()));

  ValueGraphVisitor for_index(owner(), temp_index());
  node->index_expr()->Visit(&for_index);
  Append(for_index);
  arguments->Add(PushArgument(for_index.value()));

  ValueGraphVisitor for_value(owner(), temp_index());
  node->value()->Visit(&for_value);
  Append(for_value);
  Value* value = NULL;
  if (result_is_needed) {
    value = Bind(BuildStoreExprTemp(for_value.value()));
  } else {
    value = for_value.value();
  }
  arguments->Add(PushArgument(value));

  if (super_function != NULL) {
    // Generate static call to super operator []=.

    StaticCallInstr* store =
        new StaticCallInstr(node->token_pos(),
                            *super_function,
                            Array::ZoneHandle(),
                            arguments);
    if (result_is_needed) {
      Do(store);
      return BuildLoadExprTemp();
    } else {
      return store;
    }
  } else {
    // Generate dynamic call to operator []=.
    const intptr_t checked_argument_count = 3;
    const String& name =
        String::ZoneHandle(Symbols::New(Token::Str(Token::kASSIGN_INDEX)));
    InstanceCallInstr* store =
        new InstanceCallInstr(node->token_pos(),
                              name,
                              Token::kASSIGN_INDEX,
                              arguments,
                              Array::ZoneHandle(),
                              checked_argument_count);
    if (result_is_needed) {
      Do(store);
      return BuildLoadExprTemp();
    } else {
      return store;
    }
  }
}


void EffectGraphVisitor::VisitStoreIndexedNode(StoreIndexedNode* node) {
  ReturnDefinition(BuildStoreIndexedValues(node, kResultNotNeeded));
}


void ValueGraphVisitor::VisitStoreIndexedNode(StoreIndexedNode* node) {
  ReturnDefinition(BuildStoreIndexedValues(node, kResultNeeded));
}


bool EffectGraphVisitor::MustSaveRestoreContext(SequenceNode* node) const {
  return (node == owner()->parsed_function().node_sequence()) &&
         (owner()->parsed_function().saved_entry_context_var() != NULL);
}


void EffectGraphVisitor::UnchainContext() {
  InlineBailout("EffectGraphVisitor::UnchainContext (context)");
  Value* context = Bind(new CurrentContextInstr());
  Value* parent = Bind(
      new LoadFieldInstr(context,
                         Context::parent_offset(),
                         Type::ZoneHandle()));  // Not an instance, no type.
  AddInstruction(new StoreContextInstr(parent));
}


// <Statement> ::= Sequence { scope: LocalScope
//                            nodes: <Statement>*
//                            label: SourceLabel }
void EffectGraphVisitor::VisitSequenceNode(SequenceNode* node) {
  LocalScope* scope = node->scope();
  const intptr_t num_context_variables =
      (scope != NULL) ? scope->num_context_variables() : 0;
  int previous_context_level = owner()->context_level();
  if (num_context_variables > 0) {
    InlineBailout("EffectGraphVisitor::VisitSequenceNode (context)");
    // The loop local scope declares variables that are captured.
    // Allocate and chain a new context.
    // Allocate context computation (uses current CTX)
    Value* allocated_context =
        Bind(new AllocateContextInstr(node->token_pos(),
                                      num_context_variables));

    // If this node_sequence is the body of the function being compiled, and if
    // this function allocates context variables, but none of its enclosing
    // functions do, the context on entry is not linked as parent of the
    // allocated context but saved on entry and restored on exit as to prevent
    // memory leaks.
    // In this case, the parser pre-allocates a variable to save the context.
    if (MustSaveRestoreContext(node)) {
      Value* current_context = Bind(new CurrentContextInstr());
      Do(BuildStoreTemp(*owner()->parsed_function().saved_entry_context_var(),
                        current_context));
      Value* null_context = Bind(new ConstantInstr(Object::ZoneHandle()));
      AddInstruction(new StoreContextInstr(null_context));
    }

    AddInstruction(new ChainContextInstr(allocated_context));
    owner()->set_context_level(scope->context_level());

    // If this node_sequence is the body of the function being compiled, copy
    // the captured parameters from the frame into the context.
    if (node == owner()->parsed_function().node_sequence()) {
      ASSERT(scope->context_level() == 1);
      const Function& function = owner()->parsed_function().function();
      int num_params = function.NumParameters();
      int param_frame_index = (num_params == function.num_fixed_parameters()) ?
          (kLastParamSlotIndex + num_params - 1) : kFirstLocalSlotIndex;
      // Handle the saved arguments descriptor as an additional parameter.
      if (owner()->parsed_function().GetSavedArgumentsDescriptorVar() != NULL) {
        ASSERT(param_frame_index == kFirstLocalSlotIndex);
        num_params++;
      }
      for (int pos = 0; pos < num_params; param_frame_index--, pos++) {
        const LocalVariable& parameter = *scope->VariableAt(pos);
        ASSERT(parameter.owner() == scope);
        if (parameter.is_captured()) {
          // Create a temporary local describing the original position.
          const String& temp_name = String::ZoneHandle(String::Concat(
              parameter.name(), String::Handle(Symbols::New("-orig"))));
          LocalVariable* temp_local = new LocalVariable(
              0,  // Token index.
              temp_name,
              Type::ZoneHandle(Type::DynamicType()));  // Type.
          temp_local->set_index(param_frame_index);

          // Copy parameter from local frame to current context.
          Value* load = Bind(BuildLoadLocal(*temp_local));
          Do(BuildStoreLocal(parameter, load, kResultNotNeeded));
          // Write NULL to the source location to detect buggy accesses and
          // allow GC of passed value if it gets overwritten by a new value in
          // the function.
          Value* null_constant =
              Bind(new ConstantInstr(Object::ZoneHandle()));
          Do(BuildStoreLocal(*temp_local, null_constant, kResultNotNeeded));
        }
      }
    }
  }

  if (FLAG_enable_type_checks &&
      (node == owner()->parsed_function().node_sequence())) {
    const Function& function = owner()->parsed_function().function();
    const int num_params = function.NumParameters();
    int pos = 0;
    if (function.IsConstructor()) {
      // Skip type checking of receiver and phase for constructor functions.
      pos = 2;
    } else if (function.IsFactory() || function.IsDynamicFunction()) {
      // Skip type checking of type arguments for factory functions.
      // Skip type checking of receiver for instance functions.
      pos = 1;
    }
    while (pos < num_params) {
      const LocalVariable& parameter = *scope->VariableAt(pos);
      ASSERT(parameter.owner() == scope);
      if (!CanSkipTypeCheck(parameter.token_pos(),
                            NULL,
                            parameter.type(),
                            parameter.name())) {
        Value* parameter_value = Bind(BuildLoadLocal(parameter));
        AssertAssignableInstr* assert_assignable =
            BuildAssertAssignable(parameter.token_pos(),
                                  parameter_value,
                                  parameter.type(),
                                  parameter.name());
        parameter_value = Bind(assert_assignable);
        // Store the type checked argument back to its corresponding local
        // variable so that ssa renaming detects the dependency and makes use
        // of the checked type in type propagation.
        Do(BuildStoreLocal(parameter, parameter_value, kResultNotNeeded));
      }
      pos++;
    }
  }

  intptr_t i = 0;
  while (is_open() && (i < node->length())) {
    EffectGraphVisitor for_effect(owner(), temp_index());
    node->NodeAt(i++)->Visit(&for_effect);
    Append(for_effect);
    if (!is_open()) {
      // E.g., because of a JumpNode.
      break;
    }
  }

  if (is_open()) {
    if (MustSaveRestoreContext(node)) {
      ASSERT(num_context_variables > 0);
      BuildLoadContext(*owner()->parsed_function().saved_entry_context_var());
    } else if (num_context_variables > 0) {
      UnchainContext();
    }
  }

  // No continue on sequence allowed.
  ASSERT((node->label() == NULL) ||
         (node->label()->join_for_continue() == NULL));
  // If this node sequence is labeled, a break out of the sequence will have
  // taken care of unchaining the context.
  if ((node->label() != NULL) &&
      (node->label()->join_for_break() != NULL)) {
    if (is_open()) Goto(node->label()->join_for_break());
    exit_ = node->label()->join_for_break();
  }

  // The outermost function sequence cannot contain a label.
  ASSERT((node->label() == NULL) ||
         (node != owner()->parsed_function().node_sequence()));
  owner()->set_context_level(previous_context_level);
}


void EffectGraphVisitor::VisitCatchClauseNode(CatchClauseNode* node) {
  InlineBailout("EffectGraphVisitor::VisitCatchClauseNode (exception)");
  // NOTE: The implicit variables ':saved_context', ':exception_var'
  // and ':stacktrace_var' can never be captured variables.
  // Restores CTX from local variable ':saved_context'.
  AddInstruction(
      new CatchEntryInstr(node->exception_var(), node->stacktrace_var()));
  BuildLoadContext(node->context_var());

  EffectGraphVisitor for_catch(owner(), temp_index());
  node->VisitChildren(&for_catch);
  Append(for_catch);
}


void EffectGraphVisitor::VisitTryCatchNode(TryCatchNode* node) {
  InlineBailout("EffectGraphVisitor::VisitTryCatchNode (exception)");
  intptr_t old_try_index = owner()->try_index();
  intptr_t try_index = owner()->AllocateTryIndex();
  owner()->set_try_index(try_index);

  // Preserve CTX into local variable '%saved_context'.
  BuildStoreContext(node->context_var());

  EffectGraphVisitor for_try_block(owner(), temp_index());
  node->try_block()->Visit(&for_try_block);

  if (for_try_block.is_open()) {
    JoinEntryInstr* after_try =
        new JoinEntryInstr(owner()->AllocateBlockId(), old_try_index);
    for_try_block.Goto(after_try);
    for_try_block.exit_ = after_try;
  }

  JoinEntryInstr* try_entry =
      new JoinEntryInstr(owner()->AllocateBlockId(), try_index);

  Goto(try_entry);
  AppendFragment(try_entry, for_try_block);
  exit_ = for_try_block.exit_;

  // We are done generating code for the try block.
  owner()->set_try_index(old_try_index);

  CatchClauseNode* catch_block = node->catch_block();
  if (catch_block != NULL) {
    // Set the corresponding try index for this catch block so
    // that we can set the appropriate handler pc when we generate
    // code for this catch block.
    catch_block->set_try_index(try_index);
    EffectGraphVisitor for_catch_block(owner(), temp_index());
    catch_block->Visit(&for_catch_block);
    CatchBlockEntryInstr* catch_entry =
        new CatchBlockEntryInstr(owner()->AllocateBlockId(),
                                 old_try_index,
                                 catch_block->handler_types(),
                                 try_index);
    owner()->AddCatchEntry(catch_entry);
    ASSERT(!for_catch_block.is_open());
    AppendFragment(catch_entry, for_catch_block);
    if (node->end_catch_label() != NULL) {
      JoinEntryInstr* join = node->end_catch_label()->join_for_continue();
      if (join != NULL) {
        if (is_open()) Goto(join);
        exit_ = join;
      }
    }
  }

  // Generate code for the finally block if one exists.
  if ((node->finally_block() != NULL) && is_open()) {
    EffectGraphVisitor for_finally_block(owner(), temp_index());
    node->finally_block()->Visit(&for_finally_block);
    Append(for_finally_block);
  }
}


// Looks up dynamic method noSuchMethod in target_class
// (including its super class chain) and builds a static call to it.
StaticCallInstr* EffectGraphVisitor::BuildStaticNoSuchMethodCall(
    const Class& target_class,
    AstNode* receiver,
    const String& method_name,
    ArgumentListNode* method_arguments) {
  // Build the graph to allocate an InvocationMirror object by calling
  // the static allocation method.
  const Library& corelib = Library::Handle(Library::CoreLibrary());
  const Class& mirror_class = Class::Handle(
      corelib.LookupClassAllowPrivate(Symbols::InvocationMirror()));
  ASSERT(!mirror_class.IsNull());
  const Function& allocation_function = Function::ZoneHandle(
      Resolver::ResolveStaticByName(
          mirror_class,
          PrivateCoreLibName(Symbols::AllocateInvocationMirror()),
          Resolver::kIsQualified));
  ASSERT(!allocation_function.IsNull());

  // Evaluate the receiver before the arguments. This will be used
  // as an argument to the noSuchMethod call.
  ValueGraphVisitor for_receiver(owner(), temp_index());
  receiver->Visit(&for_receiver);
  Append(for_receiver);
  PushArgumentInstr* push_receiver = PushArgument(for_receiver.value());

  // Allocate the arguments and pass them into the construction
  // of the InvocationMirror.
  const intptr_t args_pos = method_arguments->token_pos();
  ArgumentListNode* arguments = new ArgumentListNode(args_pos);
  // The first argument is the original method name.
  arguments->Add(new LiteralNode(args_pos, method_name));
  // The second argument is the arguments descriptor of the original method.
  const Array& args_descriptor =
      Array::ZoneHandle(ArgumentsDescriptor::New(method_arguments->length(),
                                                 method_arguments->names()));
  arguments->Add(new LiteralNode(args_pos, args_descriptor));
  // The third argument is an array containing the original method arguments,
  // including the receiver.
  ArrayNode* args_array = new ArrayNode(
      args_pos,
      Type::ZoneHandle(Type::ArrayType()),
      *owner()->parsed_function().array_literal_var());
  for (intptr_t i = 0; i < method_arguments->length(); i++) {
    args_array->AddElement(method_arguments->NodeAt(i));
  }
  arguments->Add(args_array);
  ZoneGrowableArray<PushArgumentInstr*>* allocation_args =
      new ZoneGrowableArray<PushArgumentInstr*>(arguments->length());
  BuildPushArguments(*arguments, allocation_args);
  StaticCallInstr* allocation = new StaticCallInstr(args_pos,
                                                    allocation_function,
                                                    Array::ZoneHandle(),
                                                    allocation_args);
  Value* invocation_mirror = Bind(allocation);
  PushArgumentInstr* push_invocation_mirror = PushArgument(invocation_mirror);
  // Lookup noSuchMethod and call it with the receiver and the InvocationMirror.
  const Function& no_such_method_func = Function::ZoneHandle(
      Resolver::ResolveDynamicAnyArgs(target_class, Symbols::NoSuchMethod()));
  // We are guaranteed to find noSuchMethod of class Object.
  ASSERT(!no_such_method_func.IsNull());
  ZoneGrowableArray<PushArgumentInstr*>* args =
      new ZoneGrowableArray<PushArgumentInstr*>(2);
  args->Add(push_receiver);
  args->Add(push_invocation_mirror);
  return new StaticCallInstr(args_pos,
                             no_such_method_func,
                             Array::ZoneHandle(),
                             args);
}


StaticCallInstr* EffectGraphVisitor::BuildThrowNoSuchMethodError(
    intptr_t token_pos,
    const Class& function_class,
    const String& function_name,
    int invocation_type) {
  ZoneGrowableArray<PushArgumentInstr*>* arguments =
      new ZoneGrowableArray<PushArgumentInstr*>();
  // Object receiver.
  // TODO(regis): For now, we pass a class literal of the unresolved
  // method's owner, but this is not specified and will probably change.
  Type& type = Type::ZoneHandle(
      Type::New(function_class,
                TypeArguments::Handle(),
                token_pos,
                Heap::kOld));
  type ^= ClassFinalizer::FinalizeType(
      function_class, type, ClassFinalizer::kCanonicalize);
  Value* receiver_value = Bind(new ConstantInstr(type));
  arguments->Add(PushArgument(receiver_value));
  // String memberName.
  const String& member_name = String::ZoneHandle(Symbols::New(function_name));
  Value* member_name_value = Bind(new ConstantInstr(member_name));
  arguments->Add(PushArgument(member_name_value));
  // Smi invocation_type.
  Value* invocation_type_value = Bind(new ConstantInstr(
      Smi::ZoneHandle(Smi::New(invocation_type))));
  arguments->Add(PushArgument(invocation_type_value));
  // List arguments.
  // TODO(regis): Pass arguments.
  Value* arguments_value = Bind(new ConstantInstr(Array::ZoneHandle()));
  arguments->Add(PushArgument(arguments_value));
  // List argumentNames.
  Value* argument_names_value =
      Bind(new ConstantInstr(Array::ZoneHandle()));
  arguments->Add(PushArgument(argument_names_value));
  // List existingArgumentNames.
  Value* existing_argument_names_value =
      Bind(new ConstantInstr(Array::ZoneHandle()));
  arguments->Add(PushArgument(existing_argument_names_value));
  // Resolve and call NoSuchMethodError._throwNew.
  const Library& core_lib = Library::Handle(Library::CoreLibrary());
  const Class& cls = Class::Handle(
      core_lib.LookupClass(Symbols::NoSuchMethodError()));
  ASSERT(!cls.IsNull());
  const Function& func = Function::ZoneHandle(
      Resolver::ResolveStatic(cls,
                              PrivateCoreLibName(Symbols::ThrowNew()),
                              arguments->length(),
                              Array::ZoneHandle(),
                              Resolver::kIsQualified));
  ASSERT(!func.IsNull());
  return new StaticCallInstr(token_pos,
                             func,
                             Array::ZoneHandle(),  // No names.
                             arguments);
}


void EffectGraphVisitor::BuildThrowNode(ThrowNode* node) {
  // TODO(kmillikin) non-local control flow is not handled correctly
  // by the inliner.
  InlineBailout("EffectGraphVisitor::BuildThrowNode (exception)");
  ValueGraphVisitor for_exception(owner(), temp_index());
  node->exception()->Visit(&for_exception);
  Append(for_exception);
  PushArgument(for_exception.value());
  Instruction* instr = NULL;
  if (node->stacktrace() == NULL) {
    instr = new ThrowInstr(node->token_pos());
  } else {
    ValueGraphVisitor for_stack_trace(owner(), temp_index());
    node->stacktrace()->Visit(&for_stack_trace);
    Append(for_stack_trace);
    PushArgument(for_stack_trace.value());
    instr = new ReThrowInstr(node->token_pos());
  }
  AddInstruction(instr);
}


void EffectGraphVisitor::VisitThrowNode(ThrowNode* node) {
  BuildThrowNode(node);
  CloseFragment();
}


// A throw cannot be part of an expression, however, the parser may replace
// certain expression nodes with a throw. In that case generate a literal null
// so that the fragment is not closed in the middle of an expression.
void ValueGraphVisitor::VisitThrowNode(ThrowNode* node) {
  BuildThrowNode(node);
  ReturnDefinition(new ConstantInstr(Instance::ZoneHandle()));
}


void EffectGraphVisitor::VisitInlinedFinallyNode(InlinedFinallyNode* node) {
  InlineBailout("EffectGraphVisitor::VisitInlinedFinallyNode (exception)");
  const intptr_t try_index = owner()->try_index();
  if (try_index >= 0) {
    // We are about to generate code for an inlined finally block. Exceptions
    // thrown in this block of code should be treated as though they are
    // thrown not from the current try block but the outer try block if any.
    owner()->set_try_index((try_index - 1));
  }
  BuildLoadContext(node->context_var());

  JoinEntryInstr* finally_entry =
      new JoinEntryInstr(owner()->AllocateBlockId(), owner()->try_index());
  EffectGraphVisitor for_finally_block(owner(), temp_index());
  node->finally_block()->Visit(&for_finally_block);

  if (try_index >= 0) {
    owner()->set_try_index(try_index);
  }

  if (for_finally_block.is_open()) {
    JoinEntryInstr* after_finally =
        new JoinEntryInstr(owner()->AllocateBlockId(), owner()->try_index());
    for_finally_block.Goto(after_finally);
    for_finally_block.exit_ = after_finally;
  }

  Goto(finally_entry);
  AppendFragment(finally_entry, for_finally_block);
  exit_ = for_finally_block.exit_;
}


FlowGraph* FlowGraphBuilder::BuildGraph() {
  if (FLAG_print_ast) {
    // Print the function ast before IL generation.
    AstPrinter::PrintFunctionNodes(parsed_function());
  }
  // Compilation can be nested, preserve the computation-id.
  const Function& function = parsed_function().function();
  TargetEntryInstr* normal_entry =
      new TargetEntryInstr(AllocateBlockId(),
                           CatchClauseNode::kInvalidTryIndex);
  graph_entry_ = new GraphEntryInstr(parsed_function(), normal_entry);
  EffectGraphVisitor for_effect(this, 0);
  // This check may be deleted if the generated code is leaf.
  CheckStackOverflowInstr* check =
      new CheckStackOverflowInstr(function.token_pos());
  // If we are inlining don't actually attach the stack check. We must still
  // create the stack check in order to allocate a deopt id.
  if (!IsInlining()) for_effect.AddInstruction(check);
  parsed_function().node_sequence()->Visit(&for_effect);
  AppendFragment(normal_entry, for_effect);
  // Check that the graph is properly terminated.
  ASSERT(!for_effect.is_open());
  FlowGraph* graph = new FlowGraph(*this, graph_entry_, last_used_block_id_);
  return graph;
}


void FlowGraphBuilder::Bailout(const char* reason) {
  const char* kFormat = "FlowGraphBuilder Bailout: %s %s";
  const char* function_name = parsed_function_.function().ToCString();
  intptr_t len = OS::SNPrint(NULL, 0, kFormat, function_name, reason) + 1;
  char* chars = Isolate::Current()->current_zone()->Alloc<char>(len);
  OS::SNPrint(chars, len, kFormat, function_name, reason);
  const Error& error = Error::Handle(
      LanguageError::New(String::Handle(String::New(chars))));
  Isolate::Current()->long_jump_base()->Jump(1, error);
}


}  // namespace dart
