# frozen_string_literal: true

require "spec_helper"

RSpec.describe Errbit::Client do
  subject(:client) { described_class.new(configuration) }

  let(:configuration) do
    Errbit::Configuration.new.tap do |config|
      config.host = "https://errbit.example.com"
      config.project_id = "proj-123"
      config.api_key = "secret-key"
    end
  end

  let(:exception) do
    raise ArgumentError, "invalid input"
  rescue ArgumentError => e
    e
  end

  let(:endpoint) { "https://errbit.example.com/api/v1/projects/proj-123/errors/secret-key" }

  it "POSTs the error report JSON to the configured endpoint" do
    stub = stub_request(:post, endpoint)
           .with(
             headers: { "Content-Type" => "application/json" },
             body: hash_including("error" => hash_including("class" => "ArgumentError", "message" => "invalid input"))
           )
           .to_return(
             status: 202,
             body: JSON.generate(id: "err-1", created_at: "2026-09-23T00:00:00Z"),
             headers: { "Content-Type" => "application/json" }
           )

    result = client.notify(exception)

    expect(stub).to have_been_requested
    expect(result).to be_success
    expect(result.id).to eq("err-1")
    expect(result.created_at).to eq("2026-09-23T00:00:00Z")
  end

  it "returns a failure result on a 400 response without raising" do
    stub_request(:post, endpoint).to_return(
      status: 400,
      body: JSON.generate(error: "class is required"),
      headers: { "Content-Type" => "application/json" }
    )

    result = client.notify(exception)

    expect(result).to be_failure
    expect(result.status_code).to eq(400)
    expect(result.error).to eq("class is required")
  end

  it "returns a failure result on a 401 response without raising" do
    stub_request(:post, endpoint).to_return(status: 401, body: JSON.generate(error: "invalid api_key"))

    result = client.notify(exception)

    expect(result).to be_failure
    expect(result.status_code).to eq(401)
  end

  it "raises Errbit::DeliveryError on a network failure" do
    stub_request(:post, endpoint).to_raise(Errno::ECONNREFUSED)

    expect { client.notify(exception) }.to raise_error(Errbit::DeliveryError)
  end

  it "returns an ignored result without making a request when the exception is ignored" do
    configuration.ignore = [ArgumentError]

    result = client.notify(exception)

    expect(result).to be_ignored
    expect(WebMock).not_to have_requested(:post, endpoint)
  end

  it "raises ConfigurationError when required config is missing" do
    configuration.api_key = nil

    expect { client.notify(exception) }.to raise_error(Errbit::ConfigurationError)
  end
end
