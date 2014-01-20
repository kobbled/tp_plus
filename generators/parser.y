class TPPlus::Parser
token ASSIGN AT_SYM COMMENT JUMP IO_METHOD INPUT OUTPUT
token NUMREG POSREG VREG SREG POSITION TIME_SEGMENT ARG
token MOVE DOT TO AT TERM OFFSET SKIP
token SEMICOLON NEWLINE STRING
token REAL DIGIT WORD EQUAL
token EEQUAL NOTEQUAL GTE LTE LT GT BANG
token PLUS MINUS STAR SLASH DIV AND OR MOD
token IF ELSE END UNLESS
token WAIT_FOR WAIT_UNTIL TIMEOUT AFTER
token FANUC_USE FANUC_SET NAMESPACE
token CASE WHEN POSITION POSITION_REGISTER

prechigh
#  left DOT
  right BANG
  left STAR SLASH
  left PLUS MINUS
  left GT GTE LT LTE
  left EEQUAL NOTEQUAL
  left AND
  left OR
  right EQUAL
#  left DOT
preclow

rule
  program
    : /* nothing */
    | statements                       { @interpreter.nodes = val[0].flatten }
    ;

  statements
    : statement                        { result = val }
    | statements terminator statement  { result = val[0] << val[1] << val[2] }
      # to ignore trailing line breaks
    | statements terminator            { result = val[0] << val[1] }
    # this adds a couple conflicts
    | terminator statements            { result = [val[0]] << val[1] }
    | terminator                       { result = [val[0]] }
    ;

  block
    | statements                       { result = val[0] }
    ;

  statement
    #: comment                          { result = val[0] }
    : definition
    | namespace
    | assignment
    | motion_statement
    | jump
    | io_method
    | label_definition
    | conditional
    | inline_conditional
    | program_call
    | use_statement
    | set_statement
    | wait_statement
    | case_statement
    ;

  wait_statement
    : WAIT_FOR '(' indirectable ',' STRING ')'
                                       { result = WaitForNode.new(val[2], val[4]) }
    | WAIT_UNTIL '(' expression ')' wait_modifiers
                                       { result = WaitUntilNode.new(val[2],val[4]) }
    ;

  wait_modifiers
    :
    | wait_modifier                    { result = val[0] }
    | wait_modifiers wait_modifier     { result = val[0].merge(val[1]) }
    ;

  wait_modifier
    : DOT swallow_newlines TIMEOUT '(' label ')'
                                       { result = { label: val[4] } }
    | DOT swallow_newlines AFTER '(' indirectable ',' STRING ')'
                                       { result = { timeout: [val[4],val[6]] } }
    ;

  label
    : AT_SYM WORD                      { result = val[1] }
    ;

  use_statement
    : FANUC_USE indirectable           { result = UseNode.new(val[0],val[1]) }
    ;

  set_statement
    : FANUC_SET indirectable ',' var
                                       { result = SetNode.new(val[0],val[1],val[3]) }
    # this introduces 2 conflicts somehow
    | FANUC_SET expression             { result = SetNode.new(val[0],nil,val[1]) }
    ;

  program_call
    : WORD '(' args ')'                { result = CallNode.new(val[0],val[2]) }
    ;

  args
    : arg                              { result = [val[0]] }
    | args ',' arg                     { result = val[0] << val[2] }
    |                                  { result = [] }
    ;

  arg
    : number
    | var
    ;

  io_method
    : IO_METHOD var                    { result = IOMethodNode.new(val[0],val[1]) }
    ;

  jump
    : JUMP label                       { result = JumpNode.new(val[1]) }
    ;

  conditional
    : IF expression block else_block END
                                       { result = ConditionalNode.new("if",val[1],val[2],val[3]) }
    | UNLESS expression block else_block END
                                       { result = ConditionalNode.new("unless",val[1],val[2],val[3]) }
    ;

  namespace
    : NAMESPACE WORD block END         { result = NamespaceNode.new(val[1],val[2]) }
    ;

  case_statement
    : CASE var swallow_newlines
        case_conditions
        case_else
      END                               { result = CaseNode.new(val[1],val[3],val[4]) }
    ;

  case_conditions
    : case_condition                    { result = val }
    | case_conditions case_condition
                                        { result = val[0] << val[1] << val[2] }
    ;

  case_condition
    : WHEN case_allowed_condition swallow_newlines case_allowed_statement
        terminator                      { result = CaseConditionNode.new(val[1],val[3]) }
    ;

  case_allowed_condition
    : number
    | var
    ;

  case_else
    : ELSE swallow_newlines case_allowed_statement terminator
                                        { result = CaseConditionNode.new(nil,val[2]) }
    |
    ;

  case_allowed_statement
    : program_call
    | jump
    ;

  inline_conditional
    : inlineable IF expression          { result = InlineConditionalNode.new("if",val[2],val[0]) }
    | inlineable UNLESS expression      { result = InlineConditionalNode.new("unless",val[2],val[0]) }
    ;

  inlineable
    : jump
    | assignment
    | io_method
    | program_call
    ;

  else_block
    : ELSE block                       { result = val[1] }
    |                                  { result = [] }
    ;

  motion_statement
    : MOVE DOT swallow_newlines TO '(' var ')' motion_modifiers
                                       { result = MotionNode.new(val[0],val[5],val[7]) }
    ;

  motion_modifiers
    : motion_modifier                  { result = val }
    | motion_modifiers motion_modifier
                                       { result = val[0] << val[1] }
    ;

  motion_modifier
    : DOT swallow_newlines AT '(' speed ')'
                                       { result = SpeedNode.new(val[4]) }
    | DOT swallow_newlines TERM '(' indirectable ')'
                                       { result = TerminationNode.new(val[4]) }
    | DOT swallow_newlines OFFSET '(' var ')'
                                       { result = OffsetNode.new(val[4]) }
    | DOT swallow_newlines TIME_SEGMENT '(' time ',' time_seg_actions ')'
                                       { result = TimeNode.new(val[2],val[4],val[6]) }
    | DOT swallow_newlines SKIP '(' label optional_lpos_arg ')'
                                       { result = SkipNode.new(val[4],val[5]) }
    ;

  optional_lpos_arg
    : ',' var                          { result = val[1] }
    |
    ;

  indirectable
    : number
    | var
    ;

  time_seg_actions
    : program_call
    | io_method
    ;

  time
    : var
    | number
    ;

  speed
    : indirectable ',' STRING          { result = { speed: val[0], units: val[2] } }
    | STRING                           { result = { speed: val[0], units: nil } }
    ;

  label_definition
    : label                            { result = LabelDefinitionNode.new(val[0]) }#@interpreter.add_label(val[1]) }
    ;

  definition
    : WORD ASSIGN definable            { result = DefinitionNode.new(val[0],val[2]) }
    ;

  assignment
    : var EQUAL expression            { result = AssignmentNode.new(val[0],val[2]) }
    | var PLUS EQUAL expression       { result = AssignmentNode.new(
                                           val[0],
                                           ExpressionNode.new(val[0],val[1],val[3])
                                         )
                                       }
    | var MINUS EQUAL expression       { result = AssignmentNode.new(
                                           val[0],
                                           ExpressionNode.new(val[0],val[1],val[3])
                                         )
                                       }
    ;

  var
    : namespaces DOT var               { result = NamespacedVarNode.new(val[0],val[2]) }
    | WORD DOT WORD                    { result = VarMethodNode.new(val[0],val[2]) }
    | WORD                             { result = VarNode.new(val[0]) }
    ;

  namespaces
    : namespace                       { result = val }
    | namespaces ':' ':' namespace    { result = val[0] << val[3] }
    ;

  namespace
    : WORD
    ;

  # this change goes from 6 shift/reduce conflicts to 20
  expression
    : factor                           { result = val[0] }
    | operator                         { result = val[0] }
    | '(' expression ')'               { val[1].grouped = true; result = val[1] }
    ;

  #expression
  #  : simple_expression                         { result = val[0] }
  #  | simple_expression relop simple_expression { result = ExpressionNode.new(val[0],val[1],val[2]) }
  #  | '(' expression ')'                        { result = val[1] }
  #  ;

  #simple_expression
  #  : term                                      { result = val[0] }
  #  | simple_expression addop term              { result = ExpressionNode.new(val[0],val[1],val[2]) }
  #  ;

  #term
  #  : factor
  #  | term mulop factor                         { result = ExpressionNode.new(val[0],val[1],val[2]) }
  #  ;

  # 20 to 48 conflicts!!
  operator
    : expression relop expression      { result = ExpressionNode.new(val[0],val[1],val[2]) }
    | expression addop expression      { result = ExpressionNode.new(val[0],val[1],val[2]) }
    | expression mulop expression      { result = ExpressionNode.new(val[0],val[1],val[2]) }
    # 48 => 50 with prec on BANG (62) without
    | BANG expression                  { result = ExpressionNode.new(val[1],val[0],nil) }
    ;

  relop
    : EEQUAL
    | NOTEQUAL
    | LT
    | GT
    | GTE
    | LTE
    ;

  addop
    : PLUS
    | MINUS
    | OR
    ;

  mulop
    : STAR
    | SLASH
    | DIV
    | MOD
    | AND
    ;

  factor
    : signed_number
    | var
    | indirect_position
    ;

  indirect_position
    : POSITION '(' indirectable ')'   { result = IndirectNode.new(:position, val[2]) }
    | POSITION_REGISTER '(' indirectable ')'
                                      { result = IndirectNode.new(:position_register, val[2]) }
    ;

  signed_number
    : sign DIGIT                      { val[1] = val[1].to_i * -1 if val[0] == "-"; result = DigitNode.new(val[1]) }
    | sign REAL                       { val[1] = val[1].to_f * -1 if val[0] == "-"; result = RealNode.new(val[1]) }
    ;

  sign
    : MINUS
    |
    ;

  number
    : DIGIT                            { result = DigitNode.new(val[0]) }
    | REAL                             { result = RealNode.new(val[0]) }
    ;

  definable
    : numreg
    | output
    | input
    | posreg
    | position
    | vreg
    | number
    | argument
    ;

  argument
    : ARG '[' DIGIT ']'                { result = ArgumentNode.new(val[2].to_i) }
    ;

  vreg
    : VREG '[' DIGIT ']'               { result = VisionRegisterNode.new(val[2].to_i) }
    ;

  position
    : POSITION '[' DIGIT ']'           { result = PositionNode.new(val[2].to_i) }
    ;

  numreg
    : NUMREG '[' DIGIT ']'             { result = NumregNode.new(val[2].to_i) }
    ;

  posreg
    : POSREG '[' DIGIT ']'             { result = PosregNode.new(val[2].to_i) }
    ;

  output
    : OUTPUT '[' DIGIT ']'             { result = IONode.new(val[0], val[2].to_i) }
    ;

  input
    : INPUT '[' DIGIT ']'              { result = IONode.new(val[0], val[2].to_i) }
    ;

  comment
    : COMMENT                          { result = CommentNode.new(val[0]) }
    ;

  terminator
    : NEWLINE                          { result = TerminatorNode.new }
    | comment                          { result = val[0] }
    ;

  swallow_newlines
    : NEWLINE                          { result = TerminatorNode.new }
    |
    ;

end

---- inner

  include TPPlus::Nodes

  attr_reader :interpreter
  def initialize(scanner, interpreter = TPPlus::Interpreter.new)
    @scanner       = scanner
    @interpreter   = interpreter
    super()
  end

  def next_token
    t = @scanner.next_token
    @interpreter.line_count += 1 if t && t[0] == :NEWLINE

    #puts t.inspect
    t
  end

  def parse
    do_parse
    @interpreter
  rescue Racc::ParseError => e
    raise "Parse error on line #{@interpreter.line_count+1}: #{e}"
  end
