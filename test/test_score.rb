# frozen_string_literal: true

require "test_helper"

class TestScore < Minitest::Test
  include StubbedAPI

  def setup
    super
    @question = Jev::Question::Score.new(:frustration, FRUSTRATION, levels: LEVELS)
  end

  def test_is_a_question
    assert_kind_of Jev::Question, @question
  end

  def test_requires_levels
    assert_raises(ArgumentError) { Jev::Question::Score.new(:frustration, FRUSTRATION) }
  end

  def test_serializes_to_the_documented_question_shape
    assert_equal({ type: :score, instructions: FRUSTRATION, criteria: LEVELS }, @question.to_h)
  end

  def test_rejects_fewer_levels_than_documented
    error = assert_raises(ArgumentError) { Jev::Question::Score.new(:f, FRUSTRATION, levels: ["Calm"]) }

    assert_match(/2 to 10/, error.message)
  end

  def test_rejects_more_levels_than_documented
    assert_raises(ArgumentError) { Jev::Question::Score.new(:f, FRUSTRATION, levels: (1..11).map(&:to_s)) }
  end

  def test_accepts_the_documented_boundaries
    assert_equal 2, Jev::Question::Score.new(:f, FRUSTRATION, levels: %w[Low High]).to_h[:criteria].size
    assert_equal 10, Jev::Question::Score.new(:f, FRUSTRATION, levels: (1..10).map(&:to_s)).to_h[:criteria].size
  end

  def test_reads_the_documented_answer_fields
    answer!

    assert_in_delta 1.05, @question.score
    assert_equal "Frustrated", @question.legend["1"]
    assert_in_delta 0.95, @question.probabilities["1"]
    assert_in_delta 0.92, @question.confidence
  end

  def test_reads_the_three_views_of_an_answer
    answer!

    assert_in_delta 1.05, @question.result
    assert_equal 1, @question.level
    assert_equal "Frustrated", @question.label
  end

  def test_level_follows_the_distribution_not_the_weighted_score
    polarised!

    assert_in_delta 0.9, @question.result
    assert_equal 0, @question.level
    assert_equal "Calm", @question.label
  end

  def test_ties_resolve_to_the_lower_level
    answer_with(probabilities: { "0" => 0.45, "1" => 0.1, "2" => 0.45 })

    assert_equal 0, @question.level
  end

  def test_answered_predicate_returns_booleans
    assert_equal false, @question.answered?

    answer!

    assert_equal true, @question.answered?
  end

  def test_result_raises_when_the_question_is_unanswered
    error = assert_raises(Jev::Error) { @question.result }

    assert_match(/frustration/, error.message)
  end

  def test_level_raises_when_the_question_is_unanswered
    assert_raises(Jev::Error) { @question.level }
  end

  def test_label_raises_when_the_question_is_unanswered
    assert_raises(Jev::Error) { @question.label }
  end

  private

  def answer! = @question.answer_with(JSON.parse(score_answer.to_json))

  def polarised! = answer_with(score: 0.9, probabilities: { "0" => 0.5, "1" => 0.1, "2" => 0.4 })

  def answer_with(probabilities:, score: 1.0)
    @question.answer_with(
      "score" => score, "legend" => LEGEND, "probabilities" => probabilities, "confidence" => 0.35
    )
  end
end
