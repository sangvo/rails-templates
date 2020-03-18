require 'forwardable'

module Template
  class Errors
    extend Forwardable

    def_delegators :errors, :empty?

    def initialize
      @errors = []
    end

    def add(error_message)
      errors << error_message
    end

    def to_s
      errors.join("#{'-' * 80}\n")
    end

    private

    attr_reader :errors
  end
end
