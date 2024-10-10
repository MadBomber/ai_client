# lib/ai_client/llm.rb

require 'active_hash'
require 'yaml'


class AiClient
  class LLM < ActiveHash::Base
    DATA_PATH = Pathname.new( __dir__ + '/models.yml')
    self.data = YAML.parse(DATA_PATH.read).to_ruby 

    def model     = id.split('/')[1]
    def provider  = id.split('/')[0]
  end

  class << self
    def reset_llm_data
      orc_models = AiClient.orc_client.models
      AiClient::LLM.data = orc_models
      AiClient::LLM::DATA_PATH.write(orc_models.to_yaml)
    end
  end
end
