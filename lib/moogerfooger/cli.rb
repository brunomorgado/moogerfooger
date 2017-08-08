require 'thor'
require 'moogerfooger'

module Mooger
	class CLI < Thor

    desc "install", "Install the modules according to the Moogerfile specs"
    def install
      require "moogerfooger/cli/install"
      Install.new(options).run
    end

    desc "pull MOOG_NAME", "Pulls the specified module"
    def pull(moog_name)
      require "moogerfooger/cli/pull"
      Pull.new(options, moog_name).run
    end
  end
end

