# frozen_string_literal: true

require_relative "errbit/version"
require_relative "errbit/errors"
require_relative "errbit/result"
require_relative "errbit/backtrace"
require_relative "errbit/error_report"
require_relative "errbit/configuration"
require_relative "errbit/client"

module Errbit
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield configuration
      @client = nil
      configuration
    end

    def notify(exception)
      client.notify(exception)
    end

    # Resets configuration and memoized client. Primarily useful in tests.
    def reset!
      @configuration = nil
      @client = nil
    end

    private

    def client
      @client ||= Client.new(configuration)
    end
  end
end
