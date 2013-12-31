class TPPlus::Parser
token ASSIGN AT_SYM COMMENT JUMP NUMREG IO_METHOD
token MOVE DOT TO AT TERM
token SEMICOLON NEWLINE
token REAL DIGIT WORD EQUAL UNITS
token EEQUAL NOTEQUAL GTE LTE LT GT
token PLUS MINUS STAR SLASH DIV AND OR MOD
token IF ELSE END UNLESS
rule
  program
    : /* nothing */
    | statements                       { @interpreter.nodes = val[0] }
    ;

  statements
    : statement                        { result = val }
    | statements terminator statement  { result = val[0] << val[2] }
      # to ignore trailing line breaks
    | statements terminator            { result = val[0] }
    # this adds a couple conflicts
    | terminator statements
    | terminator                       { result = [TerminatorNode.new] }
    ;

  block
    | statements                       { result = val[0] }
    ;

  statement
    : COMMENT                          { result = CommentNode.new(val[0]) }
    | definition                       { result = val[0] }
    | assignment                       { result = val[0] }
    | motion_statement                 { result = val[0] }
    | IO_METHOD WORD                   { result = IOMethodNode.new(val[0],val[1]) }
    | JUMP AT_SYM WORD                 { result = JumpNode.new(val[2]) }
    | label_definition
    | conditional
    ;

  conditional
    : IF expression block else_block END
                                       { result = ConditionalNode.new(val[1],val[2],val[3]) }
    | UNLESS expression block else_block END
                                       { result = ConditionalNode.new(val[1],val[3],val[2]) }
    ;

  else_block
    : ELSE block                       { result = val[1] }
    |
    ;

  motion_statement
    : MOVE DOT TO '(' WORD ')' motion_modifiers
                                       { result = MotionNode.new(val[0],val[4],val[6]) }
    ;

  motion_modifiers
    : DOT motion_modifier motion_modifiers
    | DOT motion_modifier
    ;

  motion_modifier
    : AT '(' speed ')'
    | TERM '(' number ')'
    ;

  speed
    : number UNITS
    ;


  label_definition
    : AT_SYM WORD                      { @interpreter.add_label(val[1]) }
    ;

  definition
    : WORD ASSIGN definable            { result = DefinitionNode.new(val[0],val[1]) }
    ;

  assignment
    : WORD EQUAL expression            { result = AssignmentNode.new(val[0],val[2]) }
    | WORD PLUS EQUAL expression       { result = AssignmentNode.new(
                                           val[0],
                                           ExpressionNode.new(val[0],val[1],val[3])
                                         )
                                       }
    | WORD MINUS EQUAL expression       { result = AssignmentNode.new(
                                           val[0],
                                           ExpressionNode.new(val[0],val[1],val[3])
                                         )
                                       }
    ;

  expression
    : simple_expression
    | simple_expression relop simple_expression { result = ExpressionNode.new(val[0],val[1],val[2]) }
    ;

  simple_expression
    : term
    | simple_expression addop term
    ;

  term
    : factor
    | term mulop factor
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
    ;

  number
    : DIGIT                            { result = DigitNode.new(val[0]) }
    ;

  definable
    : numreg
    ;

  numreg
    : NUMREG '[' DIGIT ']'
    ;

  terminator
    : NEWLINE
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
