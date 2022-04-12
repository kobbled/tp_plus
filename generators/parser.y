class TPPlus::Parser
token ASSIGN AT_SYM COMMENT MESSAGE WARNING JUMP IO_METHOD INPUT OUTPUT
token NUMREG POSREG VREG SREG TIME_SEGMENT DISTANCE_SEGMENT ARG UALM TOOLREG FRAMEREG
token MOVE DOT TO DOWNTO MID AT ACC TERM OFFSET SKIP GROUP COORD 
token MROT PTH WJNT INC BREAK RTCP FPLIN
token AP_LD RT_LD CD CR INDEV EV PSPD CTV
token SEMICOLON NEWLINE STRING
token REAL DIGIT WORD EQUAL RANGE
token EEQUAL NOTEQUAL GTE LTE LT GT BANG
token PLUS MINUS STAR SLASH DIV AND OR MOD
token IF THEN ELSE ELSIF END UNLESS FOR IN WHILE
token WAIT_FOR WAIT_UNTIL TIMEOUT AFTER
token FANUC_USE COLL_GUARD SET_SKIP_CONDITION NAMESPACE
token CASE WHEN INDIRECT POSITION
token EVAL TIMER TIMER_METHOD RAISE ABORT RETURN
token POSITION_DATA TRUE_FALSE ON_OFF CALL RUN PAUSE
token TP_HEADER TP_APPLICATION_TYPE
token LPAREN RPAREN COLON COMMA LBRACK RBRACK LBRACE RBRACE
token LABEL SYSTEM ADDRESS
token LPOS JPOS
token false
token FUNCTION OPERATION USING IMPORT COMPILE INLINE
token ARROW DEFAULTPOS POSEATTR POSEREVERSE
token SPHERE POLAR ORIGIN FIX

prechigh
  right BANG
  left STAR SLASH DIV MOD
  left PLUS MINUS
  left GT GTE LT LTE
  left EEQUAL NOTEQUAL
  left AND
  left OR
  right EQUAL
preclow

