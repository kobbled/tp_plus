require 'test_helper'

class TestParser < Test::Unit::TestCase
  include TPPlus::Nodes

  def setup
    @scanner = TPPlus::Scanner.new
    @parser  = TPPlus::Parser.new @scanner
    @interpreter = @parser.interpreter
  end

  def parse(s)
    @scanner.scan_setup(s)
    @parser.parse
  end

  def last_node
    @last_node ||= @interpreter.nodes.last
  end

  def assert_node_type(t, n)
    assert_equal t, n.class
  end

  def test_minimum_prog
    parse("")
  end

  def test_comment
    parse("# foo")
    assert_node_type CommentNode, last_node
  end

  def test_numreg_definition
    parse("foo := R[1]")
    assert_node_type DefinitionNode, last_node
  end

  def test_assignment
    parse("foo = 1")
    assert_node_type AssignmentNode, last_node
  end

end
