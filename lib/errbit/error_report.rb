# frozen_string_literal: true

module Errbit
  module ErrorReport
    module_function

    # Builds a payload matching the ErrorReport schema in
    # openapi/errbit-api.yaml.
    def build(exception)
      {
        error: {
          class: exception.class.name,
          message: exception.message.to_s,
          backtrace: Backtrace.parse(exception)
        }
      }
    end
  end
end
