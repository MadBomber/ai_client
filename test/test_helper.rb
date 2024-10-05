# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "ai_client"

require 'logger'
require 'hashie'
require 'ostruct'

require 'minitest/autorun'
require 'mocha/minitest'
