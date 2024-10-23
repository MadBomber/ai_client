# frozen_string_literal: true

# Start SimpleCov for code coverage
require 'simplecov'
SimpleCov.start do
  add_filter '/test/'
end

# Load the AI client configuration
$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "ai_client"
require "ai_client/retry_middleware"

# A stuf for testing middleware
module OmniAI
  class RateLimitError < StandardError; end
  class NetworkError < StandardError; end
end


require 'logger'
require 'hashie'
require 'ostruct'
require "bundler/gem_tasks"
require "minitest/test_task"

begin
  require "tocer/rake/register"
rescue LoadError => error
  puts error.message
end

# Register the rake tasks
Tocer::Rake::Register.call
Minitest::TestTask.create

# Your tests will go here
require 'minitest/autorun'
require 'mocha/minitest'


# After running tests, display the coverage report
Minitest.after_run do
  # This prints the coverage report to the specified format (HTML in this case)
  SimpleCov.result.format!
  puts "Coverage report generated at: #{SimpleCov.coverage_dir}"
end