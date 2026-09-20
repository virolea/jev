# frozen_string_literal: true

module Jev
  class Query
    def initialize(state)
      @state = state
      @questions = {}
    end

    def ask(identifier, content, **options)
      add(Question::Noul, identifier, content, **options)
    end

    def choose(identifier, content, options:)
      add(Question::Choice, identifier, content, options: options)
    end

    def score(identifier, content, levels:)
      add(Question::Score, identifier, content, levels: levels)
    end

    def questions = Collection.new(@questions.values)

    def perform
      yield self if block_given?

      payload = Jev.client.request(state: @state, questions: @questions.transform_values(&:to_h))
      distribute_answers_across_questions(payload["answers"])

      Response.new(payload, answers: questions)
    end

    private

    def add(type, identifier, content, **options)
      identifier = identifier.to_sym
      raise ArgumentError, "#{identifier} has already been asked" if @questions.key?(identifier)

      @questions[identifier] = type.new(identifier, content, **options)
      self
    end

    def distribute_answers_across_questions(answers)
      answers.each { |identifier, answer| @questions.fetch(identifier.to_sym).answer_with(answer) }
    end
  end
end
