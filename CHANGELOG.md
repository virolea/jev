# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2026-09-20

First release with a working client. 0.1.0 shipped an empty module.

### Added

- `Jev::Query` for building a batch of questions against a single state, with
  `ask` (noul), `choose` (choice) and `score` (score).
- `Jev::Question` and its three subclasses, sharing a uniform `result` for the
  typed value to branch on, alongside type-specific accessors:
  - `Noul` — `noul`, plus a per-question `threshold:` (default `0.5`).
  - `Choice` — `choice`, `probabilities`, `confidence`. Up to 255 options.
  - `Score` — `score`, `legend`, `probabilities`, `confidence`, plus `level` and
    `label` for the most probable level. 2 to 10 levels.
- `criteria:` on noul questions, `options:` on choice, `levels:` on score, all
  serialised to the API's `criteria` field.
- `Jev::Response` exposing the resolved `model` (e.g. `jev-1.13.0`, not
  `jev-latest`), token `usage`, and `answers`.
- `Jev::Collection`, an Enumerable set of answers supporting attribute access
  (`answers.is_urgent`) and lookup by identifier (`answers[:is_urgent]`).
- An error hierarchy under `Jev::Error`: `Jev::APIError` (carrying `status` and
  `body`) with `AuthenticationError` (401), `ValidationError` (422),
  `RateLimitError` (429) and `OverloadedError` (529).
- `Jev.api_key` for global configuration, and `Jev::Client.new(api_key)` for
  callers that need more than one key.

### Notes

- Rate limits are not retried. The API documentation recommends exponential
  backoff on 429 and 529; this client raises `Jev::RateLimitError` and
  `Jev::OverloadedError` so that policy stays with the caller.
- Requests are sent as `jev-latest` and use `Net::HTTP`'s default timeouts.
- Reading `result` on an unanswered question raises `Jev::Error` rather than
  returning a falsy value.

[0.2.0]: https://github.com/virolea/jev/releases/tag/v0.2.0
