# frozen_string_literal: true

require "spec_helper"

RSpec.describe Errbit::Backtrace do
  describe ".parse" do
    it "returns an empty array when the exception has no backtrace" do
      exception = RuntimeError.new("boom")
      expect(described_class.parse(exception)).to eq([])
    end

    it "parses frames using the pre-3.4 backtick/quote format" do
      exception = RuntimeError.new("boom")
      allow(exception).to receive(:backtrace).and_return(["/app/foo.rb:10:in `bar'"])

      expect(described_class.parse(exception)).to eq(
        [{ file: "/app/foo.rb", line: 10, method: "bar" }]
      )
    end

    it "parses frames using the 3.4+ single-quote format" do
      exception = RuntimeError.new("boom")
      allow(exception).to receive(:backtrace).and_return(["/app/foo.rb:10:in 'bar'"])

      expect(described_class.parse(exception)).to eq(
        [{ file: "/app/foo.rb", line: 10, method: "bar" }]
      )
    end

    it "handles frames without method info" do
      exception = RuntimeError.new("boom")
      allow(exception).to receive(:backtrace).and_return(["/app/foo.rb:10"])

      expect(described_class.parse(exception)).to eq(
        [{ file: "/app/foo.rb", line: 10, method: nil }]
      )
    end

    it "falls back to the raw line when it cannot be parsed" do
      exception = RuntimeError.new("boom")
      allow(exception).to receive(:backtrace).and_return(["not a real backtrace line"])

      expect(described_class.parse(exception)).to eq(
        [{ file: "not a real backtrace line", line: nil, method: nil }]
      )
    end
  end
end
