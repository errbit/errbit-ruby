# frozen_string_literal: true

module Errbit
  # Outcome of a Client#notify call.
  class Result
    attr_reader :status, :status_code, :id, :created_at, :error

    def self.ignored
      new(status: :ignored)
    end

    def self.success(status_code:, id:, created_at:)
      new(status: :success, status_code: status_code, id: id, created_at: created_at)
    end

    def self.failure(status_code:, error:)
      new(status: :failure, status_code: status_code, error: error)
    end

    def initialize(status:, status_code: nil, id: nil, created_at: nil, error: nil)
      @status = status
      @status_code = status_code
      @id = id
      @created_at = created_at
      @error = error
    end

    def success?
      status == :success
    end

    def ignored?
      status == :ignored
    end

    def failure?
      status == :failure
    end
  end
end
