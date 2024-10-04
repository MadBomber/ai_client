# test/ai_client/configuration_test.rb

require_relative '../test_helper'
require 'logger'
require 'hashie'

class AiClient::ConfigurationTest < Minitest::Test
  def setup
    # Initialize config using defaults
    @default_config = AiClient.config.dup
  end

  def test_initial_configuration
    config = AiClient.config

    assert_instance_of Logger, config.logger
    assert_nil config.timeout
    assert_equal false, config.return_raw
    assert_empty config.providers
    assert_equal AiClient::PROVIDER_PATTERNS, config.provider_patterns
    assert_equal AiClient::MODEL_TYPES, config.model_types
  end

  def test_configure_with_block
    AiClient.configure do |config|
      config.logger     = Logger.new('test.log')
      config.return_raw = true
    end

    assert_instance_of Logger, AiClient.config.logger
    assert_equal true, AiClient.config.return_raw
  end

  def test_provider_configuration_with_block
    AiClient.configure do |config|
      config.provider(:openai) do
        { organization: 'org-123', api_version: 'v1' }
      end
    end

    assert_equal({ organization: 'org-123', api_version: 'v1' }, AiClient.config.provider(:openai))
  end

  def test_provider_configuration_without_block
    AiClient.configure do |config|
      config.provider(:google) do
        { api_key: 'fake_key' }
      end
    end

    assert_equal({ api_key: 'fake_key' }, AiClient.config.provider(:google))
  end

  def test_provider_returns_empty_hash_if_not_configured
    assert_equal({}, AiClient.config.provider(:nonexistent_provider))
  end

  def test_configure_provider_can_be_overwritten
    AiClient.configure do |config|
      config.provider(:openai) do
        { organization: 'old-org' }
      end
    end

    AiClient.configure do |config|
      config.provider(:openai) do
        { organization: 'new-org', api_version: 'v2' }
      end
    end

    assert_equal({ organization: 'new-org', api_version: 'v2' }, AiClient.config.provider(:openai))
  end

  def test_instances_share_same_configuration
    AiClient.configure do |config|
      config.logger     = Logger.new('shared.log')
      config.return_raw = true
    end

    client1 = AiClient.new('gpt-3.5-turbo')
    client2 = AiClient.new('gpt-4')

    assert_equal client1.logger, client2.logger
    assert_equal client1.raw?, client2.raw?
    assert_instance_of Logger, client1.logger
    assert_instance_of Logger, client2.logger
  end

  def test_instances_have_different_configurations
    AiClient.configure do |config|
      config.logger = Logger.new('default.log')
      config.return_raw = false
    end

    client1 = AiClient.new('gpt-3.5-turbo')
    
    custom_config = Hashie::Mash.new(
      logger: Logger.new('custom.log'),
      return_raw: true
    )
    
    client2 = AiClient.new('gpt-4', config: custom_config)

    assert_equal 'custom.log', client2.logger.instance_variable_get(:@logdev).dev.path
    refute_equal client1.logger.instance_variable_get(:@logdev).dev.path, client2.logger.instance_variable_get(:@logdev).dev.path
    assert_equal client1.raw?, false
    assert_equal client2.raw?, true
  end

  def teardown
    File.delete('test.log') if File.exist?('test.log')
    File.delete('shared.log') if File.exist?('shared.log')
    File.delete('custom.log') if File.exist?('custom.log')
  end
end
