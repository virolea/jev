# frozen_string_literal: true

require "test_helper"

class TestQuery < Minitest::Test
  include StubbedAPI

  def test_the_block_and_chained_forms_build_the_same_request
    stub_response(answers: { is_urgent: noul_answer })

    Jev::Query.new(STATE).perform { |query| query.ask(:is_urgent, QUESTION) }
    Jev::Query.new(STATE).ask(:is_urgent, QUESTION).perform

    assert_requested :post, API_URL, times: 2, body: request_body(is_urgent: noul_question)
  end

  def test_criteria_reaches_the_request_body_exactly_as_documented
    stub_response(answers: { is_urgent: noul_answer })

    Jev::Query.new(STATE).perform { |query| query.ask(:is_urgent, QUESTION, criteria: CRITERIA) }

    assert_requested :post, API_URL, body: request_body(is_urgent: noul_question.merge(criteria: CRITERIA))
  end

  def test_choose_sends_the_documented_choice_question
    stub_response(answers: { department: choice_answer })

    Jev::Query.new(STATE).perform { |query| query.choose(:department, DEPARTMENT, options: OPTIONS) }

    assert_requested :post, API_URL, body: request_body(department: choice_question)
  end

  def test_score_sends_the_documented_score_question
    stub_response(answers: { frustration: score_answer })

    Jev::Query.new(STATE).perform { |query| query.score(:frustration, FRUSTRATION, levels: LEVELS) }

    assert_requested :post, API_URL, body: request_body(frustration: score_question)
  end

  def test_ask_returns_the_query_for_chaining
    query = Jev::Query.new(STATE)

    assert_same query, query.ask(:is_urgent, QUESTION)
  end

  def test_asking_the_same_identifier_twice_raises
    query = Jev::Query.new(STATE).ask(:is_urgent, QUESTION)

    error = assert_raises(ArgumentError) { query.ask(:is_urgent, "A different question") }

    assert_match(/is_urgent/, error.message)
  end

  def test_duplicate_detection_ignores_string_versus_symbol_identifiers
    query = Jev::Query.new(STATE).ask(:is_urgent, QUESTION)

    assert_raises(ArgumentError) { query.ask("is_urgent", QUESTION) }
  end

  def test_duplicate_detection_spans_question_types
    query = Jev::Query.new(STATE).ask(:department, QUESTION)

    assert_raises(ArgumentError) { query.choose(:department, DEPARTMENT, options: OPTIONS) }
  end

  def test_distinct_identifiers_are_both_kept
    query = Jev::Query.new(STATE).ask(:is_urgent, QUESTION).ask(:is_angry, "Is the customer angry?")

    assert_equal %i[is_urgent is_angry], query.questions.map(&:identifier)
  end

  private

  def request_body(questions)
    { model: "jev-latest", state: STATE, questions: questions }
  end

  def noul_question = { type: "noul", instructions: QUESTION }

  def choice_question = { type: "choice", instructions: DEPARTMENT, criteria: OPTIONS }

  def score_question = { type: "score", instructions: FRUSTRATION, criteria: LEVELS }
end
