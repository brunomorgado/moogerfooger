require "moogerfooger/installer"

module Mooger
    class CLI::Install

      def initialize(options)
        @options = options
      end

      def run
        installer = Installer.install(SharedHelpers.root, Mooger.definition(true), @options)
      end
    end
end
