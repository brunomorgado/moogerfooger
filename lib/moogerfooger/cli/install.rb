require "moogerfooger/installer"

module Mooger
    class CLI::Install

      def initialize(options)
        @options = options
      end

      def run
        installer = Installer.install(Mooger.root, Mooger.definition, options)
      end
    end
end
