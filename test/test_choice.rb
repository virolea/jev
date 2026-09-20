# frozen_string_literal: true

require "test_helper"

class TestChoice < Minitest::Test
  include StubbedAPI

  def setup
    super
    @question = Jev::Question::Choice.new(:department, DEPARTMENT, options: OPTIONS)
  end

  def test_is_a_question
    assert_kind_of Jev::Question, @question
  end

  def test_requires_options
    assert_raises(ArgumentError) { Jev::Question::Choice.new(:department, DEPARTMENT) }
  end

  def test_serializes_to_the_documented_question_shape
    assert_equal({ type: :choice, instructions: DEPARTMENT, criteria: OPTIONS }, @question.to_h)
  end

  def test_normalises_symbol_option_keys_to_the_wire_format
    question = Jev::Question::Choice.new(:department, DEPARTMENT, options: { billing: "Refunds" })

    assert_equal({ "billing" => "Refunds" }, question.to_h[:criteria])
  end

  def test_rejects_an_empty_option_set
    assert_raises(ArgumentError) { Jev::Question::Choice.new(:department, DEPARTMENT, options: {}) }
  end

  def test_rejects_more_than_the_documented_maximum
    too_many = (0..Jev::Question::Choice::MAX_OPTIONS).to_h { |i| ["option#{i}", "..."] }

    error = assert_raises(ArgumentError) { Jev::Question::Choice.new(:department, DEPARTMENT, options: too_many) }

    assert_match(/255/, error.message)
  end

  def test_accepts_exactly_the_documented_maximum
    most = (1..Jev::Question::Choice::MAX_OPTIONS).to_h { |i| ["option#{i}", "..."] }

    assert_equal 255, Jev::Question::Choice.new(:department, DEPARTMENT, options: most).to_h[:criteria].size
  end

  def test_reads_the_documented_answer_fields
    answer!

    assert_equal "billing", @question.choice
    assert_in_delta 0.88, @question.probabilities["billing"]
    assert_in_delta 0.81, @question.confidence
  end

  def test_result_returns_the_chosen_option_as_a_string
    answer!

    assert_equal "billing", @question.result
  end

  def test_answered_predicate_returns_booleans
    assert_equal false, @question.answered?

    answer!

    assert_equal true, @question.answered?
  end

  def test_result_raises_when_the_question_is_unanswered
    error = assert_raises(Jev::Error) { @question.result }

    assert_match(/department/, error.message)
  end

  private

  def answer!
    @question.answer_with(JSON.parse(choice_answer.to_json))
  end
end
