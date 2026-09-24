# errbit-ruby

A dependency-free Ruby client for reporting exceptions to an Errbit server.
Plain Ruby only — no Rails, no Rack required. Targets Ruby >= 4.0 and has
**zero runtime dependencies** (uses only `net/http`, `json`, and `uri` from
the standard library).

This gem talks to a new, purpose-built error-ingestion API — it is **not**
compatible with the Airbrake or Sentry APIs. The API is specified in
[`openapi/errbit-api.yaml`](openapi/errbit-api.yaml).

## Installation

Add to your Gemfile:

```ruby
gem "errbit-ruby", require: "errbit"
```

or install directly:

```sh
gem install errbit-ruby
```

## Usage

Configure once, near your application's boot:

```ruby
require "errbit"

Errbit.configure do |config|
  config.host       = "https://errbit.example.com"
  config.project_id = ENV.fetch("ERRBIT_PROJECT_ID")
  config.api_key    = ENV.fetch("ERRBIT_API_KEY")

  # Optional: exception classes, class-name strings, or regexps to skip.
  config.ignore = [ArgumentError, /expected, harmless/i]
end
```

Then report exceptions where you rescue them:

```ruby
begin
  risky_operation
rescue => e
  Errbit.notify(e)
  raise
end
```

`Errbit.notify` returns an `Errbit::Result`:

```ruby
result = Errbit.notify(e)

result.success? # => true/false
result.ignored? # => true if the exception matched config.ignore
result.failure? # => true on a 4xx/5xx response from the server
result.id       # => server-assigned id, on success
result.error    # => server error message, on failure
```

A report is delivered synchronously over HTTP(S) on the calling thread. A
network failure (timeout, connection refused, etc.) raises
`Errbit::DeliveryError`; a well-formed error response from the server
(400/401/404) does not raise — check `result.failure?` instead.

## Development

```sh
bundle install
bundle exec rspec
```

`bin/console` starts an IRB session with the gem pre-configured against a
placeholder host for manual experimentation.

## API

See [`openapi/errbit-api.yaml`](openapi/errbit-api.yaml) for the full
OpenAPI 3.1 definition of the single endpoint this gem calls:

```
POST /api/v1/projects/{project_id}/errors/{api_key}
```

## License

MIT
