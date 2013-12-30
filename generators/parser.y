class TPPlus::Parser
token ASSIGN AT_SYM COMMENT JUMP NUMREG IO_METHOD
token MOVE DOT TO AT TERM
token SEMICOLON NEWLINE
token REAL DIGIT WORD EQUAL PLUS MINUS UNITS
rule
  program
    : statements
    | terminator
    ;

  statements
    : statement terminator statements  { }
    | statement terminator             { @interpreter.nodes << val[0] }
    ;

  statement
    : COMMENT                          { result = CommentNode.new(val[0]) }
    | definition                       { result = val[0] }
    | assignment                       { result = val[0] }
    | motion_statement                 { result = val[0] }
    | IO_METHOD WORD                   { result = IOMethodNode.new(val[0],val[1]) }
    | JUMP AT_SYM WORD                 { result = JumpNode.new(val[2]) }
    | label_definition
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
