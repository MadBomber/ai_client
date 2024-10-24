#!/usr/bin/env ruby
# examples/text.rb
#
# This example demonstrates basic text chat functionality with different models
# and providers. It shows both default (processed) and raw responses.

require_relative 'common'

###################################
## Basic Chat with Local Model

title "1. Basic Chat with Local Ollama Model"

# Configure client to return processed text content
AiClient.configure do |o|
  o.return_raw = false
end

# Create client using local Ollama model
ollama_client = AiClient.new('mistral', provider: :ollama)

puts "\nSimple chat example:"
result = ollama_client.chat('Hello, how are you?')
puts result

puts "\nRaw response for inspection:"
puts ollama_client.response.pretty_inspect
puts

###################################
## Multi-Provider Example

title "2. Chat Across Different Providers"

# Example models from different providers
models = [
  'gpt-3.5-turbo',        # OpenAI
  'claude-2.1',           # Anthropic
  'gemini-1.5-flash',     # Google
  'mistral-large-latest', # Mistral
]

# Create clients for each model
clients = models.map { |model| AiClient.new(model) }

# Test with default configuration (processed responses)
title "Default Configuration (Processed Text)"

clients.each do |c|
  puts "\nModel: #{c.model}  Provider: #{c.provider}"
  begin
    response = c.chat('hello')
    puts response
  rescue => e
    puts "Error: #{e.message}"
  end
end

###################################
## Raw Response Example

title "3. Raw Response Example"

# Configure for raw responses
AiClient.configure do |o|
  o.return_raw = true
end

# Create new clients with raw configuration
raw_clients = models.map { |model| AiClient.new(model) }

puts "\nRaw Configuration Responses:"
raw_clients.each do |c|
  puts "\nModel: #{c.model}  Provider: #{c.provider}"
  begin
    result = c.chat('hello')
    puts result.pretty_inspect
  rescue => e
    puts "Error: #{e.message}"
  end
end

puts
