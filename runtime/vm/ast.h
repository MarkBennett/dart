// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

#ifndef VM_AST_H_
#define VM_AST_H_

#include "platform/assert.h"
#include "vm/allocation.h"
#include "vm/growable_array.h"
#include "vm/scopes.h"
#include "vm/object.h"
#include "vm/native_entry.h"
#include "vm/token.h"

namespace dart {

#define NODE_LIST(V)                                                           \
  V(ReturnNode, "return")                                                      \
  V(LiteralNode, "literal")                                                    \
  V(TypeNode, "type")                                                          \
  V(AssignableNode, "assignable")                                              \
  V(BinaryOpNode, "binop")                                                     \
  V(ComparisonNode, "compare")                                                 \
  V(UnaryOpNode, "unaryop")                                                    \
  V(ConditionalExprNode, "?:")                                                 \
  V(IfNode, "if")                                                              \
  V(SwitchNode, "switch")                                                      \
  V(CaseNode, "case")                                                          \
  V(WhileNode, "while")                                                        \
  V(DoWhileNode, "dowhile")                                                    \
  V(ForNode, "for")                                                            \
  V(JumpNode, "jump")                                                          \
  V(ArgumentListNode, "args")                                                  \
  V(ArgumentDefinitionTestNode, "defined")                                     \
  V(ArrayNode, "array")                                                        \
  V(ClosureNode, "closure")                                                    \
  V(InstanceCallNode, "instance call")                                         \
  V(StaticCallNode, "static call")                                             \
  V(ClosureCallNode, "closure call")                                           \
  V(CloneContextNode, "clone context")                                         \
  V(ConstructorCallNode, "constructor call")                                   \
  V(InstanceGetterNode, "instance getter call")                                \
  V(InstanceSetterNode, "instance setter call")                                \
  V(StaticGetterNode, "static getter")                                         \
  V(StaticSetterNode, "static setter")                                         \
  V(NativeBodyNode, "native body")                                             \
  V(PrimaryNode, "primary")                                                    \
  V(LoadLocalNode, "load local")                                               \
  V(StoreLocalNode, "store local")                                             \
  V(LoadInstanceFieldNode, "load field")                                       \
  V(StoreInstanceFieldNode, "store field")                                     \
  V(LoadStaticFieldNode, "load static field")                                  \
  V(StoreStaticFieldNode, "store static field")                                \
  V(LoadIndexedNode, "load indexed")                                           \
  V(StoreIndexedNode, "store indexed")                                         \
  V(SequenceNode, "seq")                                                       \
  V(CatchClauseNode, "catch clause block")                                     \
  V(TryCatchNode, "try catch block")                                           \
  V(ThrowNode, "throw")                                                        \
  V(InlinedFinallyNode, "inlined finally")                                     \


#define DEFINE_FORWARD_DECLARATION(type, name) class type;
NODE_LIST(DEFINE_FORWARD_DECLARATION)
#undef DEFINE_FORWARD_DECLARATION


// Abstract class to implement an AST node visitor. An example is AstPrinter.
class AstNodeVisitor : public ValueObject {
 public:
  AstNodeVisitor() {}
  virtual ~AstNodeVisitor() {}

#define DEFINE_VISITOR_FUNCTION(type, name)                                    \
  virtual void Visit##type(type* node) { }
NODE_LIST(DEFINE_VISITOR_FUNCTION)
#undef DEFINE_VISITOR_FUNCTION

 private:
  DISALLOW_COPY_AND_ASSIGN(AstNodeVisitor);
};


#define DECLARE_COMMON_NODE_FUNCTIONS(type)                                    \
  virtual void Visit(AstNodeVisitor* visitor);                                 \
  virtual const char* ShortName() const;                                       \
  virtual bool Is##type() const { return true; }                               \
  virtual type* As##type() { return this; }


class AstNode : public ZoneAllocated {
 public:
  explicit AstNode(intptr_t token_pos)
      : token_pos_(token_pos) {
    ASSERT(token_pos_ >= 0);
  }

  intptr_t token_pos() const { return token_pos_; }

#define AST_TYPE_CHECK(type, name)                                             \
  virtual bool Is##type() const { return false; }                              \
  virtual type* As##type() { return NULL; }
NODE_LIST(AST_TYPE_CHECK)
#undef AST_TYPE_CHECK

  virtual void Visit(AstNodeVisitor* visitor) = 0;
  virtual void VisitChildren(AstNodeVisitor* visitor) const = 0;
  virtual const char* ShortName() const = 0;

  // 'ShortName' is predefined for each AstNode and is the default
  // implementation of "Name()". Each AST node can override the function
  // "Name" to do more complex name composition.
  virtual const char* Name() const {
    return ShortName();
  }

  // Convert the node into an assignment node using the rhs which is passed in,
  // this is typically used for converting nodes like LoadLocalNode,
  // LoadStaticFieldNode, InstanceGetterNode etc. which were created during
  // parsing as the assignment context was not known yet at that time.
  virtual AstNode* MakeAssignmentNode(AstNode* rhs) {
    return NULL;  // By default all nodes are not assignable.
  }

  // Return NULL if 'unary_op_kind' can't be applied.
  virtual AstNode* ApplyUnaryOp(Token::Kind unary_op_kind) {
    return NULL;
  }

  // Analyzes an expression to determine whether it is a compile time
  // constant or not. Returns NULL if the expression is not a compile time
  // constant. Otherwise, the return value is an approximation of the
  // actual value of the const expression. The type of the returned value
  // corresponds to the type of the const expression and is either
  // Number, Integer, String, Bool, or anything else (not a subtype of
  // the former).
  virtual const Instance* EvalConstExpr() const { return NULL; }

 protected:
  friend class ParsedFunction;

 private:
  const intptr_t token_pos_;
  DISALLOW_COPY_AND_ASSIGN(AstNode);
};


class SequenceNode : public AstNode {
 public:
  SequenceNode(intptr_t token_pos, LocalScope* scope)
    : AstNode(token_pos),
      scope_(scope),
      nodes_(4),
      label_(NULL) {
  }

  LocalScope* scope() const { return scope_; }

  SourceLabel* label() const { return label_; }
  void set_label(SourceLabel* value) { label_ = value; }

  void VisitChildren(AstNodeVisitor* visitor) const;

  void Add(AstNode* node) { nodes_.Add(node); }
  intptr_t length() const { return nodes_.length(); }
  AstNode* NodeAt(intptr_t index) const { return nodes_[index]; }

  DECLARE_COMMON_NODE_FUNCTIONS(SequenceNode);

  // Collects all nodes accessible from this sequence node into array 'nodes'.
  void CollectAllNodes(GrowableArray<AstNode*>* nodes);

 private:
  LocalScope* scope_;
  GrowableArray<AstNode*> nodes_;
  SourceLabel* label_;

  DISALLOW_COPY_AND_ASSIGN(SequenceNode);
};


class CloneContextNode : public AstNode {
 public:
  explicit CloneContextNode(intptr_t token_pos)
    : AstNode(token_pos) {
  }