rule
  program
    #: statements                        { @interpreter.nodes = val[0].flatten }
    : statements { @interpreter.nodes = val[0] }
    |
    ;


  statements
    : statement terminator              {
                                          result = [val[0]]
                                          result << val[1] unless val[1].nil?
                                        }
    | statements statement terminator   {
                                          result = val[0] << val[1]
                                          result << val[2] unless val[2].nil?
                                        }
    ;

  block
    : NEWLINE statements      { result = val[1] }
    ;

  optional_newline
    : NEWLINE
    |
    ;

  statement
    : comment
    | message
    | definition
    | namespace
    #| assignment
    | motion_statement
    | position_assignment
    #| jump
    #| io_method
    | label_definition
    | address
    | conditional
    | inline_conditional
    | conditional_block
    | forloop
    | while_loop
    #| program_call
    | use_statement
    | set_skip_statement
    | wait_statement
    | case_statement
    | fanuc_eval
    | timer_method
    | position_data
    | raise
    | tp_header_definition
    | lpos_or_jpos
    | empty_stmt
    | warning
    | var_system
    | PAUSE                           { result = PauseNode.new }
    | ABORT                           { result = AbortNode.new }
    | return_statement
    | collguard_statement
    | function
    | tp_application_definition
    | using_statement
    | import_statement
    | compile_statement
    ;

  lpos_or_jpos
    : LPOS LPAREN var_or_indirect RPAREN          { result = LPOSNode.new(val[2]) }
    | JPOS LPAREN var_or_indirect RPAREN          { result = JPOSNode.new(val[2]) }
    ;

  empty_stmt
    : NEWLINE                         { result = EmptyStmtNode.new() }
    ;

  tp_header_definition
    : TP_HEADER EQUAL tp_header_value { result = HeaderNode.new(val[0],val[2]) }
    ;

  tp_header_value
    : STRING
    | TRUE_FALSE
    | ON_OFF
    ;

  tp_tool_methods
    : LBRACE sn tp_tool_attributes sn RBRACE    { result = val[2] }
    | LBRACE sn RBRACE                       { result = {} }
    ;

  tp_tool_attributes
    : tp_tool_attribute                   { result = val[0] }
    | tp_tool_attributes COMMA sn tp_tool_attribute
                                       { result = val[0] + val[3] }
    ;

  tp_tool_attribute
    : WORD COLON hash_value {result = [ToolApplMem.new(val[0],val[2])]}
    ;
    
  tp_application_definition
    : TP_APPLICATION_TYPE EQUAL sn tp_tool_methods  { result = ToolApplNode.new(val[0],val[3]) }
    ;

  raise
    : RAISE var_or_indirect            { result = RaiseNode.new(val[1]) }
    ;

  timer_method
    : TIMER_METHOD var_or_indirect     { result = TimerMethodNode.new(val[0],val[1]) }
    ;

  fanuc_eval
    : EVAL STRING                      { result = EvalNode.new(val[1]) }
    ;

  wait_statement
    : WAIT_FOR LPAREN indirectable COMMA STRING RPAREN
                                       { result = WaitForNode.new(val[2], val[4]) }
    | WAIT_UNTIL LPAREN expression RPAREN
                                       { result = WaitUntilNode.new(val[2], nil) }
    | WAIT_UNTIL LPAREN expression RPAREN DOT wait_modifier
                                       { result = WaitUntilNode.new(val[2],val[5]) }
    | WAIT_UNTIL LPAREN expression RPAREN DOT wait_modifier DOT wait_modifier
                                       { result = WaitUntilNode.new(val[2],val[5].merge(val[7])) }
    ;

  wait_modifier
    : timeout_modifier
    | after_modifier
    ;

  timeout_modifier
    : swallow_newlines TIMEOUT LPAREN label RPAREN
                                       { result = { label: val[3] } }
    ;

  after_modifier
    : swallow_newlines AFTER LPAREN indirectable COMMA STRING RPAREN
                                       { result = { timeout: [val[3],val[5]] } }
    ;

  label
    : LABEL { result = val[0] }
    ;

  group_statement
    : GROUP LPAREN integer RPAREN { result = val[2] }
    ;
  
  use_statement
    : FANUC_USE indirectable           { result = UseNode.new(val[0],val[1]) }
    | FANUC_USE LPAREN indirectable RPAREN  { result = UseNode.new(val[0],val[2]) }
    | FANUC_USE LPAREN indirectable COMMA group_statement RPAREN  { result = UseNode.new(val[0],val[2],val[4]) }
    ;

  collguard_statement
    : COLL_GUARD optional_arg           { result = ColGuard.new(val[0],val[1]) }
    ;

  # set_skip_condition x
  set_skip_statement
    : SET_SKIP_CONDITION expression             { result = SetSkipNode.new(val[1]) }
    ;

  function_call
    : WORD                { result = val[0] }
    | namespaces WORD     { result = val[0][0] + '_' + val[1] }
    ;
  program_call
    : function_call LPAREN args RPAREN                { result = CallNode.new(val[0],val[2]) }
    | RUN function_call LPAREN args RPAREN            { result = CallNode.new(val[1],val[3],async: true) }
    | CALL var LPAREN args RPAREN                     { result = CallNode.new(nil,val[3],str_call:val[1]) }
    | var_or_indirect EQUAL function_call LPAREN args RPAREN     { result = CallNode.new(val[2],val[4],ret:val[0]) }
    ;

  args
    : arg                              { result = [val[0]] }
    | args COMMA arg                     { result = val[0] << val[2] }
    |                                  { result = [] }
    ;

  arg
    : number
    | signed_number
    | var
    | string
    | address
    ;

  program_vars
    : program_var                     { result = [val[0]] }
    | program_vars COMMA program_var  { result = val[0] << val[2] }
    |                                  { result = [] }

  program_var
    : WORD                             { result = FunctionVarNode.new(val[0]) }

  return_statement
    : RETURN LPAREN expression RPAREN      { result = FunctionReturnNode.new(val[2]) }
    | RETURN                               { result = ReturnNode.new }

  string
    : STRING                           { result = StringNode.new(val[0]) }
    ;

  io_method
    : IO_METHOD var_or_indirect        { result = IOMethodNode.new(val[0],val[1]) }
    | IO_METHOD LPAREN var_or_indirect RPAREN
                                       { result = IOMethodNode.new(val[0],val[2]) }
    | IO_METHOD LPAREN var_or_indirect COMMA number COMMA STRING RPAREN
                                       { result = IOMethodNode.new(val[0],val[2],{ pulse_time: val[4], pulse_units: val[6] }) }
    ;

  var_or_indirect
    : var
    | indirect_thing
    | var_system
    ;


  jump
    : JUMP label                       { result = JumpNode.new(val[1]) }
    ;

  conditional
    : IF expression block elsif_conditions else_block END
                                       { result = ConditionalNode.new("if",val[1],val[2],val[3],val[4]) }
    | UNLESS expression block else_block END
                                       { result = ConditionalNode.new("unless",val[1],val[2],[],val[3]) }
    ;

  conditional_block
    : IF expression THEN block elsif_block else_block END
                                      { result = ConditionalBlockNode.new(val[1],val[3],val[4],val[5]) }

  elsif_conditions
    : elsif_condition                   { result = val }
    | elsif_conditions elsif_condition
                                        { result = val[0] << val[1] << val[2] }
    |                                   { result = [] }
    ;
  
  elsif_condition
    : ELSIF expression block  
                                        { result = ConditionalNode.new("if",val[1],val[2],[],[]) }
    ;

  elsif_block
    : elsif_block_condition                  { result = val }
    | elsif_block elsif_block_condition
                                        { result = val[0] << val[1] << val[2] }
    |                                   { result = [] }
    ;

  elsif_block_condition
    : ELSIF expression THEN block
                      { result = ConditionalBlockNode.new(val[1],val[3],[],[]) }

  forloop
    : FOR var IN LPAREN int_or_var TO int_or_var RPAREN block END
                                       { result = ForNode.new(val[1],val[4],val[6],val[8],val[5]) }
    | FOR var IN LPAREN int_or_var DOWNTO int_or_var RPAREN block END
                                       { result = ForNode.new(val[1],val[4],val[6],val[8],val[5]) }
    ;

  while_loop
    : WHILE expression block END       { result = WhileNode.new(val[1],val[2]) }
    ;

  int_or_var
    : integer
    | var
    ;

  word_list
    : word_tuple                             { result = val }
    | word_list word_tuple                   { result = val[0] << val[1] }
    ;
  
  word_tuple
    : COMMA WORD                     { result = val[1] }
    | WORD                              { result = val[0] }
    ;

  using_statement
    : USING word_list           { result = UsingNode.new(val[1])}
    ;

  compile_statement
    : COMPILE IMPORT word_list         { result = ImportNode.new(val[2],compile: true)}
    ;
  
  import_statement
    : IMPORT word_list           { result = ImportNode.new(val[1])}
    ;

  namespace
    : NAMESPACE WORD block END         { result = NamespaceNode.new(val[1],val[2]) }
    ;
  
  function
    : INLINE FUNCTION WORD LPAREN program_vars RPAREN block END         { result = FunctionNode.new(val[2],val[4],val[6], '', true) }
    | INLINE FUNCTION WORD LPAREN program_vars RPAREN COLON WORD block END  { result = FunctionNode.new(val[2],val[4],val[8],val[7], true) }
    | FUNCTION WORD LPAREN program_vars RPAREN block END         { result = FunctionNode.new(val[1],val[3],val[5]) }
    | FUNCTION WORD LPAREN program_vars RPAREN COLON WORD block END  { result = FunctionNode.new(val[1],val[3],val[7],val[6]) }
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
    : WHEN case_allowed_condition block  
                                        {result = CaseConditionNode.new(val[1],val[2]) }
    ;

  case_allowed_condition
    : number
    | var
    ;

  case_else
    : ELSE block
                                        {result = CaseConditionNode.new(nil,val[1]) }
    |
    ;

  case_allowed_statement
    : program_call
    | jump
    ;

  inline_conditional
    : inlineable
    | inlineable IF expression     { result = InlineConditionalNode.new(val[1], val[2], val[0]) }
    | inlineable UNLESS expression { result = InlineConditionalNode.new(val[1], val[2], val[0]) }
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
    : MOVE DOT swallow_newlines TO LPAREN var_or_indirect RPAREN motion_modifiers
                                       { result = MotionNode.new(val[0],nil,val[5],val[7]) }
    | MOVE DOT swallow_newlines MID LPAREN var_or_indirect RPAREN DOT swallow_newlines TO LPAREN var_or_indirect RPAREN motion_modifiers
                                       { result = MotionNode.new(val[0],val[5],val[11],val[13]) }
    ;

  motion_modifiers
    : motion_modifier                  { result = val }
    | motion_modifiers motion_modifier
                                       { result = val[0] << val[1] }
    ;

  motion_arguements
    : valid_terminations
        { result = [val[0]] }
    | valid_terminations COMMA valid_terminations
        { result = [val[0], val[2]] }
    ;

  motion_modifier
    : DOT swallow_newlines AT LPAREN speed RPAREN
                                       { result = SpeedNode.new(val[4]) }
    | DOT swallow_newlines ACC LPAREN int_or_var RPAREN
                                       { result = AccNode.new(val[4]) }
    | DOT swallow_newlines CR LPAREN motion_arguements RPAREN
                                       { result = TerminationNode.new(val[2],val[4][0],val[4][1]) }
    | DOT swallow_newlines TERM LPAREN valid_terminations RPAREN
                                       { result = TerminationNode.new(val[2],val[4],nil) }
    | DOT swallow_newlines OFFSET LPAREN var_or_indirect RPAREN
                                       { result = OffsetNode.new(val[2],val[4]) }
    | DOT swallow_newlines TIME_SEGMENT LPAREN time COMMA seg_actions RPAREN
                                       { result = TimeNode.new(val[2],val[4],val[6]) }
    | DOT swallow_newlines DISTANCE_SEGMENT LPAREN distance COMMA seg_actions RPAREN
                                       { result = DistanceNode.new(val[2],val[4],val[6]) }
    | DOT swallow_newlines SKIP LPAREN label optional_lpos_arg RPAREN
                                       { result = SkipNode.new(val[4],val[5]) }
    | DOT swallow_newlines valid_motion_statements
                                       { result = StatementModifierNode.new(val[2]) }
    | DOT swallow_newlines single_argument_motion_modifiers LPAREN int_or_var RPAREN
                                       { result = ArguementModifierNode.new(val[2],val[4]) }
    ;

  valid_motion_statements
    : COORD 
    | MROT
    | PTH 
    | INC
    | WJNT
    | BREAK
    | RTCP
    | FPLIN
    ;

  single_argument_motion_modifiers
    : CD
    | EV
    | INDEV
    | RT_LD
    | AP_LD
    | PSPD
    | CTV
    ;

  valid_terminations
    : integer
    | var
    | MINUS DIGIT                      {
                                         raise Racc::ParseError, sprintf("\ninvalid termination type: (%s)", val[1]) if val[1] != 1

                                         result = DigitNode.new(val[1].to_i * -1)
                                       }
    ;

  optional_lpos_arg
    : COMMA var                          { result = val[1] }
    |
    ;

  indirectable
    : number
    | var
    ;

  optional_arg
    : number
    | var
    |                 { result = nil }
    ;

  seg_actions
    : program_call
    | io_method
    | assignment
    ;

  time
    : var
    | number
    ;
  
  distance
    : var
    | number
    ;

  speed
    : indirectable COMMA STRING          { result = { speed: val[0], units: val[2] } }
    | STRING                           { result = { speed: val[0], units: nil } }
    ;

  label_definition
    : label                            { result = LabelDefinitionNode.new(val[0]) }#@interpreter.add_label(val[1]) }
    ;

  definition
    : WORD ASSIGN definable            { result = RegDefinitionNode.new(val[0], val[2]) }
    ;

  assignment
    : var_or_indirect EQUAL expression            { result = AssignmentNode.new(val[0],val[2]) }
    | var_or_indirect PLUS EQUAL expression       { result = AssignmentNode.new(
                                           val[0],
                                           ExpressionNode.new(val[0],"+",val[3])
                                         )
                                       }
    | var_or_indirect MINUS EQUAL expression       { result = AssignmentNode.new(
                                           val[0],
                                           ExpressionNode.new(val[0],"-",val[3])
                                         )
                                       }
    | var_or_indirect STAR EQUAL expression       { result = AssignmentNode.new(
                                           val[0],
                                           ExpressionNode.new(val[0],"*",val[3])
                                         )
                                       }
    | var_or_indirect SLASH EQUAL expression       { result = AssignmentNode.new(
                                           val[0],
                                           ExpressionNode.new(val[0],"/",val[3])
                                         )
                                       }
    ;

  position_assignment
    : DEFAULTPOS var_method_modifiers ARROW array   { result = PoseDefaultNode.new(val[1],val[3]) }
    | var_or_indirect ARROW array   { result = PoseNode.new(val[0],val[2]) }
    | LPAREN assignable_range RPAREN var_method_modifiers ARROW array   { result = PoseRangeNode.new(val[1],val[3],val[5]) }
    | assignable_range EQUAL assignable_range {result = PoseAssignNode.new(val[0], val[2])}
    | assignable_range EQUAL LPAREN assignable_range RPAREN pose_range_modifiers {result = PoseAssignNode.new(val[0], val[3], val[5])}
    ;

  assignable_range
    : var RANGE var  {result = RangeNode.new(val[0], val[2])}
    | var {result = RangeNode.new(val[0], val[0])}
    ;

  var
    : var_without_namespaces
    | var_with_namespaces
    ;

  var_without_namespaces
    : WORD                             { result = VarNode.new(val[0]) }
    | WORD var_method_modifiers        { result = VarMethodNode.new(val[0],val[1]) }
    ;

  var_with_namespaces
    : namespaces var_without_namespaces
                                       { result = NamespacedVarNode.new(val[0],val[1]) }
    ;

  var_method_modifiers
    : var_method_modifier              { result = val[0] }
    | var_method_modifiers var_method_modifier
                                       { result = val[0].merge(val[1]) }
    ;

  pose_range_modifiers
    : pose_range_modifier                      { result = val[0] }
    | pose_range_modifiers pose_range_modifier
                                              { result = val[0].merge(val[1]) }
    ;
  
  pose_range_modifier
    : DOT swallow_newlines POSEREVERSE   { result = {mod: val[2]} }
    ;

  coord_system
    : SPHERE        { result = val[0] }
    | POLAR         { result = val[0] }
    | ORIGIN        { result = val[0] }
    ;
  
  var_method_modifier
    : DOT swallow_newlines WORD        { result = { method: val[2] } }
    | DOT swallow_newlines group_statement
                                       { result = { group: val[2] } }
    | DOT swallow_newlines POSEATTR
                                       { result = { pose: val[2] } }
    | DOT swallow_newlines OFFSET
                                       { result = { offset: true } }
    | DOT swallow_newlines coord_system
                                       { result = { coord: val[2] } }
    | DOT swallow_newlines FIX
                                       { result = { fix: true } }
    ;
  
  var_system
    : SYSTEM WORD var_system_modifers    { result = SystemDefinitionNode.new(val[1], nil, val[2]) }
    | SYSTEM WORD LBRACK integer RBRACK var_system_modifers { result = SystemDefinitionNode.new(val[1], val[3], val[5])  }
    ;

  var_system_modifers
    : var_system_modifer                      { result = [val[0]] }
    | var_system_modifers var_system_modifer
                                              {result =  val[0] << val[1] }
    |
    ;

  var_system_modifer
    : DOT var_system                        { result = val[1] }
    ;

  namespaces
    : ns                               { result = [val[0]] }
    | namespaces ns                    { result = val[0] << val[1] }
    ;

  ns
    : WORD COLON COLON                 { result = val[0] }
    ;


  expression
    : unary_expression
    | binary_expression
    ;

  unary_expression
    : factor                           { result = val[0] }
    | address
    | BANG factor                      { result = UnaryExpressionNode.new("!",val[1]) }
    ;

  binary_expression
    : expression operator expression
                                       { result = ExpressionNode.new(val[0], val[1], val[2]) }
    ;

  operator
    : EEQUAL { result = "==" }
    | NOTEQUAL { result = "<>" }
    | LT { result = "<" }
    | GT { result = ">" }
    | GTE { result = ">=" }
    | LTE { result = "<=" }
    | PLUS { result = "+" }
    | MINUS { result = "-" }
    | OR { result = "||" }
    | STAR { result = "*" }
    | SLASH { result = "/" }
    | DIV { result = "DIV" }
    | MOD { result = "%" }
    | AND { result = "&&" }
    ;

  factor
    : number
    | signed_number
    | operation
    | var
    | signed_var
    | var_system
    | indirect_thing
    | paren_expr
    | booleans
    ;

  booleans
    : TRUE_FALSE   { result = BooleanNode.new(val[0]) }
    | ON_OFF       { result = BooleanNode.new(val[0]) }

  paren_expr
    : LPAREN expression RPAREN        { result = ParenExpressionNode.new(val[1]) }
    ;

  indirect_thing
    : INDIRECT LPAREN STRING COMMA indirectable RPAREN
                                      { result = IndirectNode.new(val[2].to_sym, val[4], nil) }
    | INDIRECT LPAREN STRING COMMA indirectable RPAREN var_method_modifiers
                                      { result = IndirectNode.new(val[2].to_sym, val[4], val[6]) }
    ;

  signed_number
    : sign DIGIT                      {
                                          val[1] = val[1].to_i * -1 if val[0] == "-"
                                          result = DigitNode.new(val[1])
                                      }
    | sign REAL                       { val[1] = val[1].to_f * -1 if val[0] == "-"; result = RealNode.new(val[1]) }
    ;

  signed_var
    : sign var                        { result = ExpressionNode.new(
                                          val[1],
                                          "*",
                                          DigitNode.new(-1)
                                        ) }
    ;

  sign
    : MINUS { result = "-" }
    ;

  number
    : integer
    | REAL                             { result = RealNode.new(val[0]) }
    ;

  integer
    : DIGIT                            { result = DigitNode.new(val[0]) }
    ;

  definable
    : reg
    | number
    | signed_number
    | string
    | framereg
    | booleans
    ;

  definable_range
    : DIGIT RANGE DIGIT      {result = RangeNode.new(val[0].to_i, val[2].to_i)}
    | DIGIT       { result = RangeNode.new(val[0].to_i, val[0].to_i)}
    ;

  reg_types
    : SREG  {result = val[0]}
    | UALM  {result = val[0]}
    | TIMER {result = val[0]}
    | ARG   {result = val[0]}
    | VREG  {result = val[0]}
    | POSITION {result = val[0]}
    | NUMREG {result = val[0]}
    | POSREG {result = val[0]}
    | INPUT {result = val[0]}
    | OUTPUT {result = val[0]}

  reg
    : reg_types LBRACK definable_range RBRACK               { val[2].setType(val[0]) ; result = val[2] }
    ;

  frametype
    : TOOLREG    { result = val[0] }
    | FRAMEREG   { result = val[0] }
    ;

  framereg
    : frametype LBRACK DIGIT RBRACK             { result = FrameNode.new(val[0], val[2].to_i) }
    ;
  


  operation
    : OPERATION LBRACK var_or_indirect RBRACK     { result = OperationNode.new(val[0], val[2], nil) }
    | OPERATION LBRACK var_or_indirect COMMA var_or_indirect RBRACK   { result = OperationNode.new(val[0], val[2], val[4]) }
    | OPERATION LBRACK signed_number RBRACK       {  result = OperationNode.new(val[0], val[2], nil) }
    | OPERATION LBRACK number RBRACK       {  result = OperationNode.new(val[0], val[2], nil) }
    ;

  address
    : ADDRESS var                       { result = AddressNode.new(val[1]) }
    ;

  comment
    : COMMENT                                { result = CommentNode.new(val[0]) }
    ;
  
  message
    : MESSAGE LPAREN STRING RPAREN      { result = MessageNode.new(val[2]) }
    ;

