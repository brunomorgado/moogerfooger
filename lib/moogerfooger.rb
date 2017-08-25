require "pathname"
require "moogerfooger/version"
require "pry"

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
      FileUtils.rm_rf(SharedHelpers.moogs_dir_path.to_s)
        binding.pry
      SharedHelpers.installed_moogs.each { |remote|
        GitHelpers.remove_remote(remote)
      }
    end

    def definition(unlock=false)
      reset if unlock
      @definition ||= Definition.build
    end

    def locked?
      SharedHelpers.file_exists? SharedHelpers.lockfile
    end
  end
end
