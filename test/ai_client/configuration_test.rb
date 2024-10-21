# test/configuration_test.rb

require_relative '../test_helper'

class AiClient::ConfigurationTest < Minitest::Test
  def setup
    # Reset the class-level configuration before each test
    AiClient.class_config = AiClient.default_config.dup
    AiClient.class_config.merge!(logger: Logger.new(STDOUT))
  end

  def test_default_configuration
    client = AiClient.new('gpt-3.5-turbo')
    assert_equal Logger, client.logger.class
    assert_nil client.timeout
    assert_equal false, client.raw?
  end

  def test_indifferent_access_class_config
    AiClient.class_config.timeout = 10
    assert_equal 10, AiClient.class_config.timeout
    assert_equal 10, AiClient.class_config[:timeout]
    assert_equal 10, AiClient.class_config['timeout']
  end

  def test_indifferent_access_instance_config
    client = AiClient.new('gpt-3.5-turbo')

    client.config.timeout = 10
    assert_equal 10, client.config.timeout
    assert_equal 10, client.config[:timeout]
    assert_equal 10, client.config['timeout']
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

  def test_instance_config_from_file_suppliment
    assert_nil AiClient.class_config.timeout

    filepath = Pathname.new(__dir__) + 'config.yml'
    client = AiClient.new('gpt-3.5-turbo', config: filepath)

    assert_equal 10, client.config.timeout
  end

  def test_config_load
    filepath = Pathname.new(__dir__) + 'config.yml'
    my_config = AiClient::Config.load filepath

    assert_equal AiClient::Config, my_config.class
    assert_equal [:timeout], my_config.keys
    assert_equal 10, my_config.timeout
  end

  def test_config_merge_of_hash
    filepath = Pathname.new(__dir__) + 'config.yml'
    my_config = AiClient::Config.load filepath
    my_hash   = {
      xyzzy:      'Magic',
      fourty_two:  'Life, the Universe and Everything',
      'was_string' => 'All keys are Symbols'
    }

    my_config.merge! my_hash

    assert_equal AiClient::Config, my_config.class
    assert_equal [:timeout, :xyzzy, :fourty_two, :was_string], my_config.keys


  end
end
