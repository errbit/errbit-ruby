# frozen_string_literal: true

require_relative "lib/errbit/version"

Gem::Specification.new do |spec|
  spec.name = "errbit-ruby"
  spec.version = Errbit::VERSION
  spec.authors = ["Igor Zubkov"]
  spec.email = ["igor.zubkov@gmail.com"]

  spec.summary = "Plain-Ruby client for reporting exceptions to an Errbit server."
  spec.description = <<~DESC
    A dependency-free Ruby gem that catches and reports exceptions to an
    Errbit server over its error-ingestion API. No Rails, no Rack required.
  DESC
  spec.homepage = "https://github.com/errbit/errbit-ruby"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 4.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "net-http"
  spec.add_runtime_dependency "json"
  spec.add_runtime_dependency "uri"

  spec.add_development_dependency "rspec"
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "rubocop", "~> 1.65"
end
