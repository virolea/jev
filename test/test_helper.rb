# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "jev"

require "minitest/autorun"
require "webmock/minitest"

Jev.api_key = "test-key"

module StubbedAPI
  API_URL = "https://api.typesafe.ai/v1/systemone"
  STATE = "Help! My payouts have been failing for 3 days."

  QUESTION = "Does this convey urgency?"
  CRITERIA = { "true" => "Explicitly time-sensitive", "false" => "No urgency expressed" }.freeze

  DEPARTMENT = "Which team should handle this?"
  OPTIONS = {
    "billing" => "Payments, invoicing, refunds",
    "technical" => "Bugs, outages, integrations",
    "sales" => "Pricing, upgrades, new accounts"
  }.freeze

  FRUSTRATION = "How frustrated is the customer?"
  LEVELS = ["Calm", "Frustrated", "Very angry"].freeze
  LEGEND = { "0" => "Calm", "1" => "Frustrated", "2" => "Very angry" }.freeze

  private

  def stub_response(answers:, usage: nil, model: "jev-1.13.0")
    body = { model: model, answers: answers }
    body[:usage] = usage if usage

    stub_request(:post, API_URL).to_return(status: 200, body: body.to_json)
  end

  def noul_answer(noul: 0.95) = { type: "noul", noul: noul }

  def choice_answer
    { type: "choice", choice: "billing",
      probabilities: { billing: 0.88, technical: 0.12, sales: 0.0 }, confidence: 0.81 }
  end

  def score_answer
    { type: "score", score: 1.05, legend: LEGEND,
      probabilities: { "0" => 0.0, "1" => 0.95, "2" => 0.05 }, confidence: 0.92 }
  end
end
