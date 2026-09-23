# frozen_string_literal: true

require "spec_helper"

RSpec.describe Errbit do
  describe ".configure" do
    it "yields a Configuration and persists changes across calls" do
      described_class.configure do |config|
        config.host = "https://errbit.example.com"
      end

      expect(described_class.configuration.host).to eq("https://errbit.example.com")
    end
  end

  describe ".notify" do
    before do
      described_class.configure do |config|
        config.host = "https://errbit.example.com"
        config.project_id = "proj-123"
        config.api_key = "secret-key"
      end
    end

    let(:exception) do
      raise RuntimeError, "boom"
    rescue RuntimeError => e
      e
    end

    it "delegates to a Client built from the current configuration" do
      stub_request(:post, "https://errbit.example.com/api/v1/projects/proj-123/errors/secret-key")
        .to_return(status: 202, body: JSON.generate(id: "err-1", created_at: "2026-09-23T00:00:00Z"))

      result = described_class.notify(exception)

      expect(result).to be_success
      expect(result.id).to eq("err-1")
    end

    it "does not send a request for an ignored exception" do
      described_class.configuration.ignore = [RuntimeError]

      result = described_class.notify(exception)

      expect(result).to be_ignored
      expect(WebMock).not_to have_requested(:post, /errbit.example.com/)
    end
  end
end
