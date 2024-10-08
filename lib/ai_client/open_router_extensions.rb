# lib/ai_client/open_router_extensions.rb
# frozen_string_literal: true

# These extensions to AiClient are only available with
# a valid API Key for the open_router.ai web-service

require 'open_router'

class AiClient
  class << self
    def add_open_router_extensions
      access_token = fetch_access_token

      return unless access_token

      configure_open_router(access_token)
      initialize_orc_client
    end

    private

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

    def orc_client
      @orc_client ||= add_open_router_extensions || raise("OpenRouter extensions are not available")
    end

    def orc_models
      @orc_models ||= orc_client.models
    end

    # Using named parameters for better readability
    def orc_model_names(provider: nil)
      model_ids = orc_models.map { _1['id'] }

      return model_ids unless provider

      model_ids.filter_map { _1.split('/')[1] if _1.start_with?(provider.to_s.downcase) }
    end

    def orc_model_details(model)
      orc_models.find { _1['id'].include?(model) }
    end

    def orc_providers
      @orc_providers ||= orc_models.map{ _1['id'].split('/')[0] }.sort.uniq      
    end
  end
end

AiClient.add_open_router_extensions
