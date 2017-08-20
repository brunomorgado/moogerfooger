require "pathname"
require "moogerfooger/version"

module Mooger

	require "moogerfooger/errors"
	require "moogerfooger/dsl"
  require "moogerfooger/definition"
  require "moogerfooger/shared_herlpers"
  require "moogerfooger/cli/cli"

	class << self

    def reset
      @definition = nil
      File.delete(SharedHelpers.lockfile) if SharedHelpers.file_exists? SharedHelpers.lockfile
    end

    def definition(unlock)
      reset if unlock
      @definition ||= Definition.build
    end

    def locked?
      SharedHelpers.file_exists? SharedHelpers.lockfile
    end
  end
end
