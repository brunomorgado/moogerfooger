module Mooger
  class MoogerError < StandardError

    def self.status_code(code)
      define_method(:status_code) { code }
      if match = MoogerError.all_errors.find {|_k, v| v == code }
        error, _ = match
        raise ArgumentError,
          "Trying to register #{self} for status code #{code} but #{error} is already registered"
      end
      MoogerError.all_errors[self] = code
    end

    def self.all_errors
      @all_errors ||= {}
    end
  end

  class MoogerfileNotFound < MoogerError; status_code(3); end
  class MoogerfileError < MoogerError; status_code(4); end
  class InvalidOption < MoogerError; status_code(5); end
  class MoogerfileEvalError < MoogerfileError; end
end
