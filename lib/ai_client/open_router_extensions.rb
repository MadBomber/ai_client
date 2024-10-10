# lib/ai_client/open_router_extensions.rb
# frozen_string_literal: true

# These extensions to AiClient are only available with
# a valid API Key for the open_router.ai web-service

require 'open_router'
require 'yaml'

class AiClient

  def models                        = self.class.models
  def providers                     = self.class.providers
  def model_names(a_provider=nil)   = self.class.model_names(a_provider)
  def model_details(a_model)        = self.class.model_details(a_model)
  def find_model(a_model_substring) = self.class.find_model(a_model_substring)

  class << self
    def add_open_router_extensions
      access_token = fetch_access_token

      return unless access_token

      configure_open_router(access_token)
      initialize_orc_client
    end

    def orc_client
      @orc_client ||= add_open_router_extensions || raise("OpenRouter extensions are not available")
    end

    def orc_models
      @orc_models ||= orc_client.models
    end

    # TODO: Refactor these DB like methods to take
    #       advantage of AiClient::LLM

    def model_names(provider=nil)
      model_ids = models.map { _1['id'] }

      return model_ids unless provider

      model_ids.filter_map { _1.split('/')[1] if _1.start_with?(provider.to_s.downcase) }
    end

    def model_details(model)
      orc_models.find { _1['id'].include?(model) }
    end

    def providers
      @providers ||= models.map{ _1['id'].split('/')[0] }.sort.uniq      
    end

    def find_model(a_model_substring)
      model_names.select{ _1.include?(a_model_substring) }
    end
  
    def reset_llm_data
      LLM.data = orc_models
      LLM::DATA_PATH.write(orc_models.to_yaml)
    end


    private

    # Similar to fetch_api_key but for the class_config
    def fetch_access_token
      class_config.envar_api_key_names.open_router
                  .map { |key| ENV[key] }
                  .compact
                  .first
    end
    
    def configure_open_router(access_token)
      OpenRouter.configure { |config| config.access_token = access_token }
    end

    def initialize_orc_client
      @orc_client ||= OpenRouter::Client.new
    end
  end
end


AiClient.add_open_router_extensions
