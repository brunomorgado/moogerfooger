require "moogerfooger/installer"

module Mooger
    class CLI::Install
      attr_reader :options
      def initialize(options)
        @options = options
      end

      def run
        definition = Mooger.definition
        installer = Installer.install(Mooger.root_path, definition, options)
      end
    end
end
