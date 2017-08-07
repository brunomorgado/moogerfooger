require 'thor'
require 'moogerfooger'

module Mooger
	class CLI < Thor

    desc "install", "Install the modules according to the Moogerfile specs"
    def install
      require "moogerfooger/cli/install"
      Install.new(options.dup).run
    end

	end
end

