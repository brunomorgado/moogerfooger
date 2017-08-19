require "pathname"
require "moogerfooger/version"

module Mooger

	require "moogerfooger/errors"
	require "moogerfooger/dsl"
  require "moogerfooger/definition"
  require "moogerfooger/shared_herlpers"
  require "moogerfooger/cli"

	class << self

    def root
      @root ||= SharedHelpers.root
    end

    def moogs_dir
      @moogs_dir ||= SharedHelpers.default_moogs_dir
    end

    def moogerfile
      @moogerfile ||= SharedHelpers.default_moogerfile
    end

    def lockfile
      @lockfile ||= SharedHelpers.default_lockfile
    end

    def definition
      @definition ||= begin
                        Definition.build(moogerfile)
                      end
    end
  end
end
