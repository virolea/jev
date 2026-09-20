# frozen_string_literal: true

module Jev
  class Question
    class Choice < Question
      MAX_OPTIONS = 255

      attr_reader :choice, :probabilities, :confidence

      def initialize(identifier, content, options:)
        super(identifier, content)
        @options = options.transform_keys(&:to_s)
        validate_options!
      end

      def answer_with(answer)
        @choice = answer["choice"]
        @probabilities = answer["probabilities"]
        @confidence = answer["confidence"]
      end

      def answered? = !@choice.nil?

      private

      def type = :choice

      def value = @choice

      def criteria = @options

      def validate_options!
        return if @options.size.between?(1, MAX_OPTIONS)

        raise ArgumentError, "a choice question takes 1 to #{MAX_OPTIONS} options, got #{@options.size}"
      end
    end
  end
end
