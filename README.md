# AiClient

First and foremost a big **THANK YOU** to [Kevin Sylvestre](https://ksylvest.com/) for his gem [OmniAI](https://github.com/ksylvest/omniai) upon which this effort depends.

**This is a work in progress**  I could use your help extending its capability.

AiClien` is working.  I've used early versions of it in several projects.

See the  [change log](CHANGELOG.md) for recent modifications.

## Summary

`ai_client` is a versatile Ruby gem that serves as a generic client for interacting with various AI service providers through a unified API provided by Kevin's gem `OmniAI`. The `AiClient` class is designed to simplify the integration of large language models (LLMs) into applications. `AiClient` allows developers to create instances using just the model name, greatly reducing configuration overhead.

With built-in support for popular AI providers—including OpenAI, Anthropic, Google, Mistral, LocalAI and Ollama—the gem abstracts the complexities of API interactions, offering methods for tasks such as chatting, transcription, speech synthesis, and embedding.

The middleware architecture enables customizable processing of requests and responses, making it easy to implement features like logging and retry logic. Seamlessly integrated with the `OmniAI` framework, `ai_client` empowers developers to leverage cutting-edge AI capabilities without vendor lock-in, making it an essential tool for modern AI-driven applications.

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
