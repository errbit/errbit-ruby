# frozen_string_literal: true

require "spec_helper"

RSpec.describe Errbit::ErrorReport do
  describe ".build" do
    it "builds a payload matching the ErrorReport OpenAPI schema" do
      exception = begin
        raise ArgumentError, "invalid input"
      rescue ArgumentError => e
        e
      end

      payload = described_class.build(exception)

      expect(payload).to match(
        error: {
          class: "ArgumentError",
          message: "invalid input",
          backtrace: an_instance_of(Array)
        }
      )
      expect(payload[:error][:backtrace]).not_to be_empty
      expect(payload[:error][:backtrace].first).to include(:file, :line, :method)
    end

    it "handles exceptions without a backtrace" do
      exception = ArgumentError.new("invalid input")

      payload = described_class.build(exception)

      expect(payload).to eq(
        error: {
          class: "ArgumentError",
          message: "invalid input",
          backtrace: []
        }
      )
    end
  end
end