  virtual void VisitChildren(AstNodeVisitor* visitor) const { }

  DECLARE_COMMON_NODE_FUNCTIONS(CloneContextNode);

 private:
  DISALLOW_COPY_AND_ASSIGN(CloneContextNode);
};


class ArgumentListNode : public AstNode {
 public:
  explicit ArgumentListNode(intptr_t token_pos)
     : AstNode(token_pos),
       nodes_(4),
       names_(Array::ZoneHandle()) {
  }

  void VisitChildren(AstNodeVisitor* visitor) const;

  void Add(AstNode* node) {
    nodes_.Add(node);
  }
  intptr_t length() const { return nodes_.length(); }
  AstNode* NodeAt(intptr_t index) const { return nodes_[index]; }
  void SetNodeAt(intptr_t index, AstNode* node) { nodes_[index] = node; }
  const Array& names() const {
    return names_;
  }
  void set_names(const Array& names) {
    names_ = names.raw();
  }

  DECLARE_COMMON_NODE_FUNCTIONS(ArgumentListNode);

 private:
  GrowableArray<AstNode*> nodes_;
  Array& names_;

  DISALLOW_COPY_AND_ASSIGN(ArgumentListNode);
};


class ArgumentDefinitionTestNode : public AstNode {
 public:
  ArgumentDefinitionTestNode(intptr_t token_pos,
                             intptr_t formal_parameter_index,
                             const String& formal_parameter_name,
                             LocalVariable* saved_arguments_descriptor)
     : AstNode(token_pos),
       formal_parameter_index_(formal_parameter_index),
       formal_parameter_name_(formal_parameter_name),
       saved_arguments_descriptor_(*saved_arguments_descriptor) {
    ASSERT(formal_parameter_index_ >= 0);
    ASSERT(formal_parameter_name_.IsZoneHandle());
    ASSERT(formal_parameter_name_.IsSymbol());
    ASSERT(saved_arguments_descriptor != NULL);
  }

  virtual void VisitChildren(AstNodeVisitor* visitor) const { }

  intptr_t formal_parameter_index() const { return formal_parameter_index_; }
  const String& formal_parameter_name() const { return formal_parameter_name_; }
  const LocalVariable& saved_arguments_descriptor() const {
    return saved_arguments_descriptor_;
  }

  DECLARE_COMMON_NODE_FUNCTIONS(ArgumentDefinitionTestNode);

 private:
  const intptr_t formal_parameter_index_;
  const String& formal_parameter_name_;
  const LocalVariable& saved_arguments_descriptor_;

  DISALLOW_COPY_AND_ASSIGN(ArgumentDefinitionTestNode);
};


class ArrayNode : public AstNode {
 public:
  ArrayNode(intptr_t token_pos,
            const AbstractType& type,
            const LocalVariable& temp)
      : AstNode(token_pos),
        type_(type),
        temp_local_(temp),
        elements_() {
    CheckFields();
  }
  ArrayNode(intptr_t token_pos,
            const AbstractType& type,
            const LocalVariable& temp,
            const GrowableArray<AstNode*>& elements)
      : AstNode(token_pos),
        type_(type),
        temp_local_(temp),
        elements_(elements.length()) {
    CheckFields();
    for (intptr_t i = 0; i < elements.length(); i++) {
      elements_.Add(elements[i]);
    }
  }

  void VisitChildren(AstNodeVisitor* visitor) const;

  intptr_t length() const { return elements_.length(); }

  AstNode* ElementAt(intptr_t index) const { return elements_[index]; }
  void SetElementAt(intptr_t index, AstNode* value) {
    elements_[index] = value;
  }
  void AddElement(AstNode* expr) { elements_.Add(expr); }

  const AbstractType& type() const { return type_; }

  const LocalVariable& temp_local() const { return temp_local_; }

  DECLARE_COMMON_NODE_FUNCTIONS(ArrayNode);

 private:
  const AbstractType& type_;
  const LocalVariable& temp_local_;  // Store allocated array while filling it.
  GrowableArray<AstNode*> elements_;

  void CheckFields() {
    ASSERT(type_.IsZoneHandle());
    ASSERT(!type_.IsNull());
    ASSERT(type_.IsFinalized());
    // Type may be uninstantiated when creating a generic list literal.
    ASSERT((type_.arguments() == AbstractTypeArguments::null()) ||
           ((AbstractTypeArguments::Handle(type_.arguments()).Length() == 1)));
  }

  DISALLOW_IMPLICIT_CONSTRUCTORS(ArrayNode);
};


class LiteralNode : public AstNode {
 public:
  LiteralNode(intptr_t token_pos, const Instance& literal)
      : AstNode(token_pos), literal_(literal) {
    ASSERT(literal_.IsNotTemporaryScopedHandle());
    ASSERT(literal_.IsSmi() || literal_.IsOld());
#if defined(DEBUG)
    if (literal_.IsString()) {
      ASSERT(String::Cast(literal_).IsSymbol());
    }
#endif  // defined(DEBUG)
    ASSERT(literal_.IsNull() ||
           Class::Handle(literal_.clazz()).is_finalized() ||
           Class::Handle(literal_.clazz()).is_prefinalized());
  }

  const Instance& literal() const { return literal_; }

  virtual const Instance* EvalConstExpr() const {
    return &literal();
  }

  virtual void VisitChildren(AstNodeVisitor* visitor) const { }

  virtual AstNode* ApplyUnaryOp(Token::Kind unary_op_kind);

  DECLARE_COMMON_NODE_FUNCTIONS(LiteralNode);

 private:
  const Instance& literal_;

  DISALLOW_IMPLICIT_CONSTRUCTORS(LiteralNode);
};


class TypeNode : public AstNode {
 public:
  TypeNode(intptr_t token_pos, const AbstractType& type)
      : AstNode(token_pos), type_(type) {
    ASSERT(type_.IsZoneHandle());
    ASSERT(!type_.IsNull());
    ASSERT(type_.IsFinalized());
  }

  const AbstractType& type() const { return type_; }

  virtual const Instance* EvalConstExpr() const {
    if (!type_.IsInstantiated() || type_.IsMalformed()) {
      return NULL;
    }
    return &type();
  }

  virtual void VisitChildren(AstNodeVisitor* visitor) const { }

  DECLARE_COMMON_NODE_FUNCTIONS(TypeNode);

 private:
  const AbstractType& type_;

  DISALLOW_IMPLICIT_CONSTRUCTORS(TypeNode);
};


class AssignableNode : public AstNode {
 public:
  AssignableNode(intptr_t token_pos,
                 AstNode* expr,
                 const AbstractType& type,
                 const String& dst_name)
      : AstNode(token_pos), expr_(expr), type_(type), dst_name_(dst_name) {
    ASSERT(expr_ != NULL);
    ASSERT(type_.IsZoneHandle());
    ASSERT(!type_.IsNull());
    ASSERT(type_.IsFinalized());
    ASSERT(dst_name_.IsNotTemporaryScopedHandle());
  }

