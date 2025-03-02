# lib/ai_client/xai.rb

module AiClient
  module XAI
    class Client
      BASE_URI = 'https://api.x.ai/v1' # Replace with actual xAI API endpoint

      def initialize(api_key: ENV['XAI_API_KEY'])
        @api_key = api_key
        @connection = OmniAI::HTTP::Connection.new(BASE_URI)
      end

      def chat(prompt:, model: 'grok3', **options)
        response = @connection.post(
          '/chat/completions', # Adjust endpoint based on xAI API docs
          headers: { 'Authorization' => "Bearer #{@api_key}", 'Content-Type' => 'application/json' },
          body: {
            model: model,
            messages: [{ role: 'user', content: prompt }],
            temperature: options[:temperature] || 0.7,
            max_tokens: options[:max_tokens] || 1024
          }.to_json
        )
        parse_response(response)
      end

      private

      def parse_response(response)
        json = JSON.parse(response.body)
        json['choices'][0]['message']['content'] # Adjust based on actual response structure
      end
    end
  end
end
