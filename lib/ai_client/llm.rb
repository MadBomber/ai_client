# lib/ai_client/llm.rb

require 'active_hash'
require 'yaml'


class AiClient
  class LLM < ActiveHash::Base
    DATA_PATH = Pathname.new( __dir__ + '/models.yml')
    self.data = YAML.parse(DATA_PATH.read).to_ruby 

    scope :providers,  -> {all.map(&:provider).uniq.map(&:to_sym)}

    scope :models, ->(substring=nil) do
      (substring.nil? ? all : all.where(id: /#{substring}/i))
        .map(&:model).sort.uniq
    end

    # Extracts the model name from the LLM ID.
    #
    # @return [String] the model name.
    #
    def model     = id.split('/')[1]

    # Extracts the provider name from the LLM ID.
    #
    # @return [Symbol] the provider name.
    #
    def provider  = id.split('/')[0].to_sym
  
    def to_h = attributes

  end

  class << self
    
    # Resets the LLM data by fetching models from the Orc client
    # and writing it to the models.yml file.
    #
    # @return [void] 
    #
    def reset_llm_data
      orc_models = AiClient.orc_client.models
      AiClient::LLM.data = orc_models
      AiClient::LLM::DATA_PATH.write(orc_models.to_yaml)
    end

  end
end
