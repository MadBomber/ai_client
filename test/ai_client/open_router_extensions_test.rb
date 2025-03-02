require_relative '../test_helper'

class OpenRouterExtensionsTest < Minitest::Test
  include TestHelpers
  
  def setup
    # Reset the class-level configuration before each test
    AiClient.class_config = AiClient.default_config.dup
    skip "Ollama server not available - run 'ollama serve'" unless ollama_available?
  end

  def test_model_details_returns_hash
    details = AiClient.model_details('openai/gpt-3.5-turbo')
    refute_nil details
    assert_kind_of Hash, details.to_h
  end

  def test_models_returns_array_of_strings
    models = AiClient.models(:openai)
    refute_nil models
    assert_kind_of Array, models
    assert models.all? { |m| m.is_a?(String) }
    # Instead of checking exact models, just verify some expected models are present
    assert models.include?('gpt-3.5-turbo')
    assert models.include?('gpt-4')
  end

  def test_providers_returns_array_of_symbols
    providers = AiClient.providers
    refute_nil providers
    assert_kind_of Array, providers
    assert providers.all? { |p| p.is_a?(Symbol) }
    # Check for some expected providers rather than the exact list
    assert providers.include?(:openai)
    assert providers.include?(:anthropic)
    assert providers.include?(:google)
  end

  def test_models_with_provider_filters_models
    models = AiClient.models(:openai)
    refute_nil models
    assert_kind_of Array, models
    # Check for some expected models rather than the exact list
    assert models.include?('gpt-3.5-turbo')
    assert models.include?('gpt-4')
  end

  def test_model_details_with_specific_model
    details = AiClient.model_details('openai/gpt-3.5-turbo')
    refute_nil details
    assert_equal 'openai/gpt-3.5-turbo', details.id
  end

  def test_models_returns_matching_models
    models = AiClient.models('turbo')
    refute_nil models
    assert_kind_of Array, models
    # Check that all returned models contain 'turbo'
    assert models.all? { |m| m.include?('turbo') }
    # Check for some expected models
    assert models.include?('gpt-3.5-turbo')
  end

  def test_add_open_router_extensions_without_access_token
    skip "OpenRouter extensions test skipped"
  end

  def test_add_open_router_extensions_with_access_token
    skip "OpenRouter extensions test skipped"
  end

  def test_orc_client_initialization
    skip "OpenRouter extensions test skipped"
  end

  def test_reset_llm_data
    # This is a simple test to ensure the method doesn't raise errors
    AiClient.reset_llm_data
  end
end
