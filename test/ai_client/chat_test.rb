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
    @model = 'gpt-3.5-turbo'
    @client = AiClient.new(@model)
  end

  def test_chat_with_context
    mock_client = mock()
    mock_client.expects(:chat).returns(OpenStruct.new(data: {'choices' => [{'message' => {'content' => 'Response 1'}}]}))
    @client.instance_variable_set(:@client, mock_client)

    # First chat interaction
    result = @client.chat('Hello')
    assert_equal 'Response 1', result
    
    # Verify context is stored
    context = @client.instance_variable_get(:@context)
    assert_equal 1, context.length
    assert_equal 'Hello', context.first[:user]
    assert_equal 'Response 1', context.first[:bot]
  end

  def test_chat_with_tools
    TestChatFunction.register

    mock_client = mock()
    mock_client.expects(:chat).returns(OpenStruct.new(data: {'choices' => [{'message' => {'content' => 'Tool response'}}]}))
    @client.instance_variable_set(:@client, mock_client)

    result = @client.chat('Use tool', tools: ['test_function'])
    assert_equal 'Tool response', result

    TestChatFunction.disable
  end

  def test_clear_context
    mock_client = mock()
    mock_client.expects(:chat).returns(OpenStruct.new(data: {'choices' => [{'message' => {'content' => 'Test'}}]}))
    @client.instance_variable_set(:@client, mock_client)

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
end
