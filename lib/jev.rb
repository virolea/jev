# frozen_string_literal: true

require "zeitwerk"
require "net/http"
require "json"
require_relative "jev/version"

loader = Zeitwerk::Loader.for_gem
loader.setup

module Jev
  class Error < StandardError; end

  class APIError < Error
    attr_reader :status, :body

    def initialize(status, body)
      @status = status
      @body = body
      super("Jev API error #{status}: #{body}")
    end
  end

  class AuthenticationError < APIError; end
  class ValidationError < APIError; end
  class RateLimitError < APIError; end
  class OverloadedError < APIError; end

  class << self
    attr_accessor :api_key

    def client
      @client ||= Client.new(api_key)
    end
  end
end
