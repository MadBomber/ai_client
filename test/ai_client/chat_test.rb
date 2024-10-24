require_relative '../test_helper'

class TestChatFunction < AiClient::Function
  def self.call(**params)
    "Tool response"
  end

  def self.details
    {
      name: :test_function,
      description: 'A test function'
    }
  end
end

class ChatTest < Minitest::Test
  def setup
    @model  = 'llama3.1'
    @client = AiClient.new(@model)
    @client.config.timeout = 5  # Add timeout to prevent long-running tests
    skip "Ollama server not available - run 'ollama serve'" unless ollama_available?
  end

  def ollama_available?
    system('curl -s http://localhost:11434/api/tags >/dev/null')
  end

  def test_chat_with_context
    # First chat interaction
    result = @client.chat('Hello')
    refute_nil result
    refute_empty result
    
    # Verify context is stored
    context = @client.instance_variable_get(:@context)
    assert_equal 1, context.length
    assert_equal 'Hello', context.first[:user]
    refute_nil context.first[:bot]
  end

  def test_chat_with_tools
    TestChatFunction.register

    result = @client.chat('Use tool', tools: ['test_function'])
    refute_nil result

    TestChatFunction.disable
  end

  def test_clear_context
    @client.chat('Add to context')
    assert_equal 1, @client.instance_variable_get(:@context).length

    @client.clear_context
    assert_empty @client.instance_variable_get(:@context)
  end

  def test_add_context_with_empty_context
    result = @client.add_context('New message')
    assert_equal 'New message', result
  end

  def test_add_context_with_context_disabled
    @client.config.context_length = 0
    result = @client.add_context('Test message')
    assert_equal 'Test message', result
  end

  def test_add_context_with_array_input
    array_input = [{role: 'user', content: 'Test'}]
    result = @client.add_context(array_input)
    assert_equal array_input, result
  end

  def test_raw_response
    @client.raw = true
    result = @client.chat('Hi')  # Shorter message
    assert result.respond_to?(:data), "Raw response should have data method"
    assert_kind_of Hash, result.data
  end

  def test_context_length_limit
    @client.config.context_length = 2
    
    @client.chat('Hi')  # Shorter messages
    @client.chat('Hey')
    @client.chat('Bye')
    
    context = @client.instance_variable_get(:@context)
    assert_equal 2, context.length, "Context should be limited to 2 entries"
    assert_equal 'Hey', context.first[:user]
    assert_equal 'Bye', context.last[:user]
  end

  def test_chat_with_invalid_tools
    assert_raises(RuntimeError) do
      @client.chat('Test', tools: 'invalid')
    end
  end
end
