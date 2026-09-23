# frozen_string_literal: true

require "spec_helper"

RSpec.describe Errbit::Configuration do
  subject(:configuration) { described_class.new }

  describe "defaults" do
    it "starts unconfigured with a sensible ignore list and timeouts" do
      expect(configuration.host).to be_nil
      expect(configuration.project_id).to be_nil
      expect(configuration.api_key).to be_nil
      expect(configuration.ignore).to eq([])
      expect(configuration.open_timeout).to eq(2)
      expect(configuration.read_timeout).to eq(2)
    end
  end

  describe "#validate!" do
    it "raises ConfigurationError when required fields are missing" do
      expect { configuration.validate! }.to raise_error(
        Errbit::ConfigurationError, /host, project_id, api_key/
      )
    end

    it "does not raise once host/project_id/api_key are set" do
      configuration.host = "https://errbit.example.com"
      configuration.project_id = "abc"
      configuration.api_key = "secret"

      expect { configuration.validate! }.not_to raise_error
    end
  end

  describe "#ignored?" do
    it "matches by exception class, including subclasses" do
      configuration.ignore = [ArgumentError]

      expect(configuration.ignored?(TypeError.new)).to be false
      expect(configuration.ignored?(ArgumentError.new)).to be true
    end

    it "matches by regexp against message or class name" do
      configuration.ignore = [/timeout/i]

      expect(configuration.ignored?(RuntimeError.new("Connection timeout"))).to be true
      expect(configuration.ignored?(RuntimeError.new("boom"))).to be false
    end

    it "matches by exact class name string" do
      configuration.ignore = ["ArgumentError"]

      expect(configuration.ignored?(ArgumentError.new)).to be true
      expect(configuration.ignored?(TypeError.new)).to be false
    end
  end
end
