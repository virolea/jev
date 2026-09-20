# Jev

A Ruby client for the [Typesafe](https://typesafe.ai) Jev model API.

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add jev
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install jev
```

## Configuration

Set your API key once, typically in an initializer:

```ruby
Jev.api_key = _YOUR_JEV_API_KEY_ 
```

## Quick start

```ruby
response = Jev::Query.new("Help! My payouts have been failing for 3 days.").perform do |query|
  query.ask(:is_urgent, "Does this convey urgency?")
end

response.answers.is_urgent.result  # => true
response.answers.is_urgent.noul    # => 0.95
```

## The three question types

Every question in a single query is evaluated in parallel against the same state, so
adding questions costs far less than making another call. Prefer several narrow questions
over one broad one.

### `ask` — noul

Evaluates the truth of a statement, returning a probability between 0 and 1.

```ruby
query.ask(:is_urgent, "Does this convey urgency?",
          criteria: {
            "true" => "Explicitly time-sensitive",
            "false" => "No urgency expressed"
          })
```

`criteria` is optional, but it is how you scope a noul — worth providing whenever the
statement could be read more than one way.

### `choose` — choice

Selects one option from a set. Up to 255 options.

```ruby
query.choose(:department, "Which team should handle this?",
             options: {
               "billing" => "Payments, invoicing, refunds",
               "technical" => "Bugs, outages, integrations",
               "sales" => "Pricing, upgrades, new accounts"
             })
```

### `score` — score

Rates the state against an ordered rubric of 2 to 10 levels.

```ruby
query.score(:frustration, "How frustrated is the customer?",
            levels: ["Calm", "Frustrated", "Very angry"])
```

## Reading answers

Every answer exposes `result` — the typed value to branch on — whatever its type:

```ruby
answers = response.answers

answers.is_urgent.result    # => true       (noul, thresholded)
answers.department.result   # => "billing"  (the chosen option)
answers.frustration.result  # => 1.05       (the probability-weighted score)
```

Underneath that, each type exposes what the model actually returned:

```ruby
answers.is_urgent.noul             # => 0.95
answers.department.probabilities   # => { "billing" => 0.88, "technical" => 0.12, "sales" => 0.0 }
answers.department.confidence      # => 0.81
answers.frustration.level          # => 1            (most probable level)
answers.frustration.label          # => "Frustrated"  (that level, via the legend)
answers.frustration.probabilities  # => { "0" => 0.0, "1" => 0.95, "2" => 0.05 }
```

Reading `result` on a question that has not been answered raises `Jev::Error` rather than
returning a falsy value — so "the model said no" is never confused with "we never asked".

Answers are enumerable, which is where combining atomic questions pays off:

```ruby
answers.map(&:identifier)                       # => [:is_urgent, :department, :frustration]
answers.to_h { |a| [a.identifier, a.result] }   # => { is_urgent: true, department: "billing", frustration: 1.05 }
answers[:department]                            # => the question, looked up by identifier
answers.count                                   # => 3
```

Note that `result` is truthy for any answered choice or score, so `select(&:result)` only
narrows a set of nouls.

### Thresholds

A noul's `result` is its probability compared against a threshold, which defaults to 0.5.
The threshold belongs to the question, since the confidence you need is part of what you
are asking:

```ruby
query.ask(:is_urgent, "Does this convey urgency?", threshold: 0.8)
```

The raw probability is always available via `noul` if you would rather route on it yourself.

### Acting on a score

A score answer gives you two different views, and which you want depends on what you are doing.

**For a decision, use `level` or `label`.** These report the most probable level, which is
what the model actually asserted:

```ruby
case answers.frustration.label
when "Very angry" then escalate_to_human
when "Frustrated" then flag_for_review
else                   autorespond
end
```

**For ranking or aggregation, use `result`**, the probability-weighted value. It is the only
one of the two that gives a total order or a meaningful average:

```ruby
tickets.sort_by { |ticket| -ticket.answers.frustration.result }
weekly_average = scores.sum(&:result) / scores.size
```

Be careful thresholding `result` directly. A rubric's levels are ordered but not evenly
spaced, so a cutoff like `result >= 1.5` assumes a scale the rubric does not really have.
It can also mislead on a split distribution: probabilities of
`{ "0" => 0.5, "1" => 0.1, "2" => 0.4 }` average to `0.9`, pointing near *Frustrated*,
the one level the model considers least likely. `level` reports `0` there, which is honest.
Check `confidence` before acting on a weighted score.

Ties in `level` resolve to the lower level.

## Response metadata

```ruby
response.model              # => "jev-1.13.0"  — the version that actually answered
response.usage.input_tokens  # => 318
response.usage.output_tokens # => 34
```

Note that `model` is the *resolved* version. Requests are sent as `jev-latest`, so this is
how you find out what you actually got.

## Errors

All errors inherit from `Jev::Error`:

```ruby
begin
  query.perform
rescue Jev::AuthenticationError  # 401
rescue Jev::ValidationError      # 422
rescue Jev::RateLimitError       # 429
rescue Jev::OverloadedError      # 529
rescue Jev::APIError => e        # any other non-success status
  e.status  # => 500
  e.body    # => the raw response body
end
```

**Rate limits are not retried for you.** The API documentation recommends exponential
backoff on 429 and 529; this client raises instead, so that policy stays yours:

```ruby
begin
  query.perform
rescue Jev::RateLimitError, Jev::OverloadedError
  # back off and retry on your own terms
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/virolea/jev.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
