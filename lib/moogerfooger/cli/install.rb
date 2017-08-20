require "moogerfooger/installer"

module Mooger
    class CLI::Install

      def initialize(options)
        @options = options
      end

      def run
        installer = Installer.install(Mooger.definition(true), @options)
      end
    end
end
