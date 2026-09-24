# errbit-ruby

A dependency-free Ruby client for reporting exceptions to an Errbit server.
Plain Ruby — no Rails, no Rack. Targets Ruby >= 4.0.

## Design constraints (do not violate without asking)

- **Zero runtime dependencies.** The gem may only use Ruby's standard
  library (`net/http`, `json`, `uri`, ...) at runtime. `rspec`, `webmock`,
  `rubocop`, `rake`, `irb` are development-only (`add_development_dependency`
  in `errbit-ruby.gemspec`, or plain `gem` lines in the `Gemfile`).
- **No Rails, no Rack.** Nothing in `lib/` may assume either is loaded.
- **This is a new, custom API** — not Airbrake- or Sentry-compatible. The
  wire format is defined in `openapi/errbit-api.yaml` and that file is the
  source of truth for the request/response shape the client builds and
  parses. If you change the payload shape in `lib/errbit/error_report.rb`
  or `lib/errbit/client.rb`, update the OpenAPI spec to match (and vice
  versa).
- **Synchronous delivery only.** `Errbit::Client#notify` makes a blocking
  `Net::HTTP` call on the caller's thread. No background thread/queue.
- Target Ruby version is 4.0 (`.ruby-version` pins the local dev version to
  4.0.7 via rbenv; `required_ruby_version` in the gemspec is `>= 4.0`).

## Project layout

- `lib/errbit.rb` — public entry point: `Errbit.configure`, `Errbit.notify`.
- `lib/errbit/configuration.rb` — `host`, `project_id`, `api_key`, `ignore`
  list, timeouts.
- `lib/errbit/backtrace.rb` — parses `exception.backtrace` lines into
  `{file:, line:, method:}` hashes. Handles both the pre-3.4 backtick/quote
  format and the 3.4+ single-quote format.
- `lib/errbit/error_report.rb` — builds the JSON payload from an
  `Exception`, matching the `ErrorReport` schema in the OpenAPI spec.
- `lib/errbit/client.rb` — POSTs to
  `{host}/api/v1/projects/{project_id}/errors/{api_key}` via `Net::HTTP`,
  returns an `Errbit::Result`.
- `lib/errbit/result.rb` — outcome object: `success?` / `ignored?` /
  `failure?`.
- `lib/errbit/errors.rb` — `Errbit::Error`, `ConfigurationError`,
  `DeliveryError` (raised only on network failure, never on a well-formed
  4xx/5xx from the server — those come back as a failed `Result`).
- `openapi/errbit-api.yaml` — OpenAPI 3.1 spec for the single ingestion
  endpoint this gem calls. Update alongside any payload/response change.

## Commands

```sh
bundle install
bundle exec rspec          # run the test suite (spec/)
bundle exec rubocop        # lint
bundle exec rake           # defaults to spec
bin/console                # IRB session with Errbit pre-configured
```

Note: a `rubocop --server` daemon can get stuck/orphaned on this machine
and hang `bundle exec rubocop`. If it hangs, check `ps aux | grep rubocop`
and confirm with the user before killing anything; `--no-server` may not
help if the daemon itself is wedged.

## Testing conventions

- RSpec, with WebMock stubbing all HTTP (`WebMock.disable_net_connect!` in
  `spec/spec_helper.rb` — real network calls in specs are a bug, not a
  feature).
- WebMock's `hash_including` body matchers compare against the
  **JSON-decoded body with string keys**, not symbols — write
  `hash_including("error" => hash_including("class" => ...))`, not
  `hash_including(error: hash_including(class: ...))`. Getting this wrong
  is a common mistake here and fails silently-looking WebMock diffs.
- Every spec file lives under `spec/`, mirroring `lib/errbit/*` files
  1:1 (`lib/errbit/client.rb` <-> `spec/errbit/client_spec.rb`).

## Style

- `# frozen_string_literal: true` at the top of every Ruby file.
- Double-quoted string literals (enforced by `.rubocop.yml`).
- No comments explaining *what* code does; only *why*, when non-obvious
  (see the `DeliveryError` note above for an example of the kind of thing
  worth a comment).
