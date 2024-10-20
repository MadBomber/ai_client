# test/p[em_router_extensions_test.rb

require_relative '../test_helper'


class OpenRouterExtensionsTest < Minitest::Test
  def setup
    @ai_client = AiClient.new('gpt-3.5-turbo')
  end
  
  def test_model_details_returns_hash    
    result = @ai_client.model_details
    assert_instance_of AiClient::LLM, result
    assert_equal 'openai/gpt-3.5-turbo', result[:id]
  end

  def test_models_returns_array_of_strings    
    result = @ai_client.models
    expected = [
      "o1-mini-2024-09-12", 
      "o1-mini", 
      "o1-preview-2024-09-12", 
      "o1-preview", 
      "chatgpt-4o-latest", 
      "gpt-4o-2024-08-06", 
      "gpt-4o-mini-2024-07-18", 
      "gpt-4o-mini", 
      "gpt-4o-2024-05-13", 
      "gpt-4o", 
      "gpt-4o:extended", 
      "gpt-4-turbo", 
      "gpt-4-turbo-preview", 
      "gpt-3.5-turbo-0613", 
      "gpt-4-vision-preview", 
      "gpt-4-1106-preview", 
      "gpt-3.5-turbo-1106", 
      "gpt-3.5-turbo-instruct", 
      "gpt-4-32k-0314", 
      "gpt-4-32k", 
      "gpt-3.5-turbo-16k", 
      "gpt-4-0314", 
      "gpt-4", 
      "gpt-3.5-turbo-0301", 
      "gpt-3.5-turbo-0125", 
      "gpt-3.5-turbo"
    ].sort
    assert_equal expected, result.sort
  end

  def test_providers_returns_array_of_symbols
    result = AiClient.providers
    expected = [
      :google, 
      :liquid, 
      :thedrummer, 
      :"eva-unit-01", 
      :"anthracite-org", 
      :"meta-llama", 
      :qwen, 
      :neversleep, 
      :openai, 
      :mistralai, 
      :cohere, 
      :sao10k, 
      :ai21, 
      :microsoft, 
      :nousresearch, 
      :perplexity, 
      :aetherwiing, 
      :nothingiisreal, 
      :alpindale, 
      :anthropic, 
      :cognitivecomputations, 
      :deepseek, 
      :databricks, 
      :sophosympatheia, 
      :gryphe, 
      :openchat, 
      :teknium, 
      :lizpreciatior, 
      :undi95, 
      :openrouter, 
      :jondurbin, 
      :"xwin-lm", 
      :pygmalionai, 
      :huggingfaceh4, 
      :mancer
    ].sort

    assert_equal expected, result.sort
  end

  def test_models_with_provider_filters_models
    result = AiClient.models(:openai)
    expected = [
      "o1-mini-2024-09-12", 
      "o1-mini", 
      "o1-preview-2024-09-12", 
      "o1-preview", 
      "chatgpt-4o-latest", 
      "gpt-4o-2024-08-06", 
      "gpt-4o-mini-2024-07-18", 
      "gpt-4o-mini", 
      "gpt-4o-2024-05-13", 
      "gpt-4o", 
      "gpt-4o:extended", 
      "gpt-4-turbo", 
      "gpt-4-turbo-preview", 
      "gpt-3.5-turbo-0613", 
      "gpt-4-vision-preview", 
      "gpt-4-1106-preview", 
      "gpt-3.5-turbo-1106", 
      "gpt-3.5-turbo-instruct", 
      "gpt-4-32k-0314", 
      "gpt-4-32k", 
      "gpt-3.5-turbo-16k", 
      "gpt-4-0314", 
      "gpt-4", 
      "gpt-3.5-turbo-0301", 
      "gpt-3.5-turbo-0125", 
      "gpt-3.5-turbo"
    ].sort

    assert_equal expected, result.sort
  end

  def test_model_details_with_specific_model    
    result = AiClient.model_details('openai/gpt-3.5-turbo')
    assert_equal('openai/gpt-3.5-turbo', result[:id])
  end

  def test_models_returns_matching_models    
    result = AiClient.models('turbo')
    expected = [
      "gpt-4-turbo", 
      "gpt-4-turbo-preview", 
      "gpt-3.5-turbo-0613", 
      "gpt-3.5-turbo-1106", 
      "gpt-3.5-turbo-instruct", 
      "gpt-3.5-turbo-16k", 
      "gpt-3.5-turbo-0301", 
      "gpt-3.5-turbo-0125", 
      "gpt-3.5-turbo"
    ].sort
    assert_equal expected, result.sort
  end

  def test_add_open_router_extensions_without_access_token
    skip
    OpenRouter.expects(:configure).never
    AiClient.expects(:fetch_access_token).returns(nil)

    AiClient.add_open_router_extensions
  end

  def test_add_open_router_extensions_with_access_token
    skip
    OpenRouter.expects(:configure).with { |&block| block.call }
    AiClient.expects(:fetch_access_token).returns('some_token')

    AiClient.add_open_router_extensions
  end

  def test_orc_client_initialization
    skip
    OpenRouter::Client.expects(:new).returns(mock)
    client = AiClient.orc_client
    assert_instance_of OpenRouter::Client, client
  end

  def test_reset_llm_data
    skip
    models_data = [{ id: 'model1' }, { id: 'model2' }]
    @ai_client.class.stubs(:orc_models).returns(models_data)
    LLM.expects(:data=).with(models_data)
    LLM::DATA_PATH.expects(:write).with(models_data.to_yaml)

    @ai_client.class.reset_llm_data
  end
end
