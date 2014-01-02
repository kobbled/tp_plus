class TPPlus::Parser
token ASSIGN AT_SYM COMMENT JUMP IO_METHOD INPUT OUTPUT
token NUMREG POSREG VREG SREG
token MOVE DOT TO AT TERM
token SEMICOLON NEWLINE
token REAL DIGIT WORD EQUAL UNITS
token EEQUAL NOTEQUAL GTE LTE LT GT
token PLUS MINUS STAR SLASH DIV AND OR MOD
token IF ELSE END UNLESS
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
    | assignment
    | motion_statement
    | jump
    | io_method
    | label_definition
    | conditional
    | inline_conditional
    | program_call
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
    : JUMP AT_SYM WORD                 { result = JumpNode.new(val[2]) }
    ;

  conditional
    : IF expression block else_block END
                                       { result = ConditionalNode.new("if",val[1],val[2],val[3]) }
    | UNLESS expression block else_block END
                                       { result = ConditionalNode.new("unless",val[1],val[2],val[3]) }
    ;

  inline_conditional
    : inlineable IF expression          { result = InlineConditionalNode.new("if",val[2],val[0]) }
    | inlineable UNLESS expression      { result = InlineConditionalNode.new("unless",val[2],val[0]) }
    ;

  inlineable
    : jump
    | assignment
    | io_method
    ;

  else_block
    : ELSE block                       { result = val[1] }
    |
    ;

  motion_statement
    : MOVE DOT TO '(' var ')' motion_modifiers
                                       { result = MotionNode.new(val[0],val[4],val[6]) }
    ;

  motion_modifiers
    : motion_modifier                  { result = val }
    | motion_modifiers motion_modifier
                                       { result = val[0] << val[1] }
    ;
    #: DOT motion_modifier motion_modifiers
    #                                  { result = val[1] }
    #| DOT motion_modifier             { result = val[1] }
    #;

  motion_modifier
    : DOT AT '(' speed ')'                 { result = SpeedNode.new(val[3]) }
    | DOT TERM '(' number ')'              { result = TerminationNode.new(val[3]) }
    ;

  speed
    : number UNITS                     { result = [val[0],UnitsNode.new(val[1])] }
    ;


  label_definition
    : AT_SYM WORD                      { result = LabelDefinitionNode.new(val[1]) }#@interpreter.add_label(val[1]) }
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
    : WORD                             { result = VarNode.new(val[0]) }
    ;

  expression
    : simple_expression                         { result = val[0] }
    | simple_expression relop simple_expression { result = ExpressionNode.new(val[0],val[1],val[2]) }
    ;

  simple_expression
    : term                                      { result = val[0] }
    | simple_expression addop term              { result = ExpressionNode.new(val[0],val[1],val[2]) }
    ;

  term
    : factor
    | term mulop factor                         { result = ExpressionNode.new(val[0],val[1],val[2]) }
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
    : number
    | var
    ;

  number
    : DIGIT                            { result = DigitNode.new(val[0]) }
    ;

  definable
    : numreg
    | output
    | posreg
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

  comment
    : COMMENT                          { result = CommentNode.new(val[0]) }
    ;

  terminator
    : NEWLINE                          { result = TerminatorNode.new }
    | comment                          { result = val[0] }
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
    @interpreter.line_count += 1 if t == [:NEWLINE,"\n"]

    puts t.inspect
    t
  end

  def parse
    do_parse
    @interpreter
  rescue Racc::ParseError => e
    raise "Parse error on line #{@interpreter.line_count+1}: #{e}"
  end
