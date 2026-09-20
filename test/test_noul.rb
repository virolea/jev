# frozen_string_literal: true

require "test_helper"

class TestNoul < Minitest::Test
  include StubbedAPI

  def setup
    super
    @question = Jev::Question::Noul.new(:is_urgent, "Does this convey urgency?")
  end

  def test_coerces_the_identifier_to_a_symbol
    assert_equal :is_urgent, Jev::Question::Noul.new("is_urgent", "...").identifier
  end

  def test_serializes_to_the_documented_question_shape
    assert_equal({ type: :noul, instructions: "Does this convey urgency?" }, @question.to_h)
  end

  def test_omits_criteria_when_none_is_given
    refute_includes @question.to_h.keys, :criteria
  end

  def test_serializes_criteria_when_given
    question = Jev::Question::Noul.new(:is_urgent, "...", criteria: CRITERIA)

    assert_equal CRITERIA, question.to_h[:criteria]
  end

  def test_normalises_symbol_criteria_keys_to_the_wire_format
    question = Jev::Question::Noul.new(
      :is_urgent, "...",
      criteria: { true: "Explicitly time-sensitive", false: "No urgency expressed" } # rubocop:disable Lint/BooleanSymbol
    )

    assert_equal CRITERIA, question.to_h[:criteria]
  end

  def test_exposes_the_raw_probability
    assert_nil @question.noul

    @question.answer_with("type" => "noul", "noul" => 0.95)

    assert_in_delta 0.95, @question.noul
  end

  def test_answered_predicate_returns_booleans
    assert_equal false, @question.answered?

    @question.answer_with("type" => "noul", "noul" => 0.95)

    assert_equal true, @question.answered?
  end

  def test_result_uses_a_default_threshold_of_one_half
    assert answered(:above, 0.51).result
    refute answered(:below, 0.49).result
  end

  def test_result_honours_a_custom_threshold
    refute answered(:strict, 0.72, threshold: 0.8).result
    assert answered(:lenient, 0.72, threshold: 0.7).result
  end

  def test_result_raises_when_the_question_is_unanswered
    error = assert_raises(Jev::Error) { @question.result }

    assert_match(/is_urgent/, error.message)
  end

  def test_an_unanswered_question_is_distinguishable_from_a_false_one
    refute answered(:is_urgent, 0.1).result
    assert_raises(Jev::Error) { @question.result }
  end

  private

  def answered(identifier, noul, **options)
    Jev::Question::Noul.new(identifier, "...", **options).tap { |q| q.answer_with("noul" => noul) }
  end
end
