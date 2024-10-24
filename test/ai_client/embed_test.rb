require_relative '../test_helper'

class EmbedTest < Minitest::Test
  def setup
    # Use Ollama
    @model  = 'nomic-embed-text'
    @client = AiClient.new(@model)
  end

  def test_basic_embed_functionality
    mock_client = mock()
    input = "test text"
    expected_embedding = [0.1, 0.2, 0.3]
    
    mock_client.expects(:embed).with(input, model: @model).returns(expected_embedding)
    @client.instance_variable_set(:@client, mock_client)
    
    result = @client.embed(input)
    assert_equal expected_embedding, result
  end

  def test_embed_with_additional_params
    mock_client = mock()
    input = "test text"
    params = { temperature: 0.7 }
    
    mock_client.expects(:embed).with(input, model: @model, temperature: 0.7).returns([0.1])
    @client.instance_variable_set(:@client, mock_client)
    
    result = @client.embed(input, **params)
    assert_equal [0.1], result
  end

  def test_batch_embed_handles_empty_input
    result = @client.batch_embed([])
    assert_equal [], result
  end

  def test_batch_embed_respects_batch_size
    mock_client = mock()
    inputs = ['text1', 'text2', 'text3']

    mock_client.expects(:embed).with(['text1', 'text2'], model: @model).returns([0.1, 0.2])
    mock_client.expects(:embed).with(['text3'], model: @model).returns([0.3])

    @client.instance_variable_set(:@client, mock_client)

    result = @client.batch_embed(inputs, batch_size: 2)
    assert_equal [0.1, 0.2, 0.3], result
  end

  def test_batch_embed_handles_errors
    mock_client = mock()
    mock_client.expects(:embed).raises(StandardError.new("API error"))
    @client.instance_variable_set(:@client, mock_client)

    assert_raises(StandardError) do
      @client.batch_embed(['text1'])
    end
  end

  def test_batch_embed_with_custom_params
    mock_client = mock()
    inputs = ['text1', 'text2']
    params = { temperature: 0.7 }

    mock_client.expects(:embed)
              .with(['text1', 'text2'], model: @model, temperature: 0.7)
              .returns([0.1, 0.2])

    @client.instance_variable_set(:@client, mock_client)

    result = @client.batch_embed(inputs, batch_size: 2, **params)
    assert_equal [0.1, 0.2], result
  end

  def test_batch_embed_enforces_rate_limiting
    mock_client = mock()
    inputs = ['text1', 'text2', 'text3']
    
    # Sleep happens at the start of each batch
    sequence = sequence('batch_sequence')
    
    @client.expects(:sleep).with(1).in_sequence(sequence)
    mock_client.expects(:embed)
              .with(['text1'], model: @model)
              .returns([0.1])
              .in_sequence(sequence)
    
    @client.expects(:sleep).with(1).in_sequence(sequence)
    mock_client.expects(:embed)
              .with(['text2'], model: @model)
              .returns([0.2])
              .in_sequence(sequence)
    
    @client.expects(:sleep).with(1).in_sequence(sequence)
    mock_client.expects(:embed)
              .with(['text3'], model: @model)
              .returns([0.3])
              .in_sequence(sequence)

    @client.instance_variable_set(:@client, mock_client)

    result = @client.batch_embed(inputs, batch_size: 1)
    assert_equal [0.1, 0.2, 0.3], result
  end
end
