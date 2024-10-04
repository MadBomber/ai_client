# test/ai_client/middleware_test.rb

require_relative '../test_helper'

class AiClient::MiddlewareTest < Minitest::Test
  def setup
    @model = 'gpt-3.5-turbo'
  end

  def test_middleware
    AiClient.clear_middlewares
    AiClient.use(TestMiddleware)
    local_client = AiClient.new(@model)
    
    local_client.raw = false

    mock_client = mock()
    mock_client.expects(:chat).returns(OpenStruct.new(data: {'choices' => [{'message' => {'content' => 'Generated text'}}]}))
    local_client.instance_variable_set(:@client, mock_client)

    result = local_client.chat([{role: 'user', content: 'Hello'}])
    assert_equal "Generated text - Processed by TestMiddleware", result
  end


  def test_middleware_chain_order
    AiClient.clear_middlewares
    AiClient.use(Middleware1)
    AiClient.use(Middleware2)

    # NOTE: that the middleware must ve setup BEFORE
    #       an instance of the AiClient is created.
    local_client = AiClient.new(@model)

    mock_client = mock()
    mock_client.expects(:chat).returns(OpenStruct.new(data: {'choices' => [{'message' => {'content' => 'Generated text'}}]}))
    local_client.instance_variable_set(:@client, mock_client)

    result = local_client.chat([{role: 'user', content: 'Hello'}])

    assert_equal 'Generated text two one', result
  end


end


class TestMiddleware
  def self.call(client, next_middleware, *args)
    result = next_middleware.call
    result.data['choices'][0]['message']['content'] += " - Processed by TestMiddleware"
    result
  end
end


class Middleware1
  def self.call(client, next_middleware, *args)
    client.instance_variable_set(:@middleware1_called, true)
    result = next_middleware.call
    result.data['choices'][0]['message']['content'] += " one"
    result
  end
end


class Middleware2
  def self.call(client, next_middleware, *args)
    client.instance_variable_set(:@middleware2_called, true)
    result = next_middleware.call
    result.data['choices'][0]['message']['content'] += " two"
    result
  end
end
