# AiClient

First and foremost a big **THANK YOU** to [Kevin Sylvestre](https://ksylvest.com/) for his gem [OmniAI](https://github.com/ksylvest/omniai) and [Olympia](https://olympia.chat/) for their [open_router gem](https://github.com/OlympiaAI/open_router) upon which this effort depends.

See the  [change log](CHANGELOG.md) for recent modifications.

## Summary

Are you ready to supercharge your applications with cutting-edge AI capabilities? 
Introducing `ai_client`, the ultimate Ruby gem that provides a seamless interface 
for interacting with a multitude of AI service providers through a single, 
unified API. 

With `ai_client`, you can effortlessly integrate large language models (LLMs) 
into your projects—simply specify the model name and let the gem handle the 
rest! Say goodbye to tedious configuration and hello to rapid development.

This gem comes packed with built-in support for leading AI providers, including 
OpenAI, Anthropic, Google, Mistral, LocalAI, and Ollama. Whether you need to 
implement chatbots, transcription services, speech synthesis, or embeddings, 
`ai_client` abstracts the complexities of API interactions, allowing you to focus 
on what truly matters: building amazing applications.

Plus, with its flexible middleware architecture, you can easily customize request 
and response processing—implement logging, retry logic, and more with minimal effort. 
And thanks to its seamless integration with the `OmniAI` framework, you can leverage 
the latest AI advancements without worrying about vendor lock-in.

Join the growing community of developers who are transforming their applications 
with `ai_client`. Install it today and unlock the full potential of AI in your 
projects!


## Installation

If you are using a Gemfile and bundler in your project just install the gem by executing:

```bash
bundle add ai_client
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install ai_client
```

## Providers Supported

To explicitely designate a provider to use with an AiClient instance
use the parameter `provider: :your_provider` with the Symbol for the supported
provider you want to use with the model you specify.  The following providers
are supported by the OmniAI gem upon which AiClient depends along with a few
extensions.

| Symbol | Envar API Key | Client Source |
| --- | --- | --- |
| :anthropic | [ANTHROPIC_API_KEY](https://www.anthropic.com/) | OmniAI |
| :google | [GOOGLE_API_KEY](https://cloud.google.com/gemini) | OmniAI |
| :localai | [LOCALAI_API_KEY](https://localai.io/) | AiClient Extension |
| :mistral | [MISTRAL_API_KEY](https://mistral.ai/) | OmniAI |
| :ollama | [OLLAMA_API_KEY](https://ollama.com/) | AiClient Extension |
| :open_router | [OPEN_ROUTER_API_KEY](https://openrouter.ai/) | AiClient Extension |
| :openai | [OPENAI_API_KEY](https://www.openai.com/) | OmniAI |

In case you are using a different environment variable for your access token than the ones shown above you can use the `api_key:` parameter.

```ruby
client = AiClient.new('provider/model_name', api_key: ENV['OPENROUTER_API_KEY'])
```

This way if you are using `AiClient` inside of a Rails application you can retrieve your access token from a secretes file.

## Usage

Basic usage:

```ruby
AI = AiClient.new('gpt-4o')
```

That's it.  Just provide the model name that you want to use.  If you application is using more than one model, no worries, just create multiple AiClient instances.

```ruby
c1 = AiClient.new('nomic-embeddings-text')
c2 = AiClient.new('gpt-4o-mini')
```

You can also use the `provider:` parameter in the event that the model you want to use is available through multiple providers or that AiClient can not automatically associate the model name with a provider.


```ruby
AI = AiClient.new('nomic-embed-text', provider: :ollama)
```

### Configuration

There are three levels of configuration, each inherenting from the level above. The following sections
describe those configuration levels.

#### Default Configuration

The file [lib/ai_client/configuration.rb] hard codes the default configuration.  This is used to
update the [lib/ai_client/config.yml] file during development.  If you have
some changes for this configuration please send me a pull request so we
can all benefit from your efforts.

#### Class Configuration

The class configuration is derived initially from the default configuration.  It
can be changed in three ways.

1. Class Configuration Block

```ruby
AiClient.configuration do |config|
  config.some_item = some_value
  ...
end
```

2. Set by a Config File

```ruby
AiClient.class_config = AiClient::Config.load('path/to/file.yml')
```

3. Supplemented by a Config File

```ruby
AiClient.class_config.merge! AiClient::Config.load('path/to/file.yml')
```

#### Instance Configuration

All instances have a configuration.  Initially that configuration is the same
as the class configuration; however, each instance can have its own separate
configuration.  For an instance the class configuration can either be supplemented 
or complete over-ridden.

1. Supplement from a Constructor Block

```ruby
client = AiClient.new('super-ai-overlord-model') do |config|
  config.some_item = some_value
  ...
end
```

2. Suppliment from a YAML File

```ruby
client = AiClient.new('baby-model', config: 'path/to/file.yml')
```

3. Load Complete Configuration from a YAML File

```ruby
client = AiClient.new('your-model')
client.config = AiClient::Config.load('path/to/file.yml')
```

### What Now?

TODO: Document the methods and their options.

```ruby
AI.chat(...)
AI.transcribe(...)
AI.speak(...)
AI.embed(...)
AI.batch_embed(...)
```

See the [examples directory](examples/README.md) for some ideas on how to use AiClient.

### System Environment Variables

The API keys used with each LLM provider have the pattern `XXX_API_KEY` where XXX is the name of the provided.  For example `OPENAI_API_KEY1` and `ANTROPIC_API_KEY` etc.

TODO: list all providers supported and their envar

### Options

TODO: document the options like `provider: :ollama`

## Best ?? Practices

If you are going to be using one model for multiple purposes in different parts of your application you can assign the instance of `AiClient` to a constant so that the same client can be used everywhere.

```ruby
AI = AiClient.new 'gpt-4o'
...
AI.chat "do something with this #{stuff}"
...
AI.speak "warning  Will Robinson! #{bad_things_happened}"
...
```

Using the constant for the instance allows you to reference the same client instance inside any method through out your application.  Of course it does not apply to only one instance.  You could assign multiple instances for different models/providers.  For example you could have `AI` for your primary client and `AIbackup` for a fallback client in case you have a problem on the primary; or, maybe `Vectorizer` as a client name tied to a model specializing in embedding vectorization.

## Extensions for OmniAI

The AiClient makes use of extensions to the OmniAI gem that define
additional providers and protocols.

1. **OmniAI::Ollama^** which wraps the OmniAI::OpenAI class
2. **OmniAI::LocalAI** which also wraps the OmniAI::OpenAI class
3. **OmniAI::OpenRouter**  TODO: Still under development

## OmniAI and OpenRouter

OmniAI is a Ruby gem that supports specific providers directly using a common-ish API.  You incur costs directly from those providers for which you have individual API keys (aka access tokens.) OpenRouter, on the other hand, is a web service that also establishes a common API for many providers and models; however, OpenRouter adds a small fee on top of the fee charged by those providers.  You trade off cost for flexibility.  With OpenRouter you only need one API key (OPEN_ROUTER_API_KEY) to access all of its supported services.

The advantage of AiClient is that you have the added flexibility to choose on a client by client bases where you want your model to be processed.  You get free local processing through Ollama and LocalAI.  You get less costly direct access to some providers via OmniAI.  You get slightly more costly wide-spread access via OpenRouter

## Contributing

I can sure use your help.  This industry is moving faster than I can keep up with.  If you have a bug fix or new feature idea then have at it.  Send me a pull request so we all can benefit from your efforts.

If you only have time to report a bug, that's fine.  Just create an issue in this repo.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
