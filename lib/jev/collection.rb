# frozen_string_literal: true

module Jev
  class Collection
    include Enumerable

    def initialize(questions)
      @questions = questions
      @questions.each do |question|
        next if respond_to?(question.identifier)

        define_singleton_method(question.identifier) { question }
      end
    end

    def each(&) = @questions.each(&)

    def [](identifier)
      @questions.find { |question| question.identifier == identifier.to_sym }
    end
  end
end
