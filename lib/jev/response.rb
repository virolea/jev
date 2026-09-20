# frozen_string_literal: true

module Jev
  class Response
    Usage = Struct.new(:input_tokens, :output_tokens)

    attr_reader :model, :usage, :answers

    def initialize(payload, answers:)
      @model = payload["model"]
      @usage = Usage.new(*(payload["usage"] || {}).values_at("input_tokens", "output_tokens"))
      @answers = answers
    end
  end
end
