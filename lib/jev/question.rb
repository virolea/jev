# frozen_string_literal: true

module Jev
  class Question
    attr_reader :identifier

    def initialize(identifier, content)
      @identifier = identifier.to_sym
      @content = content
    end

    def to_h = { type: type, instructions: @content, criteria: criteria }.compact

    def answer_with(_answer)
      raise NotImplementedError, "#{self.class} must implement #answer_with"
    end

    def answered?
      raise NotImplementedError, "#{self.class} must implement #answered?"
    end

    def result
      ensure_answered!

      value
    end

    private

    def ensure_answered!
      raise Error, "#{@identifier} has not been answered" unless answered?
    end

    def criteria = nil
  end
end
