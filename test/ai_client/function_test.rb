# test/ai_client/function_test.rb

require_relative '../test_helper'


class TestFunction < AiClient::Function
  def self.call(**params)
    params[:message] || "No message provided"
  end

  def self.details
    { name: :test_function, description: "A test function" }
  end
end

class AiClientFunctionTest < Minitest::Test
  def setup
    TestFunction.register
  end

  def teardown
    TestFunction.disable
  end

  def test_call_with_message
    result = TestFunction.call(message: "Hello, world!")
    assert_equal "Hello, world!", result
  end

  def test_call_without_message
    result = TestFunction.call
    assert_equal "No message provided", result
  end

  def test_details
    details = TestFunction.details
    assert_instance_of Hash, details
    assert_equal :test_function, details[:name]
    assert_equal "A test function", details[:description]
  end

  def test_register_function
    assert_includes TestFunction.functions, :test_function
  end

  def test_disable_function
    TestFunction.disable
    refute_includes TestFunction.functions, :test_function
  end
end

