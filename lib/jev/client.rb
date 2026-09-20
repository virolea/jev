# frozen_string_literal: true

module Jev
  class Client
    API_URL = "https://api.typesafe.ai/v1/systemone"
    MODEL = "jev-latest"

    ERRORS_BY_STATUS = {
      401 => AuthenticationError,
      422 => ValidationError,
      429 => RateLimitError,
      529 => OverloadedError
    }.freeze

    def initialize(api_key)
      raise ArgumentError, "Missing API key" unless api_key

      @api_key = api_key
    end

    def request(state:, questions:)
      body = { model: MODEL, state: state, questions: questions }

      response = Net::HTTP.post(uri, body.to_json, request_headers)
      raise error_for(response) unless response.is_a?(Net::HTTPSuccess)

      JSON.parse(response.body)
    end

    private

    def error_for(response)
      status = response.code.to_i

      ERRORS_BY_STATUS.fetch(status, APIError).new(status, response.body)
    end

    def uri
      URI(API_URL)
    end

    def request_headers
      {
        "Content-Type": "application/json",
        "Authorization": "Bearer #{@api_key}"
      }
    end
  end
end
