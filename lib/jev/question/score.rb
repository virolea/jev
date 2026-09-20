# frozen_string_literal: true

module Jev
  class Question
    class Score < Question
      LEVELS = (2..10)

      attr_reader :score, :legend, :probabilities, :confidence

      def initialize(identifier, content, levels:)
        super(identifier, content)
        @levels = Array(levels)
        validate_levels!
      end

      def answer_with(answer)
        @score = answer["score"]
        @legend = answer["legend"]
        @probabilities = answer["probabilities"]
        @confidence = answer["confidence"]
      end

      def answered? = !@score.nil?

      def level
        ensure_answered!

        probabilities.max_by { |_, probability| probability }.first.to_i
      end

      def label = legend[level.to_s]

      private

      def type = :score

      def value = @score

      def criteria = @levels

      def validate_levels!
        return if LEVELS.cover?(@levels.size)

        raise ArgumentError, "a score question takes #{LEVELS.min} to #{LEVELS.max} levels, got #{@levels.size}"
      end
    end
  end
end
