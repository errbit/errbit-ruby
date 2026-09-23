# frozen_string_literal: true

module Errbit
  module Backtrace
    # Matches both backtrace line formats Ruby has used:
    #   "file.rb:12:in `method'"   (Ruby <= 3.3)
    #   "file.rb:12:in 'method'"   (Ruby >= 3.4)
    # and lines with no method info at all: "file.rb:12"
    LINE_PATTERN = /\A(?<file>.+):(?<line>\d+)(?::in\s+[`'](?<method>.+)')?\z/.freeze

    module_function

    def parse(exception)
      Array(exception&.backtrace).map { |line| parse_line(line) }
    end

    def parse_line(line)
      match = LINE_PATTERN.match(line.to_s)
      return { file: line.to_s, line: nil, method: nil } unless match

      {
        file: match[:file],
        line: match[:line].to_i,
        method: match[:method]
      }
    end
  end
end