  AstNode* expr() const { return expr_; }
  const AbstractType& type() const { return type_; }
  const String& dst_name() const { return dst_name_; }

  virtual void VisitChildren(AstNodeVisitor* visitor) const {
    expr()->Visit(visitor);
  }

  DECLARE_COMMON_NODE_FUNCTIONS(AssignableNode);

 private:
  AstNode* expr_;
  const AbstractType& type_;
  const String& dst_name_;

  DISALLOW_IMPLICIT_CONSTRUCTORS(AssignableNode);
};


class ClosureNode : public AstNode {
 public:
  ClosureNode(intptr_t token_pos,
              const Function& function,
              AstNode* receiver,  // Non-null for implicit instance closures.
              LocalScope* scope)  // Null for implicit closures.
      : AstNode(token_pos),
        function_(function),
        receiver_(receiver),
        scope_(scope) {
    ASSERT(function_.IsZoneHandle());
    ASSERT((function_.IsNonImplicitClosureFunction() &&
            (receiver_ == NULL) && (scope_ != NULL)) ||
           (function_.IsImplicitInstanceClosureFunction() &&
            (receiver_ != NULL) && (scope_ == NULL)) ||
           (function_.IsImplicitStaticClosureFunction() &&
            (receiver_ == NULL) && (scope_ == NULL)));
  }

  const Function& function() const { return function_; }
  AstNode* receiver() const { return receiver_; }
  LocalScope* scope() const { return scope_; }

  virtual void VisitChildren(AstNodeVisitor* visitor) const {
    if (receiver() != NULL) {
      receiver()->Visit(visitor);
    }
  }

  virtual AstNode* MakeAssignmentNode(AstNode* rhs);

  virtual const Instance* EvalConstExpr() const;

  DECLARE_COMMON_NODE_FUNCTIONS(ClosureNode);

 private:
  const Function& function_;
  AstNode* receiver_;
  LocalScope* scope_;

  DISALLOW_IMPLICIT_CONSTRUCTORS(ClosureNode);
};


// Primary nodes hold identifiers or values (library, class or function)
// resolved from an identifier. Primary nodes should not ever make it to the
// code generation phase as they will be transformed into the correct call or
// field access nodes.
class PrimaryNode : public AstNode {
 public:
  PrimaryNode(intptr_t token_pos, const Object& primary)
      : AstNode(token_pos), primary_(primary) {
    ASSERT(primary_.IsNotTemporaryScopedHandle());
  }

  const Object& primary() const { return primary_; }

  bool IsSuper() const {
    return primary().IsString() && (primary().raw() == Symbols::Super().raw());
  }

  virtual void VisitChildren(AstNodeVisitor* visitor) const;

  DECLARE_COMMON_NODE_FUNCTIONS(PrimaryNode);

 private:
  const Object& primary_;

  DISALLOW_IMPLICIT_CONSTRUCTORS(PrimaryNode);
};


class ReturnNode : public AstNode {
 public:
  // Return from a void function returns the null object.
  explicit ReturnNode(intptr_t token_pos)
      : AstNode(token_pos),
        value_(new LiteralNode(token_pos, Instance::ZoneHandle())),
        inlined_finally_list_() { }
  // Return from a non-void function.
  ReturnNode(intptr_t token_pos,
             AstNode* value)
      : AstNode(token_pos), value_(value), inlined_finally_list_() {
    ASSERT(value_ != NULL);
  }

  AstNode* value() const { return value_; }

  intptr_t inlined_finally_list_length() const {
    return inlined_finally_list_.length();
  }
  InlinedFinallyNode* InlinedFinallyNodeAt(intptr_t index) const {
    return inlined_finally_list_[index];
  }
  void AddInlinedFinallyNode(InlinedFinallyNode* finally_node) {
    inlined_finally_list_.Add(finally_node);
  }

  virtual void VisitChildren(AstNodeVisitor* visitor) const {
    if (value() != NULL) {
      value()->Visit(visitor);
    }
  }

  DECLARE_COMMON_NODE_FUNCTIONS(ReturnNode);

 private:
  AstNode* value_;
  GrowableArray<InlinedFinallyNode*> inlined_finally_list_;

  DISALLOW_COPY_AND_ASSIGN(ReturnNode);
};


class ComparisonNode : public AstNode {
 public:
  ComparisonNode(intptr_t token_pos,
                 Token::Kind kind,
                 AstNode* left,
                 AstNode* right)
  : AstNode(token_pos), kind_(kind), left_(left), right_(right) {
    ASSERT(left_ != NULL);
    ASSERT(right_ != NULL);
    ASSERT(IsKindValid());
  }

  Token::Kind kind() const { return kind_; }
  AstNode* left() const { return left_; }
  AstNode* right() const { return right_; }

  virtual void VisitChildren(AstNodeVisitor* visitor) const {
    left()->Visit(visitor);
    right()->Visit(visitor);
  }

  virtual const char* Name() const;
  virtual const Instance* EvalConstExpr() const;

  DECLARE_COMMON_NODE_FUNCTIONS(ComparisonNode);

 private:
  const Token::Kind kind_;
  AstNode* left_;
  AstNode* right_;

  bool IsKindValid() const;

  DISALLOW_IMPLICIT_CONSTRUCTORS(ComparisonNode);
};


class BinaryOpNode : public AstNode {
 public:
  BinaryOpNode(intptr_t token_pos,
               Token::Kind kind,
               AstNode* left,
               AstNode* right)
      : AstNode(token_pos), kind_(kind), left_(left), right_(right) {
    ASSERT(left_ != NULL);
    ASSERT(right_ != NULL);
    ASSERT(IsKindValid());
  }

  Token::Kind kind() const { return kind_; }
  AstNode* left() const { return left_; }
  AstNode* right() const { return right_; }

  virtual void VisitChildren(AstNodeVisitor* visitor) const {
    left()->Visit(visitor);
    right()->Visit(visitor);
  }

  virtual const char* Name() const;
  virtual const Instance* EvalConstExpr() const;

  DECLARE_COMMON_NODE_FUNCTIONS(BinaryOpNode);

 private:
  const Token::Kind kind_;
  AstNode* left_;
  AstNode* right_;

  bool IsKindValid() const;

  DISALLOW_IMPLICIT_CONSTRUCTORS(BinaryOpNode);
};


class UnaryOpNode : public AstNode {
 public:
  // Returns optimized version, e.g., for ('-' '1') ('-1') literal is returned.
  static AstNode* UnaryOpOrLiteral(intptr_t token_pos,
                                   Token::Kind kind,
                                   AstNode* operand);
  UnaryOpNode(intptr_t token_pos,
              Token::Kind kind,
              AstNode* operand)
      : AstNode(token_pos), kind_(kind), operand_(operand) {
    ASSERT(operand_ != NULL);
    ASSERT(IsKindValid());
  }

