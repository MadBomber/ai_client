# ai_client_test.rb

require_relative 'test_helper'

class AiClientTest < Minitest::Test
  # SMELL:  There are at least 3 unit tests that
  #         failing randomly when the tests are run
  #         run in a random order.  Changed the order
  #         to normal in hopes that I can find
  #         what data is being polluted between
  #         the unit tests.
  #
  def self.test_order
    :random
  end


  # Override the run method to print the test name before executing it
  def self.run_one_method(klass, method_name, reporter)
    # puts "  Running #{method_name}"
    super
  end


  # Expected to run before each test case
  def setup
    @model  = 'gpt-3.5-turbo'
    @logger = Logger.new(STDOUT)

    AiClient.clear_middlewares
    @client = AiClient.new(@model, logger: @logger)
  end


  def teardown
    AiClient.clear_middlewares
  end


  def test_initialize
    assert_equal :openai, @client.provider
    assert_equal @logger, @client.logger
  end


  def test_determine_provider
    assert_equal :anthropic, @client.send(:determine_provider, 'claude-2')
    assert_equal :openai, @client.send(:determine_provider, 'gpt-4')
    assert_equal :google, @client.send(:determine_provider, 'gemini-pro')
    assert_equal :mistral, @client.send(:determine_provider, 'mistral-medium')
    assert_equal :localai, @client.send(:determine_provider, 'local-model')
    assert_equal :ollama, @client.send(:determine_provider, 'llama-7b')

    assert_raises(ArgumentError) { @client.send(:determine_provider, 'unknown-model') }
  end


  def test_chat
    mock_client = mock()
    mock_client.expects(:chat).returns(OpenStruct.new(data: {'choices' => [{'message' => {'content' => 'Generated text'}}]}))
    @client.instance_variable_set(:@client, mock_client)

    result = @client.chat([{role: 'user', content: 'Hello'}])
    
    assert_equal "Generated text", result
  end



  def test_transcribe
    mock_client = mock()
    mock_client.expects(:transcribe).returns('Transcribed text')
    @client.instance_variable_set(:@client, mock_client)

    result = @client.transcribe('audio.mp3')
    assert_equal 'Transcribed text', result
  end


  def test_speak
    mock_client = mock()
    mock_client.expects(:speak).returns('Generated audio')
    @client.instance_variable_set(:@client, mock_client)

    result = @client.speak('Hello, world!')
    assert_equal 'Generated audio', result
  end


  def test_embed
    mock_client = mock()
    mock_client.expects(:embed).returns([0.1, 0.2, 0.3])
    @client.instance_variable_set(:@client, mock_client)

    result = @client.embed('Text to embed')
    assert_equal [0.1, 0.2, 0.3], result
  end


  def test_batch_embed
    mock_client = mock()
    mock_client.expects(:embed).twice.returns([0.1, 0.2, 0.3])
    @client.instance_variable_set(:@client, mock_client)

    result = @client.batch_embed(['Text 1', 'Text 2'], batch_size: 1)
    assert_equal [0.1, 0.2, 0.3, 0.1, 0.2, 0.3], result
  end


  def test_content_extraction
    @client.instance_variable_set(:@provider, :openai)
    @client.instance_variable_set(:@last_response, OpenStruct.new(data: {'choices' => [{'message' => {'content' => 'OpenAI content'}}]}))
    assert_equal 'OpenAI content', @client.content

    @client.instance_variable_set(:@provider, :anthropic)
    @client.instance_variable_set(:@last_response, OpenStruct.new(data: {'content' => [{'text' => 'Anthropic content'}]}))
    assert_equal 'Anthropic content', @client.content

    @client.instance_variable_set(:@provider, :google)
    @client.instance_variable_set(:@last_response, OpenStruct.new(data: {'candidates' => [{'content' => {'parts' => [{'text' => 'Google content'}]}}]}))
    assert_equal 'Google content', @client.content

    @client.instance_variable_set(:@provider, :mistral)
    @client.instance_variable_set(:@last_response, OpenStruct.new(data: {'choices' => [{'message' => {'content' => 'Mistral content'}}]}))
    assert_equal 'Mistral content', @client.content

    @client.instance_variable_set(:@provider, :unknown)
    assert_raises(NotImplementedError) { @client.content }
  end


  def test_invalid_model
    assert_raises(ArgumentError) { AiClient.new('invalid_model') }
  end


  def test_invalid_provider
    assert_raises(ArgumentError, "Unsupported provider: invalid_provider") do
      AiClient.new('gpt-3.5-turbo', provider: :invalid_provider)
    end
  end


  def test_raw_content_flag_when_true
    mock_client = mock()
    response_data = {'choices' => [{'message' => {'content' => 'Raw content'}}]}
    mock_client.expects(:chat).returns(OpenStruct.new(data: response_data))

    @client.instance_variable_set(:@client, mock_client)
    @client.instance_variable_set(:@last_response, OpenStruct.new(data: response_data))

    @client.raw = true
    result = @client.chat([{ role: 'user', content: 'Hello' }])
    assert_equal response_data, result.data
  end


  def test_raw_content_flag_when_false
    mock_client = mock()
    response_data = {'choices' => [{'message' => {'content' => 'Raw content'}}]}
    mock_client.expects(:chat).returns(OpenStruct.new(data: response_data))

    @client.instance_variable_set(:@client, mock_client)
    @client.instance_variable_set(:@last_response, OpenStruct.new(data: response_data))

    @client.raw = false
    result = @client.chat([{ role: 'user', content: 'Hello' }])
    assert_equal 'Raw content', result
  end


  def test_batch_embed_with_large_inputs
    mock_client = mock()
    mock_client.expects(:embed).returns([0.1, 0.2, 0.3]).twice
    @client.instance_variable_set(:@client, mock_client)

    large_input = Array.new(200) { |i| "Text #{i + 1}" }
    result = @client.batch_embed(large_input, batch_size: 100)
    assert_equal [0.1, 0.2, 0.3, 0.1, 0.2, 0.3], result
  end





  def test_invalid_api_key
    ENV['OPENAI_API_KEY'] = ''
    assert_raises(ArgumentError) { AiClient.new('gpt-3.5-turbo') }
    ENV['OPENAI_API_KEY'] = 'valid_api_key' # reset to avoid affecting other tests
  end


  def test_response_storage
    mock_client = mock()
    mock_client.expects(:chat).returns(OpenStruct.new(data: {'choices' => [{'message' => {'content' => 'Stored response'}}]}))
    @client.instance_variable_set(:@client, mock_client)

    @client.chat([{role: 'user', content: 'Store this'}])
    assert_equal 'Stored response', @client.last_response.data.dig('choices', 0, 'message', 'content')
  end
end