warning
    : WARNING LPAREN STRING RPAREN      { @interpreter.increment_warning_labels()
label = @interpreter.get_warning_label()
result = WarningNode.new(MessageNode.new(val[2]), LabelDefinitionNode.new(label)) }
    ;

  terminator
    : NEWLINE                          { result = TerminatorNode.new }
    | comment optional_newline         { result = val[0] }
              # ^-- consume newlines or else we will get an extra space from EmptyStmt in the output
    | false
    |
    ;

  swallow_newlines
    : NEWLINE                          { result = TerminatorNode.new }
    |
    ;

  position_data
    : POSITION_DATA sn hash sn END
                                       { result = PositionDataNode.new(val[2]) }
    ;

  sn
    : swallow_newlines
    ;

  hash
    : LBRACE sn hash_attributes sn RBRACE    { result = val[2] }
    | LBRACE sn RBRACE                       { result = {} }
    ;

  hash_attributes
    : hash_attribute                   { result = val[0] }
    | hash_attributes COMMA sn hash_attribute
                                       { result = val[0].merge(val[3]) }
    ;

  hash_attribute
    : STRING COLON hash_value              { result = { val[0].to_sym => val[2] } }
    ;

  hash_value
    : STRING
    | WORD                              
    | hash
    | array
    | optional_sign DIGIT              { val[1] = val[1].to_i * -1 if val[0] == "-"; result = val[1] }
    | optional_sign REAL               { val[1] = val[1].to_f * -1 if val[0] == "-"; result = val[1] }
    | TRUE_FALSE                       { result = val[0] == "true" }
    ;

  optional_sign
    : sign
    |
    ;

  array
    : LBRACK sn array_values sn RBRACK       { result = val[2] }
    ;

  array_values
    : array_value                      { result = val }
    | array_values COMMA sn array_value  { result = val[0] << val[3] }
    ;

  array_value
    : hash_value
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
    #@yydebug =true

    do_parse
    @interpreter
  end

  def on_error(t, val, vstack)
    raise ParseError, sprintf("Parse error on line #{@scanner.tok_line} column #{@scanner.tok_col}: %s (%s)",
                                val.inspect, token_to_str(t) || '?')
  end

  class ParseError < StandardError ; end
