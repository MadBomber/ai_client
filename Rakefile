# frozen_string_literal: true

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

task default: :test
