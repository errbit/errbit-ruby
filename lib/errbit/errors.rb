# frozen_string_literal: true

module Errbit
  Error = Class.new(StandardError)
  ConfigurationError = Class.new(Error)

  # Raised when the exception could not be delivered at all (network
  # failure, timeout, connection refused, ...). A well-formed HTTP error
  # response from the server (4xx/5xx) is *not* raised as this error; it is
  # surfaced via a failed Result instead.
  class DeliveryError < Error
    attr_reader :cause_error

    def initialize(cause_error)
      @cause_error = cause_error
      super("Failed to deliver error report: #{cause_error.class}: #{cause_error.message}")
    end
  end
end
