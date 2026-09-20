# frozen_string_literal: true

module Jev
  class Question
    class Noul < Question
      DEFAULT_THRESHOLD = 0.5

      attr_reader :noul

      def initialize(identifier, content, threshold: DEFAULT_THRESHOLD, criteria: nil)
        super(identifier, content)
        @threshold = threshold
        @criteria = criteria&.transform_keys(&:to_s)
      end

      def answer_with(answer)
        @noul = answer["noul"]
      end

      def answered? = !@noul.nil?

      private

      attr_reader :criteria

      def type = :noul

      def value = @noul > @threshold
    end
  end
end