  Token::Kind kind() const { return kind_; }
  AstNode* operand() const { return operand_; }

  virtual void VisitChildren(AstNodeVisitor* visitor) const {
    operand()->Visit(visitor);
  }

  virtual const char* Name() const;
  virtual const Instance* EvalConstExpr() const;

  DECLARE_COMMON_NODE_FUNCTIONS(UnaryOpNode);

 private:
  const Token::Kind kind_;
  AstNode* operand_;

  bool IsKindValid() const;

  DISALLOW_IMPLICIT_CONSTRUCTORS(UnaryOpNode);
};


class ConditionalExprNode : public AstNode {
 public:
  ConditionalExprNode(intptr_t token_pos,
                      AstNode* condition,
                      AstNode* true_expr,
                      AstNode* false_expr)
      : AstNode(token_pos),
        condition_(condition),
        true_expr_(true_expr),
        false_expr_(false_expr) {
      ASSERT(condition_ != NULL);
      ASSERT(true_expr_ != NULL);
      ASSERT(false_expr_ != NULL);
  }

  AstNode* condition() const { return condition_; }
  AstNode* true_expr() const { return true_expr_; }
  AstNode* false_expr() const { return false_expr_; }

  void set_true_expr(AstNode* true_expr) {
    ASSERT(true_expr != NULL);
    true_expr_ = true_expr;
  }
  void set_false_expr(AstNode* false_expr) {
    ASSERT(false_expr != NULL);
    false_expr_ = false_expr;
  }

  virtual void VisitChildren(AstNodeVisitor* visitor) const {
    condition()->Visit(visitor);
    true_expr()->Visit(visitor);
    false_expr()->Visit(visitor);
  }

  DECLARE_COMMON_NODE_FUNCTIONS(ConditionalExprNode);

 private:
  AstNode* condition_;
  AstNode* true_expr_;
  AstNode* false_expr_;

  DISALLOW_IMPLICIT_CONSTRUCTORS(ConditionalExprNode);
};


class IfNode : public AstNode {
 public:
  IfNode(intptr_t token_pos,
         AstNode* condition,
         SequenceNode* true_branch,
         SequenceNode* false_branch)
      : AstNode(token_pos),
        condition_(condition),
        true_branch_(true_branch),
        false_branch_(false_branch) {
      ASSERT(condition_ != NULL);
  }

  AstNode* condition() const { return condition_; }
  SequenceNode* true_branch() const { return true_branch_; }
  SequenceNode* false_branch() const { return false_branch_; }

  virtual void VisitChildren(AstNodeVisitor* visitor) const {
    condition()->Visit(visitor);
    true_branch()->Visit(visitor);
    if (false_branch() != NULL) {
      false_branch()->Visit(visitor);
    }
  }

  DECLARE_COMMON_NODE_FUNCTIONS(IfNode);

 private:
  AstNode* condition_;
  SequenceNode* true_branch_;
  SequenceNode* false_branch_;

  DISALLOW_IMPLICIT_CONSTRUCTORS(IfNode);
};


class CaseNode : public AstNode {
 public:
  CaseNode(intptr_t token_pos,
           SourceLabel* label,
           SequenceNode* case_expressions,
           bool contains_default,
           LocalVariable* switch_expr_value,
           SequenceNode* statements)
    : AstNode(token_pos),
      label_(label),
      case_expressions_(case_expressions),
      contains_default_(contains_default),
      switch_expr_value_(switch_expr_value),
      statements_(statements) {
    // label may be NULL.
    ASSERT(case_expressions_ != NULL);
    ASSERT(switch_expr_value_ != NULL);
    ASSERT(statements_ != NULL);
  }

  SourceLabel* label() const { return label_; }
  SequenceNode* case_expressions() const { return case_expressions_; }
  bool contains_default() const { return contains_default_; }
  LocalVariable* switch_expr_value() const { return switch_expr_value_; }
  SequenceNode* statements() const { return statements_; }

  virtual void VisitChildren(AstNodeVisitor* visitor) const {
    case_expressions()->Visit(visitor);
    statements()->Visit(visitor);
  }

  DECLARE_COMMON_NODE_FUNCTIONS(CaseNode);

 private:
  SourceLabel* label_;
  SequenceNode* case_expressions_;
  bool contains_default_;
  LocalVariable* switch_expr_value_;
  SequenceNode* statements_;

  DISALLOW_IMPLICIT_CONSTRUCTORS(CaseNode);
};


class SwitchNode : public AstNode {
 public:
  SwitchNode(intptr_t token_pos,
             SourceLabel* label,
             SequenceNode* body)
    : AstNode(token_pos),
      label_(label),
      body_(body) {
    ASSERT(label_ != NULL);
    ASSERT(body_ != NULL);
  }

  SourceLabel* label() const { return label_; }
  AstNode* body() const { return body_; }

  virtual void VisitChildren(AstNodeVisitor* visitor) const {
    body()->Visit(visitor);
  }

  DECLARE_COMMON_NODE_FUNCTIONS(SwitchNode);

 private:
  SourceLabel* label_;
  AstNode* body_;

  DISALLOW_IMPLICIT_CONSTRUCTORS(SwitchNode);
};


class WhileNode : public AstNode {
 public:
  WhileNode(intptr_t token_pos,
            SourceLabel* label,
            AstNode* condition,
            SequenceNode* body)
    : AstNode(token_pos),
      label_(label),
      condition_(condition),
      body_(body) {
    ASSERT(label_ != NULL);
    ASSERT(condition_ != NULL);
    ASSERT(body_ != NULL);
  }

  SourceLabel* label() const { return label_; }
  AstNode* condition() const { return condition_; }
  SequenceNode* body() const { return body_; }

  virtual void VisitChildren(AstNodeVisitor* visitor) const {
    condition()->Visit(visitor);
    body()->Visit(visitor);
  }

  DECLARE_COMMON_NODE_FUNCTIONS(WhileNode);

 private:
  SourceLabel* label_;
  AstNode* condition_;
  SequenceNode* body_;

  DISALLOW_IMPLICIT_CONSTRUCTORS(WhileNode);
};


class DoWhileNode : public AstNode {
 public:
  DoWhileNode(intptr_t token_pos,
              SourceLabel* label,
              AstNode* condition,
              SequenceNode* body)
    : AstNode(token_pos),
      label_(label),
      condition_(condition),
      body_(body) {
    ASSERT(label_ != NULL);
    ASSERT(condition_ != NULL);
    ASSERT(body_ != NULL);
  }

  SourceLabel* label() const { return label_; }
  AstNode* condition() const { return condition_; }
  SequenceNode* body() const { return body_; }

  virtual void VisitChildren(AstNodeVisitor* visitor) const {
    body()->Visit(visitor);
    condition()->Visit(visitor);
  }

  DECLARE_COMMON_NODE_FUNCTIONS(DoWhileNode);

 private:
  SourceLabel* label_;
  AstNode* condition_;
  SequenceNode* body_;

