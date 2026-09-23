# frozen_string_literal: true

require "net/http"
require "json"
require "uri"

module Errbit
  class Client
    NETWORK_ERRORS = [
      Errno::ECONNREFUSED,
      Errno::ECONNRESET,
      Errno::EHOSTUNREACH,
      SocketError,
      Timeout::Error,
      Net::OpenTimeout,
      Net::ReadTimeout,
      OpenSSL::SSL::SSLError
    ].freeze

    def initialize(configuration)
      @configuration = configuration
    end

    def notify(exception)
      return Result.ignored if configuration.ignored?(exception)

      configuration.validate!
      deliver(ErrorReport.build(exception))
    end

    private

    attr_reader :configuration

    def deliver(payload)
      uri = endpoint_uri
      request = Net::HTTP::Post.new(uri)
      request["Content-Type"] = "application/json"
      request["Accept"] = "application/json"
      request.body = JSON.generate(payload)

      response = http_client(uri).request(request)
      build_result(response)
    rescue *NETWORK_ERRORS => e
      raise DeliveryError, e
    end

    def http_client(uri)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      http.open_timeout = configuration.open_timeout
      http.read_timeout = configuration.read_timeout
      http
    end

    def endpoint_uri
      base = configuration.host.to_s.chomp("/")
      URI.parse(
        "#{base}/api/v1/projects/#{escape(configuration.project_id)}/errors/#{escape(configuration.api_key)}"
      )
    end

    def escape(value)
      URI.encode_www_form_component(value.to_s)
    end

    def build_result(response)
      body = parse_json(response.body)

      case response
      when Net::HTTPAccepted
        Result.success(status_code: response.code.to_i, id: body["id"], created_at: body["created_at"])
      else
        Result.failure(status_code: response.code.to_i, error: body["error"] || response.message)
      end
    end

    def parse_json(raw)
      return {} if raw.nil? || raw.empty?

      JSON.parse(raw)
    rescue JSON::ParserError
      {}
    end
  end
end
