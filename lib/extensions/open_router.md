# Notes on OpenRouter

OpenROuter is a web service that has a common API to many
back-end LLM processors.  Its goal is basically the same as the
OmniAI gem - provide the flexibility of using multiple models
processed by myltiple providers.

```ruby
OpenRouter.configure do |config|
  config.access_token = ENV.fetch('OPEN_ROUTER_API_KEY', nil)
end

# Use a default provider/model
AI = OpenRouter::Client.new

# Returns an Array of Hash for supported 
# models/providers
Models = AI.models
```

models with a "/" are targeted to open router.
  before the "/" is the provider after it is the model name

Will need to add this entriy to the AiClient::Config `provider_patterns` Hash:

```ruby
open_router: /\//,  # /(.*)\/(.*)/  provider / model name
```

models can be an Array of Strings.  The first is the primary while
the rest are fallbacks in case there is one before fails

```ruby
{
  "models": ["anthropic/claude-2.1", "gryphe/mythomax-l2-13b"],
  "route": "fallback",
  ... // Other params
}
```

You can have OpenRouter send your prompt to the best
provider/model for the prompt like this:

```ruby
require "open_router"

OpenRouter.configure do |config|
  config.access_token = ENV["ACCESS_TOKEN"]
  config.site_name = "YOUR_APP_NAME"
  config.site_url = "YOUR_SITE_URL"
end

OpenRouter::Client.new.complete(
  model: "openrouter/auto",
  messages: [
    {
      "role": "user",
      "content": "What is the meaning of life?"
    }
  ]
).then do |response|
  puts response.dig("choices", 0, "message", "content")
end
```

OpenRouter can also support OpenAI's API by using this
  base_url: "https://openrouter.ai/api/v1",

Request Format Documentation
  https://openrouter.ai/docs/requests

Simple Quick Start ...

```ruby
OpenRouter::Client.new.complete(
  model: "openai/gpt-3.5-turbo",
  messages: [
    {
      "role": "user",
      "content": "What is the meaning of life?"
    }
  ]
).then do |response|
  puts response.dig("choices", 0, "message", "content")
end
```

## Design Approaches

There are at least two different approaches to
integrate the OpenRouter capability.  1) Use the open_router gem
and forget about using the same common-ish
API established by OmniAI; or 2) Take advantage
or OpenRouter's OpenAI's API and do for it
the same thing that was done of Ollama and LocalAI.