  DISALLOW_IMPLICIT_CONSTRUCTORS(DoWhileNode);
};


// initializer, condition, increment expressions can be NULL.
class ForNode : public AstNode {
 public:
  ForNode(intptr_t token_pos,
          SourceLabel* label,
          SequenceNode* initializer,
          AstNode* condition,
          SequenceNode* increment,
          SequenceNode* body)
    : AstNode(token_pos),
      label_(label),
      initializer_(initializer),
      condition_(condition),
      increment_(increment),
      body_(body) {
    ASSERT(label_ != NULL);
    ASSERT(initializer_ != NULL);
    ASSERT(increment_ != NULL);
    ASSERT(body_ != NULL);
  }

  SourceLabel* label() const { return label_; }
  SequenceNode* initializer() const { return initializer_; }
  AstNode* condition() const { return condition_; }
  SequenceNode* increment() const { return increment_; }
  SequenceNode* body() const { return body_; }

  virtual void VisitChildren(AstNodeVisitor* visitor) const {
    initializer()->Visit(visitor);
    if (condition() != NULL) {
      condition()->Visit(visitor);
    }
    increment()->Visit(visitor);
    body()->Visit(visitor);
  }

  DECLARE_COMMON_NODE_FUNCTIONS(ForNode);

 private:
  SourceLabel* label_;
  SequenceNode* initializer_;
  AstNode* condition_;
  SequenceNode* increment_;
  SequenceNode* body_;

  DISALLOW_IMPLICIT_CONSTRUCTORS(ForNode);
};


class JumpNode : public AstNode {
 public:
  JumpNode(intptr_t token_pos,
           Token::Kind kind,
           SourceLabel* label)
    : AstNode(token_pos),
      kind_(kind),
      label_(label),
      inlined_finally_list_() {
    ASSERT(label_ != NULL);
    ASSERT(kind_ == Token::kBREAK || kind_ == Token::kCONTINUE);
    if (kind_ == Token::kCONTINUE) {
      label_->set_is_continue_target(true);
    }
  }

  SourceLabel* label() const { return label_; }
  Token::Kind kind() const { return kind_; }

  intptr_t inlined_finally_list_length() const {
    return inlined_finally_list_.length();
  }
  InlinedFinallyNode* InlinedFinallyNodeAt(intptr_t index) const {
    return inlined_finally_list_[index];
  }
  void AddInlinedFinallyNode(InlinedFinallyNode* finally_node) {
    inlined_finally_list_.Add(finally_node);
  }

  virtual const char* Name() const;

  virtual void VisitChildren(AstNodeVisitor* visitor) const { }

  DECLARE_COMMON_NODE_FUNCTIONS(JumpNode);

 private:
  Token::Kind kind_;
  SourceLabel* label_;
  GrowableArray<InlinedFinallyNode*> inlined_finally_list_;
  DISALLOW_IMPLICIT_CONSTRUCTORS(JumpNode);
};


class LoadLocalNode : public AstNode {
 public:
  LoadLocalNode(intptr_t token_pos, const LocalVariable* local)
      : AstNode(token_pos), local_(*local), pseudo_(NULL) {
    ASSERT(local != NULL);
  }

  // A local variable load can optionally be a pair of an arbitrary 'pseudo'
  // AST node followed by the load.  The pseudo node is evaluated for its
  // side-effects and the value of the expression is the value of the local
  // load after evaluating the pseudo node.  Pseudo nodes are used, e.g., in
  // the desugaring of postincrement and cascade expressions.
  LoadLocalNode(intptr_t token_pos, const LocalVariable* local, AstNode* pseudo)
      : AstNode(token_pos), local_(*local), pseudo_(pseudo) {
    ASSERT(local != NULL);
  }

  const LocalVariable& local() const { return local_; }
  AstNode* pseudo() const { return pseudo_; }  // Can be NULL.
  bool HasPseudo() const { return pseudo_ != NULL; }

  virtual void VisitChildren(AstNodeVisitor* visitor) const {
    if (HasPseudo()) {
      pseudo()->Visit(visitor);
    }
  }

  virtual const Instance* EvalConstExpr() const;
  virtual AstNode* MakeAssignmentNode(AstNode* rhs);

  DECLARE_COMMON_NODE_FUNCTIONS(LoadLocalNode);

 private:
  const LocalVariable& local_;
  AstNode* pseudo_;

  DISALLOW_IMPLICIT_CONSTRUCTORS(LoadLocalNode);
};


class StoreLocalNode : public AstNode {
 public:
  StoreLocalNode(intptr_t token_pos, const LocalVariable* local, AstNode* value)
      : AstNode(token_pos),  local_(*local), value_(value) {
    ASSERT(local != NULL);
    ASSERT(value_ != NULL);
  }

  const LocalVariable& local() const { return local_; }
  AstNode* value() const { return value_; }

  virtual void VisitChildren(AstNodeVisitor* visitor) const {
    value()->Visit(visitor);
  }

  DECLARE_COMMON_NODE_FUNCTIONS(StoreLocalNode);

 private:
  const LocalVariable& local_;
  AstNode* value_;

  DISALLOW_IMPLICIT_CONSTRUCTORS(StoreLocalNode);
};



class LoadInstanceFieldNode : public AstNode {
 public:
  LoadInstanceFieldNode(intptr_t token_pos,
                        AstNode* instance,
                        const Field& field)
      : AstNode(token_pos), instance_(instance), field_(field) {
    ASSERT(instance_ != NULL);
    ASSERT(field_.IsZoneHandle());
  }

  AstNode* instance() const { return instance_; }
  const Field& field() const { return field_; }

  virtual void VisitChildren(AstNodeVisitor* visitor) const {
    instance()->Visit(visitor);
  }

  DECLARE_COMMON_NODE_FUNCTIONS(LoadInstanceFieldNode);

 private:
  AstNode* instance_;
  const Field& field_;

  DISALLOW_IMPLICIT_CONSTRUCTORS(LoadInstanceFieldNode);
};


class StoreInstanceFieldNode : public AstNode {
 public:
  StoreInstanceFieldNode(intptr_t token_pos,
                         AstNode* instance,
                         const Field& field,
                         AstNode* value)
      : AstNode(token_pos),
        instance_(instance),
        field_(field),
        value_(value) {
    ASSERT(instance_ != NULL);
    ASSERT(field_.IsZoneHandle());
    ASSERT(value_ != NULL);
  }

  AstNode* instance() const { return instance_; }
  const Field& field() const { return field_; }
  AstNode* value() const { return value_; }

  virtual void VisitChildren(AstNodeVisitor* visitor) const {
    instance()->Visit(visitor);
    value()->Visit(visitor);
  }

  DECLARE_COMMON_NODE_FUNCTIONS(StoreInstanceFieldNode);

 private:
  AstNode* instance_;
  const Field& field_;
  AstNode* value_;

