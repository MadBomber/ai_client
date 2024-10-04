# test/configuration_test.rb

require_relative '../test_helper'

class AiClient::ConfigurationTest < Minitest::Test
  def setup
    # Reset the class-level configuration before each test
    AiClient.class_config = AiClient.default_config.dup
  end

  def test_default_configuration
    client = AiClient.new('gpt-3.5-turbo')
    assert_equal Logger, client.logger.class
    assert_nil client.timeout
    assert_equal false, client.raw?
  end

  def test_client_specific_configuration
    client = AiClient.new('gpt-3.5-turbo') do |config|
      config.timeout    = 10
      config.return_raw = true
    end

    assert_equal 10, client.timeout
    assert_equal true, client.raw?
  end

  def test_multiple_clients_with_different_configurations
    client1 = AiClient.new('gpt-3.5-turbo') do |config|
      config.return_raw = true
    end

    client2 = AiClient.new('claude') do |config|
      config.return_raw = false
    end

    assert_equal true, client1.raw?
    assert_equal false, client2.raw?
  end

  def test_global_configuration_change
    # Apply a global configuration change
    AiClient.configure do |config|
      config.timeout = 15
    end

    client = AiClient.new('gpt-3.5-turbo')
    assert_equal 15, client.timeout
  end

  def test_independent_instance_modification
    client = AiClient.new('gpt-3.5-turbo')

    # Modify the instance config 
    client.raw = true
    assert_equal true, client.raw?

    # Create another instance to ensure separation
    another_client = AiClient.new('claude')
    assert_equal false, another_client.raw?  # verify another instance remains unchanged
  end
end
