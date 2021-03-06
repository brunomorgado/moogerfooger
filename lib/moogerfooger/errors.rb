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

  class MoogerfileNotFound < MoogerError; status_code(1); end
  class MoogerfileError < MoogerError; status_code(2); end
  class LockfileNotFound < MoogerError; status_code(3); end
  class LockfileError < MoogerError; status_code(4); end
  class InvalidOption < MoogerError; status_code(5); end
  class MoogerfileEvalError < MoogerfileError; end
  class GitRemoteExistsError < MoogerError; status_code(6); end
  class GitRepoHasChangesError < MoogerError; status_code(7); end
  class GitRemoteAddError < MoogerError; status_code(8); end
  class GitSubtreeAddError < MoogerError; status_code(9); end
  class GitCheckoutBranchError < MoogerError; status_code(10); end
  class NotAGitRepoError < MoogerError; status_code(11); end
  class DefinitionIsNilError < MoogerError; status_code(13); end
  class DefinitionHasNoMoogsError < MoogerError; status_code(14); end
  class MoogNotFound < MoogerError; status_code(15); end
end
