# frozen_string_literal: true

module Errbit
  class Configuration
    attr_accessor :host, :project_id, :api_key, :ignore, :open_timeout, :read_timeout

    def initialize
      @host = nil
      @project_id = nil
      @api_key = nil
      @ignore = []
      @open_timeout = 2
      @read_timeout = 2
    end

    def ignored?(exception)
      ignore.any? do |pattern|
        case pattern
        when Module
          exception.is_a?(pattern)
        when Regexp
          pattern.match?(exception.message.to_s) || pattern.match?(exception.class.name.to_s)
        else
          pattern.to_s == exception.class.name
        end
      end
    end

    def validate!
      missing = %i[host project_id api_key].select { |attr| public_send(attr).nil? || public_send(attr).to_s.empty? }
      return if missing.empty?

      raise ConfigurationError, "Errbit is missing required configuration: #{missing.join(', ')}"
    end
  end
end