  DISALLOW_IMPLICIT_CONSTRUCTORS(StoreInstanceFieldNode);
};


class LoadStaticFieldNode : public AstNode {
 public:
  LoadStaticFieldNode(intptr_t token_pos, const Field& field)
      : AstNode(token_pos), field_(field) {
    ASSERT(field_.IsZoneHandle());
  }

  const Field& field() const { return field_; }

  virtual void VisitChildren(AstNodeVisitor* visitor) const { }

  virtual AstNode* MakeAssignmentNode(AstNode* rhs);

  virtual const Instance* EvalConstExpr() const {
    ASSERT(field_.is_static());
    return field_.is_const() ? &Instance::ZoneHandle(field_.value()) : NULL;
  }

  DECLARE_COMMON_NODE_FUNCTIONS(LoadStaticFieldNode);

 private:
  const Field& field_;

  DISALLOW_IMPLICIT_CONSTRUCTORS(LoadStaticFieldNode);
};


class StoreStaticFieldNode : public AstNode {
 public:
  StoreStaticFieldNode(intptr_t token_pos, const Field& field, AstNode* value)
      : AstNode(token_pos), field_(field), value_(value) {
    ASSERT(field_.IsZoneHandle());
    ASSERT(value_ != NULL);
  }

  const Field& field() const { return field_; }
  AstNode* value() const { return value_; }

  virtual void VisitChildren(AstNodeVisitor* visitor) const {
    value()->Visit(visitor);
  }

  DECLARE_COMMON_NODE_FUNCTIONS(StoreStaticFieldNode);

 private:
  const Field& field_;
  AstNode* value_;

  DISALLOW_IMPLICIT_CONSTRUCTORS(StoreStaticFieldNode);
};


class LoadIndexedNode : public AstNode {
 public:
  LoadIndexedNode(intptr_t token_pos,
                  AstNode* array,
                  AstNode* index,
                  const Class& super_class)
      : AstNode(token_pos),
        array_(array),
        index_expr_(index),
        super_class_(super_class) {
    ASSERT(array_ != NULL);
    ASSERT(index_expr_ != NULL);
    ASSERT(super_class_.IsZoneHandle());
  }

  AstNode* array() const { return array_; }
  AstNode* index_expr() const { return index_expr_; }
  const Class& super_class() const { return super_class_; }
  bool IsSuperLoad() const { return !super_class_.IsNull(); }

  virtual void VisitChildren(AstNodeVisitor* visitor) const {
    array()->Visit(visitor);
    index_expr()->Visit(visitor);
  }

  virtual AstNode* MakeAssignmentNode(AstNode* rhs);

  DECLARE_COMMON_NODE_FUNCTIONS(LoadIndexedNode);

 private:
  AstNode* array_;
  AstNode* index_expr_;
  const Class& super_class_;
  DISALLOW_IMPLICIT_CONSTRUCTORS(LoadIndexedNode);
};


class StoreIndexedNode : public AstNode {
 public:
  StoreIndexedNode(intptr_t token_pos,
                   AstNode* array,
                   AstNode* index,
                   AstNode* value,
                   const Class& super_class)
    : AstNode(token_pos),
      array_(array),
      index_expr_(index),
      value_(value),
      super_class_(super_class) {
    ASSERT(array_ != NULL);
    ASSERT(index_expr_ != NULL);
    ASSERT(value_ != NULL);
    ASSERT(super_class_.IsZoneHandle());
  }

  AstNode* array() const { return array_; }
  AstNode* index_expr() const { return index_expr_; }
  AstNode* value() const { return value_; }
  const Class& super_class() const { return super_class_; }
  bool IsSuperStore() const { return !super_class_.IsNull(); }

  virtual void VisitChildren(AstNodeVisitor* visitor) const {
    array()->Visit(visitor);
    index_expr()->Visit(visitor);
    value()->Visit(visitor);
  }

  DECLARE_COMMON_NODE_FUNCTIONS(StoreIndexedNode);

 private:
  AstNode* array_;
  AstNode* index_expr_;
  AstNode* value_;
  const Class& super_class_;
  DISALLOW_IMPLICIT_CONSTRUCTORS(StoreIndexedNode);
};


class InstanceCallNode : public AstNode {
 public:
  InstanceCallNode(intptr_t token_pos,
                   AstNode* receiver,
                   const String& function_name,
                   ArgumentListNode* arguments)
      : AstNode(token_pos),
        receiver_(receiver),
        function_name_(function_name),
        arguments_(arguments) {
    ASSERT(receiver_ != NULL);
    ASSERT(function_name_.IsNotTemporaryScopedHandle());
    ASSERT(function_name_.IsSymbol());
    ASSERT(arguments_ != NULL);
  }

  AstNode* receiver() const { return receiver_; }
  const String& function_name() const { return function_name_; }
  ArgumentListNode* arguments() const { return arguments_; }

  virtual void VisitChildren(AstNodeVisitor* visitor) const {
    receiver()->Visit(visitor);
    arguments()->Visit(visitor);
  }

  DECLARE_COMMON_NODE_FUNCTIONS(InstanceCallNode);

 private:
  AstNode* receiver_;
  const String& function_name_;
  ArgumentListNode* arguments_;

  DISALLOW_IMPLICIT_CONSTRUCTORS(InstanceCallNode);
};


class InstanceGetterNode : public AstNode {
 public:
  InstanceGetterNode(intptr_t token_pos,
                     AstNode* receiver,
                     const String& field_name)
      : AstNode(token_pos),
        receiver_(receiver),
        field_name_(field_name) {
    ASSERT(receiver_ != NULL);
    ASSERT(field_name_.IsNotTemporaryScopedHandle());
    ASSERT(field_name_.IsSymbol());
  }

  AstNode* receiver() const { return receiver_; }
  const String& field_name() const { return field_name_; }

  virtual void VisitChildren(AstNodeVisitor* visitor) const {
    receiver()->Visit(visitor);
  }

  virtual AstNode* MakeAssignmentNode(AstNode* rhs);

  DECLARE_COMMON_NODE_FUNCTIONS(InstanceGetterNode);

 private:
  AstNode* receiver_;
  const String& field_name_;

  DISALLOW_IMPLICIT_CONSTRUCTORS(InstanceGetterNode);
};


class InstanceSetterNode : public AstNode {
 public:
  InstanceSetterNode(intptr_t token_pos,
                     AstNode* receiver,
                     const String& field_name,
                     AstNode* value)
      : AstNode(token_pos),
        receiver_(receiver),
        field_name_(field_name),
        value_(value) {
    ASSERT(receiver_ != NULL);
    ASSERT(value_ != NULL);
    ASSERT(field_name_.IsZoneHandle());
    ASSERT(field_name_.IsSymbol());
  }

  AstNode* receiver() const { return receiver_; }
  const String& field_name() const { return field_name_; }
  AstNode* value() const { return value_; }

  virtual void VisitChildren(AstNodeVisitor* visitor) const {
    receiver()->Visit(visitor);
    value()->Visit(visitor);
  }

  DECLARE_COMMON_NODE_FUNCTIONS(InstanceSetterNode);

