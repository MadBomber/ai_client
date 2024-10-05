# lib/ai_client/embed.rb

class AiClient

  ######################################
  # OmniAI Params
  #   model [String] required
  #

  def embed(input, **params)
    @client.embed(input, model: @model, **params)
  end

  def batch_embed(inputs, batch_size: 100, **params)
    inputs.each_slice(batch_size).flat_map do |batch|
      sleep 1 # DEBUG rate limits being exceeded
      embed(batch, **params)
    end
  end

end
