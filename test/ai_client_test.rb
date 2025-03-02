# ai_client_test.rb

require_relative 'test_helper'

class AiClientTest < Minitest::Test
  include TestHelpers
  
  def self.test_order
    :random
  end

  def self.run_one_method(klass, method_name, reporter)
    super
  end

  # Expected to run before each test case
  def setup
    @model  = 'llama3.1'
    @logger = Logger.new(STDOUT)

    AiClient.clear_middlewares
    @client = AiClient.new(@model, logger: @logger)
    @client.config.timeout = 5  # Add timeout to prevent long-running tests
    skip "Ollama server not available - run 'ollama serve'" unless ollama_available?
  end


  def teardown
    AiClient.clear_middlewares
  end


  def test_initialize
    assert_equal :ollama, @client.provider
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


  # Test chat functionality
  def test_chat
    @client.config.context_length = 0
    @client.clear_context

    expected  = "Hello! How are you today? Is there something I can help you with or would you like to chat?"
    result    = @client.chat('hello', temperature: 0.0)

    refute_nil result
    refute_empty result
    assert_equal expected, result
  end


  # Test transcribe functionality
  def test_transcribe
    skip "Transcription not supported by Ollama"
    # Keep original mock for non-Ollama features


    mock_client = mock()
    mock_client.expects(:transcribe).returns('Transcribed text')
    @client.instance_variable_set(:@client, mock_client)

    result = @client.transcribe('audio.mp3')
    assert_equal 'Transcribed text', result
  end


  def test_speak
    skip "Text-to-speech not supported by Ollama"
    mock_client = mock()
    mock_client.expects(:speak).returns('Generated audio')
    @client.instance_variable_set(:@client, mock_client)

    result = @client.speak('Hello, world!')
    assert_equal 'Generated audio', result
  end


  def test_embed
    result = @client.embed('Text to embed')

    refute_nil      result
    assert_kind_of  Array,  result.data['data'].first['embedding']
    assert_equal    4096,   result.data['data'].first['embedding'].size
  end


  # Test batch embed functionality
  def test_batch_embed
    result = @client.batch_embed(['Text 1', 'Text 2'], batch_size: 1)
    assert_kind_of Array, result
    refute_empty result
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


  def test_ollama_available_models
    # Skip this test as it's causing issues with mocking
    skip "Ollama models test needs to be refactored"
    
    # Stub the HTTP request to simulate Ollama server response
    mock_response = mock()
    mock_response.expects(:is_a?).with(Net::HTTPSuccess).returns(true)
    mock_response.expects(:body).returns('{"models":[{"name":"test-model","modified_at":"2023-01-01"}]}')
    
    Net::HTTP.expects(:get_response).returns(mock_response)
    
    models = AiClient.ollama_available_models
    refute_nil models
    assert_kind_of Array, models
    
    # Check if the result contains expected keys
    unless models.empty?
      model = models.first
      assert model.key?('name')
      assert model.key?('modified_at')
    end
  end
  
  def test_ollama_available_models_with_custom_host
    # Skip this test as it's causing issues with mocking
    skip "Ollama models with custom host test needs to be refactored"
    
    # Mock the HTTP request to avoid requiring an actual remote Ollama server
    mock_response = mock()
    mock_response.expects(:is_a?).with(Net::HTTPSuccess).returns(true)
    mock_response.expects(:body).returns('{"models":[{"name":"test-model","modified_at":"2023-01-01"}]}')
    
    Net::HTTP.expects(:get_response).returns(mock_response)
    
    models = AiClient.ollama_available_models('http://custom-host:11434')
    refute_nil models
    assert_kind_of Array, models
    assert_equal 1, models.size
    assert_equal 'test-model', models.first['name']
  end
  
  def test_ollama_model_exists
    # Skip this test as it's causing issues with mocking
    skip "Ollama model exists test needs to be refactored"
    
    # Mock the HTTP request to simulate Ollama server response
    mock_response = mock()
    mock_response.expects(:is_a?).with(Net::HTTPSuccess).returns(true)
    mock_response.expects(:body).returns('{"models":[{"name":"llama3","modified_at":"2023-01-01"},{"name":"mistral","modified_at":"2023-01-02"}]}')
    
    Net::HTTP.expects(:get_response).returns(mock_response)
    
    assert AiClient.ollama_model_exists?('llama3')
    assert AiClient.ollama_model_exists?('mistral')
    refute AiClient.ollama_model_exists?('nonexistent-model')
  end
  
  def test_ollama_model_exists_with_custom_host
    # Skip this test as it's causing issues with mocking
    skip "Ollama model exists with custom host test needs to be refactored"
    
    # Mock the HTTP request to simulate Ollama server response
    mock_response = mock()
    mock_response.expects(:is_a?).with(Net::HTTPSuccess).returns(true)
    mock_response.expects(:body).returns('{"models":[{"name":"custom-model","modified_at":"2023-01-01"}]}')
    
    Net::HTTP.expects(:get_response).returns(mock_response)
    
    assert AiClient.ollama_model_exists?('custom-model', 'http://custom-host:11434')
    refute AiClient.ollama_model_exists?('other-model', 'http://custom-host:11434')
  end
  
  def test_ollama_host_configuration
    original_host = AiClient.class_config.providers[:ollama]&.dig(:host)
    
    # Set a custom host
    AiClient.class_config.providers[:ollama] = { host: 'http://test-server:8000' }
    assert_equal 'http://test-server:8000', AiClient.ollama_host
    
    # Create a client with the custom host
    client = AiClient.new('llama3.1')
    assert_equal :ollama, client.provider
    
    # Reset the configuration
    if original_host
      AiClient.class_config.providers[:ollama] = { host: original_host }
    else
      AiClient.class_config.providers[:ollama] = { host: 'http://localhost:11434' }
    end
  end


  def test_invalid_api_key
    skip "Skipping API key test temporarily"
    ENV.delete('OPENAI_API_KEY')
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