 private:
  AstNode* receiver_;
  const String& field_name_;
  AstNode* value_;

  DISALLOW_IMPLICIT_CONSTRUCTORS(InstanceSetterNode);
};


class StaticGetterNode : public AstNode {
 public:
  StaticGetterNode(intptr_t token_pos,
                   AstNode* receiver,
                   bool is_super_getter,
                   const Class& cls,
                   const String& field_name)
      : AstNode(token_pos),
        receiver_(receiver),
        cls_(cls),
        field_name_(field_name),
        is_super_getter_(is_super_getter) {
    ASSERT(cls_.IsZoneHandle());
    ASSERT(field_name_.IsZoneHandle());
    ASSERT(field_name_.IsSymbol());
  }

  // The receiver is required
  // 1) for a super getter (an instance method that is resolved at compile
  //    time rather than at runtime).
  // 2) when transforming this StaticGetterNode issued in a non-static
  //    context to an InstanceSetterNode. This may occurs when we find a
  //    static getter, but no field and no static setter are declared.
  AstNode* receiver() const { return receiver_; }
  const Class& cls() const { return cls_; }
  const String& field_name() const { return field_name_; }
  bool is_super_getter() const { return is_super_getter_; }

  virtual void VisitChildren(AstNodeVisitor* visitor) const { }

  virtual AstNode* MakeAssignmentNode(AstNode* rhs);

  virtual const Instance* EvalConstExpr() const;

  DECLARE_COMMON_NODE_FUNCTIONS(StaticGetterNode);

 private:
  AstNode* receiver_;
  const Class& cls_;
  const String& field_name_;
  const bool is_super_getter_;

  DISALLOW_IMPLICIT_CONSTRUCTORS(StaticGetterNode);
};


class StaticSetterNode : public AstNode {
 public:
  StaticSetterNode(intptr_t token_pos,
                   AstNode* receiver,
                   const Class& cls,
                   const String& field_name,
                   AstNode* value)
      : AstNode(token_pos),
        receiver_(receiver),
        cls_(cls),
        field_name_(field_name),
        value_(value) {
    ASSERT(cls_.IsZoneHandle());
    ASSERT(field_name_.IsZoneHandle());
    ASSERT(value_ != NULL);
  }

  // The receiver is required for a super setter (an instance method
  // that is resolved at compile time rather than at runtime).
  AstNode* receiver() const { return receiver_; }
  const Class& cls() const { return cls_; }
  const String& field_name() const { return field_name_; }
  AstNode* value() const { return value_; }

  virtual void VisitChildren(AstNodeVisitor* visitor) const {
    value()->Visit(visitor);
  }

  DECLARE_COMMON_NODE_FUNCTIONS(StaticSetterNode);

 private:
  AstNode* receiver_;
  const Class& cls_;
  const String& field_name_;
  AstNode* value_;

  DISALLOW_IMPLICIT_CONSTRUCTORS(StaticSetterNode);
};


class StaticCallNode : public AstNode {
 public:
  StaticCallNode(intptr_t token_pos,
                 const Function& function,
                 ArgumentListNode* arguments)
      : AstNode(token_pos),
        function_(function),
        arguments_(arguments) {
    ASSERT(function_.IsZoneHandle());
    ASSERT(arguments_ != NULL);
  }

  const Function& function() const { return function_; }
  ArgumentListNode* arguments() const { return arguments_; }

  virtual void VisitChildren(AstNodeVisitor* visitor) const {
    arguments()->Visit(visitor);
  }

  virtual AstNode* MakeAssignmentNode(AstNode* rhs);

  DECLARE_COMMON_NODE_FUNCTIONS(StaticCallNode);

 private:
  const Function& function_;
  ArgumentListNode* arguments_;

  DISALLOW_IMPLICIT_CONSTRUCTORS(StaticCallNode);
};


class ClosureCallNode : public AstNode {
 public:
  ClosureCallNode(intptr_t token_pos,
                  AstNode* closure,
                  ArgumentListNode* arguments)
      : AstNode(token_pos),
        closure_(closure),
        arguments_(arguments) {
    ASSERT(closure_ != NULL);
    ASSERT(arguments_ != NULL);
  }

  AstNode* closure() const { return closure_; }
  ArgumentListNode* arguments() const { return arguments_; }

  virtual void VisitChildren(AstNodeVisitor* visitor) const {
    closure()->Visit(visitor);
    arguments()->Visit(visitor);
  }

  DECLARE_COMMON_NODE_FUNCTIONS(ClosureCallNode);

 private:
  AstNode* closure_;
  ArgumentListNode* arguments_;

  DISALLOW_IMPLICIT_CONSTRUCTORS(ClosureCallNode);
};


// There are two kinds of constructor calls: factory calls and constructor
// calls, distinguishable by constructor.IsFactory().
//
// Constructor calls implicitly allocate an object of class constructor.owner(),
// possibly parameterized by type_arguments, which may still be uninstantiated.
// For example, if the type argument T in 'new A<T>()' is not known at compile
// time, it needs to be instantiated at run time. The instantiator and its
// instantiator_class are used to instantiate uninstantiated type arguments
// at run time, as explained below.
//
// Factory calls do not implicitly allocate an object, but receive an implicit
// type argument vector as first parameter, which may still be uninstantiated.
// As in constructor calls, the instantiator and its instantiator_class are used
// to instantiate uninstantiated type arguments at run time.
//
// If the caller to the constructor or to the factory is an instance function,
// the instantiator is the receiver of this function. In order to instantiate T
// in the example above (which could for example be the first type parameter of
// the class of the caller), the code at run time extracts the type arguments of
// the receiver at an offset in the receiver specified by the provided
// instantiator_class.
//
// If the caller to the constructor or to the factory is a factory, then the
// instantiator is the first parameter of this factory, which is already a
// type argument vector. This case is identified by a null and unneeded
// instantiator_class.
//
// A temporary local is needed to hold the allocated value while the
// constructor is being called.
class ConstructorCallNode : public AstNode {
 public:
  ConstructorCallNode(intptr_t token_pos,
                      const AbstractTypeArguments& type_arguments,
                      const Function& constructor,
                      ArgumentListNode* arguments,
                      const LocalVariable* allocated_object_var)
      : AstNode(token_pos),
        type_arguments_(type_arguments),
        constructor_(constructor),
        arguments_(arguments),
        allocated_object_var_(*allocated_object_var) {
    ASSERT(type_arguments_.IsZoneHandle());
    ASSERT(constructor_.IsZoneHandle());
    ASSERT(arguments_ != NULL);
    ASSERT(allocated_object_var != NULL);
  }

  const AbstractTypeArguments& type_arguments() const {
    return type_arguments_;
  }
  const Function& constructor() const { return constructor_; }
  ArgumentListNode* arguments() const { return arguments_; }
  const LocalVariable& allocated_object_var() const {
    return allocated_object_var_;
  }

