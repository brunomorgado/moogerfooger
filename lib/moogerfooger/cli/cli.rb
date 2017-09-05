require 'thor'
require 'moogerfooger'

module Mooger
	class CLI < Thor

    desc "install [OPTIONS]", "Install the modules according to the Moogerfile specs"
    def install
      require "moogerfooger/cli/install"
      Install.new(options).run
    end

    desc "pull MOOG_NAME", "Pulls the specified module"
    def pull(moog_name)
      require "moogerfooger/cli/pull"
      Pull.new(options, moog_name).run
    end

    desc "push MOOG_NAME", "Pushes the specified module"
    def push(moog_name)
      require "moogerfooger/cli/push"
      Push.new(options, moog_name).run
    end

    desc "list", "Lists the installed moogs"
    def list
      require "moogerfooger/cli/list"
      List.new(options).run
    end
  end
end

