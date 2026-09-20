# frozen_string_literal: true

require "test_helper"

class TestCollection < Minitest::Test
  def setup
    super
    @is_urgent = Jev::Question::Noul.new(:is_urgent, "...")
    @is_angry = Jev::Question::Noul.new(:is_angry, "...")
    @collection = Jev::Collection.new([@is_urgent, @is_angry])
  end

  def test_reads_a_question_as_an_attribute
    assert_same @is_urgent, @collection.is_urgent
  end

  def test_responds_to_the_questions_it_holds
    assert_respond_to @collection, :is_urgent
    refute_respond_to @collection, :is_bananas
  end

  def test_an_unknown_question_raises_no_method_error
    assert_raises(NoMethodError) { @collection.is_bananas }
  end

  def test_reads_a_question_by_index
    assert_same @is_urgent, @collection[:is_urgent]
    assert_same @is_urgent, @collection["is_urgent"]
    assert_nil @collection[:is_bananas]
  end

  def test_is_enumerable
    assert_equal %i[is_urgent is_angry], @collection.map(&:identifier)
    assert_equal 2, @collection.count
    assert_equal([@is_urgent], @collection.select { |q| q.identifier == :is_urgent })
  end

  def test_a_question_named_after_an_existing_method_stays_reachable_by_index
    shadowing = Jev::Question::Noul.new(:count, "...")
    collection = Jev::Collection.new([shadowing])

    assert_equal 1, collection.count
    assert_same shadowing, collection[:count]
  end
end