  virtual void VisitChildren(AstNodeVisitor* visitor) const {
    arguments()->Visit(visitor);
  }

  DECLARE_COMMON_NODE_FUNCTIONS(ConstructorCallNode);

 private:
  const AbstractTypeArguments& type_arguments_;
  const Function& constructor_;
  ArgumentListNode* arguments_;
  const LocalVariable& allocated_object_var_;

  DISALLOW_IMPLICIT_CONSTRUCTORS(ConstructorCallNode);
};


// The body of a Dart function marked as 'native' consists of this node.
class NativeBodyNode : public AstNode {
 public:
  NativeBodyNode(intptr_t token_pos,
                 const Function& function,
                 const String& native_c_function_name,
                 NativeFunction native_c_function)
      : AstNode(token_pos),
        function_(function),
        native_c_function_name_(native_c_function_name),
        native_c_function_(native_c_function) {
    ASSERT(function_.IsZoneHandle());
    ASSERT(native_c_function_ != NULL);
    ASSERT(native_c_function_name_.IsZoneHandle());
    ASSERT(native_c_function_name_.IsSymbol());
  }

  const Function& function() const { return function_; }
  const String& native_c_function_name() const {
    return native_c_function_name_;
  }
  NativeFunction native_c_function() const { return native_c_function_; }

  virtual void VisitChildren(AstNodeVisitor* visitor) const { }

  DECLARE_COMMON_NODE_FUNCTIONS(NativeBodyNode);

 private:
  const Function& function_;  // Native Dart function.
  const String& native_c_function_name_;
  NativeFunction native_c_function_;  // Actual non-Dart implementation.

  DISALLOW_IMPLICIT_CONSTRUCTORS(NativeBodyNode);
};


class CatchClauseNode : public AstNode {
 public:
  static const int kInvalidTryIndex = -1;

  CatchClauseNode(intptr_t token_pos,
                  SequenceNode* catch_block,
                  const Array& handler_types,
                  const LocalVariable* context_var,
                  const LocalVariable* exception_var,
                  const LocalVariable* stacktrace_var)
      : AstNode(token_pos),
        try_index_(kInvalidTryIndex),
        catch_block_(catch_block),
        handler_types_(handler_types),
        context_var_(*context_var),
        exception_var_(*exception_var),
        stacktrace_var_(*stacktrace_var) {
    ASSERT(catch_block_ != NULL);
    ASSERT(handler_types.IsZoneHandle());
    ASSERT(context_var != NULL);
    ASSERT(exception_var != NULL);
    ASSERT(stacktrace_var != NULL);
  }

  int try_index() const {
    ASSERT(try_index_ >= 0);
    return try_index_;
  }
  void set_try_index(int value) { try_index_ = value; }

  const Array& handler_types() const { return handler_types_; }
  const LocalVariable& context_var() const { return context_var_; }
  const LocalVariable& exception_var() const { return exception_var_; }
  const LocalVariable& stacktrace_var() const { return stacktrace_var_; }

  virtual void VisitChildren(AstNodeVisitor* visitor) const {
    catch_block_->Visit(visitor);
  }

  DECLARE_COMMON_NODE_FUNCTIONS(CatchClauseNode);

 private:
  int try_index_;  // Running index of the try blocks seen in a function.
  SequenceNode* catch_block_;
  const Array& handler_types_;
  const LocalVariable& context_var_;
  const LocalVariable& exception_var_;
  const LocalVariable& stacktrace_var_;

  DISALLOW_COPY_AND_ASSIGN(CatchClauseNode);
};


class TryCatchNode : public AstNode {
 public:
  TryCatchNode(intptr_t token_pos,
               SequenceNode* try_block,
               SourceLabel* end_catch_label,
               const LocalVariable* context_var,
               CatchClauseNode* catch_block,
               SequenceNode* finally_block)
      : AstNode(token_pos),
        try_block_(try_block),
        end_catch_label_(end_catch_label),
        context_var_(*context_var),
        catch_block_(catch_block),
        finally_block_(finally_block) {
    ASSERT(try_block_ != NULL);
    ASSERT(context_var != NULL);
    ASSERT(catch_block_ != NULL || finally_block_ != NULL);
    ASSERT(end_catch_label_ != NULL);
  }

  SequenceNode* try_block() const { return try_block_; }
  SourceLabel* end_catch_label() const { return end_catch_label_; }
  CatchClauseNode* catch_block() const { return catch_block_; }
  SequenceNode* finally_block() const { return finally_block_; }
  const LocalVariable& context_var() const { return context_var_; }

  virtual void VisitChildren(AstNodeVisitor* visitor) const {
    try_block_->Visit(visitor);
    if (catch_block_ != NULL) {
      catch_block_->Visit(visitor);
    }
    if (finally_block_ != NULL) {
      finally_block_->Visit(visitor);
    }
  }

  DECLARE_COMMON_NODE_FUNCTIONS(TryCatchNode);

 private:
  SequenceNode* try_block_;
  SourceLabel* end_catch_label_;
  const LocalVariable& context_var_;
  CatchClauseNode* catch_block_;
  SequenceNode* finally_block_;

  DISALLOW_COPY_AND_ASSIGN(TryCatchNode);
};


class ThrowNode : public AstNode {
 public:
  ThrowNode(intptr_t token_pos, AstNode* exception, AstNode* stacktrace)
      : AstNode(token_pos), exception_(exception), stacktrace_(stacktrace) {
    ASSERT(exception_ != NULL);
  }

  AstNode* exception() const { return exception_; }
  AstNode* stacktrace() const { return stacktrace_; }

  virtual void VisitChildren(AstNodeVisitor* visitor) const {
    exception()->Visit(visitor);
    if (stacktrace() != NULL) {
      stacktrace()->Visit(visitor);
    }
  }

  DECLARE_COMMON_NODE_FUNCTIONS(ThrowNode);

 private:
  AstNode* exception_;
  AstNode* stacktrace_;

  DISALLOW_IMPLICIT_CONSTRUCTORS(ThrowNode);
};


class InlinedFinallyNode : public AstNode {
 public:
  InlinedFinallyNode(intptr_t token_pos,
                     AstNode* finally_block,
                     const LocalVariable* context_var)
      : AstNode(token_pos),
        finally_block_(finally_block),
        context_var_(*context_var) {
    ASSERT(finally_block_ != NULL);
    ASSERT(context_var != NULL);
  }

  AstNode* finally_block() const { return finally_block_; }
  const LocalVariable& context_var() const { return context_var_; }

  virtual void VisitChildren(AstNodeVisitor* visitor) const {
    finally_block()->Visit(visitor);
  }

  DECLARE_COMMON_NODE_FUNCTIONS(InlinedFinallyNode);

 private:
  AstNode* finally_block_;
  const LocalVariable& context_var_;

  DISALLOW_IMPLICIT_CONSTRUCTORS(InlinedFinallyNode);
};

}  // namespace dart

#undef DECLARE_COMMON_NODE_FUNCTIONS

#endif  // VM_AST_H_
