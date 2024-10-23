require_relative '../test_helper'

class EmbedTest < Minitest::Test
  def setup
    # Use Ollama
    @model  = 'nomic-embed-text'
    @client = AiClient.new(@model)
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
end
