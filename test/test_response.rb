# frozen_string_literal: true

require "test_helper"

class TestResponse < Minitest::Test
  include StubbedAPI

  def setup
    stub_response(answers: { is_urgent: noul_answer }, usage: { input_tokens: 307, output_tokens: 20 })
  end

  def test_perform_returns_a_response
    assert_instance_of Jev::Response, perform_urgency_query
  end

  def test_exposes_answers_through_the_collection_dsl
    response = perform_urgency_query

    assert response.answers.is_urgent.result
    assert_in_delta 0.95, response.answers.is_urgent.noul
  end

  def test_keeps_the_resolved_model_version
    assert_equal "jev-1.13.0", perform_urgency_query.model
  end

  def test_keeps_usage
    usage = perform_urgency_query.usage

    assert_equal 307, usage.input_tokens
    assert_equal 20, usage.output_tokens
  end

  def test_usage_survives_a_response_without_a_usage_key
    stub_response(answers: {})

    usage = Jev::Query.new(STATE).perform.usage

    assert_nil usage.input_tokens
    assert_nil usage.output_tokens
  end

  def test_a_mixed_query_reads_back_every_answer_type
    stub_response(answers: { is_urgent: noul_answer, department: choice_answer, frustration: score_answer })

    answers = perform_mixed_query

    assert_equal true, answers.is_urgent.result
    assert_equal "billing", answers.department.result
    assert_equal "Frustrated", answers.frustration.label
  end

  private

  def perform_urgency_query
    Jev::Query.new(STATE).perform { |query| query.ask(:is_urgent, QUESTION) }
  end

  def perform_mixed_query
    Jev::Query.new(STATE).perform do |query|
      query.ask(:is_urgent, QUESTION)
      query.choose(:department, DEPARTMENT, options: OPTIONS)
      query.score(:frustration, FRUSTRATION, levels: LEVELS)
    end.answers
  end
end
