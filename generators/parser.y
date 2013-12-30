class TPPlus::Parser
token ASSIGN COMMENT NUMREG
token SEMICOLON NEWLINE nil
token REAL DIGIT WORD EQUAL
rule
  program
    : statements
    | terminator
    ;

  statements
    : statement terminator statements  { @interpreter.nodes << val[0] }
    | statement terminator             { @interpreter.nodes << val[0] }
    ;

  statement
    : COMMENT                          { result = CommentNode.new(val[0]) }
    | definition                       { result = val[0] }
    | assignment                       { result = val[0] }
    ;

  definition
    : WORD ASSIGN definable            { result = DefinitionNode.new(val[0],val[1]) }
    ;

  assignment
    : WORD EQUAL expression            { result = AssignmentNode.new(val[0],val[2]) }
    ;

  expression
    : DIGIT
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
    raise "Parse error on line #{@interpreter.line_count}: #{e}"
  end
