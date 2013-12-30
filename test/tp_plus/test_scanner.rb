require 'test_helper'

class TestScanner < Test::Unit::TestCase
  def setup
    @scanner = TPPlus::Scanner.new
  end
  def test_blank_string
    @scanner.scan_setup("")
    assert_nil @scanner.next_token
  end
end
