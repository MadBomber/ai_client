# lib/extensions/omniai-open_router.rb
# frozen_string_literal: true

require 'omniai'
require 'omniai/openai'

module OmniAI

  # Create an alias for OmniAI::OpenAI module
  module OpenRouter
    extend OmniAI::OpenAI

    # Alias classes from OmniAI::OpenAI
    class Client < OmniAI::OpenAI::Client
      def initialize(**options)
        options[:host] = 'https://openrouter.ai/api/v1' unless options.has_key?(:host)
        super(**options)
      end
    end    

    Config = OmniAI::OpenAI::Config

    # Alias the Thread class and its nested classes
    Thread      = OmniAI::OpenAI::Thread
    Annotation  = OmniAI::OpenAI::Thread::Annotation
    Attachment  = OmniAI::OpenAI::Thread::Attachment
    Message     = OmniAI::OpenAI::Thread::Message
    Run         = OmniAI::OpenAI::Thread::Run
  end
end


class AiClient

  class << self
    def orc_models
      @orc_models ||= ORC.models if defined?(ORC)
    end

    def orc_model_names(provider=nil)
      if provider.nil?
        orc_models.map{|e| e['id']}
      else
        orc_models
          .map{|e| e['id']}
          .select{|name| name.start_with? provider.to_s.downcase}
          .map{|e| e.split('/')[1]}
      end
    end

    def orc_model_details(model)
      ap orc_models.select{|e| e['id'] == model}
    end
  end
end

if ENV.fetch('OPEN_ROUTER_API_KEY', nil)
  OpenRouter.configure do |config|
    config.access_token = ENV.fetch('OPEN_ROUTER_API_KEY', nil)
  end

  # Use a default provider/model
  ORC = OpenRouter::Client.new
end


