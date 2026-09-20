# frozen_string_literal: true

require "test_helper"

class TestClient < Minitest::Test
  include StubbedAPI

  QUESTIONS = { is_urgent: { type: "noul", instructions: QUESTION } }.freeze

  def test_requires_an_api_key
    assert_raises(ArgumentError) { Jev::Client.new(nil) }
  end

  def test_sends_the_documented_request_body
    stub = stub_request(:post, API_URL)
           .with(body: { model: "jev-latest", state: STATE, questions: QUESTIONS })
           .to_return(status: 200, body: success_body)

    perform

    assert_requested stub
  end

  def test_authenticates_with_its_own_api_key_rather_than_the_global_one
    stub = stub_request(:post, API_URL)
           .with(headers: { "Content-Type" => "application/json", "Authorization" => "Bearer other-key" })
           .to_return(status: 200, body: success_body)

    Jev::Client.new("other-key").request(state: STATE, questions: QUESTIONS)

    assert_requested stub
  end

  def test_parses_a_successful_response
    stub_request(:post, API_URL).to_return(status: 200, body: success_body)

    response = perform

    assert_equal "jev-1.13.0", response["model"]
    assert_in_delta 0.95, response.dig("answers", "is_urgent", "noul")
    assert_equal 307, response.dig("usage", "input_tokens")
  end

  def test_maps_documented_statuses_to_their_own_error_classes
    {
      401 => Jev::AuthenticationError,
      422 => Jev::ValidationError,
      429 => Jev::RateLimitError,
      529 => Jev::OverloadedError
    }.each do |status, error_class|
      assert_raises(error_class) { perform_returning(status) }
    end
  end

  def test_falls_back_to_the_base_api_error_for_unmapped_statuses
    assert_raises(Jev::APIError) { perform_returning(500) }
  end

  def test_every_api_error_is_rescuable_as_a_jev_error
    assert_raises(Jev::Error) { perform_returning(401) }
  end

  def test_errors_carry_the_status_and_body
    error = assert_raises(Jev::APIError) { perform_returning(422, '{"error":"bad question"}') }

    assert_equal 422, error.status
    assert_equal '{"error":"bad question"}', error.body
    assert_match(/422/, error.message)
  end

  private

  def perform
    Jev::Client.new("test-key").request(state: STATE, questions: QUESTIONS)
  end

  def perform_returning(status, body = "{}")
    stub_request(:post, API_URL).to_return(status: status, body: body)
    perform
  end

  def success_body
    { model: "jev-1.13.0", answers: { is_urgent: noul_answer },
      usage: { input_tokens: 307, output_tokens: 20 } }.to_json
  end
end
