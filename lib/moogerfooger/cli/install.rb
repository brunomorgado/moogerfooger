require "moogerfooger/installer"

module Mooger
    class CLI::Install

      def initialize(options)
        @options = options
      end

      def run
        installer = Mooger::Installer::GitSubtree.new(Mooger.definition(true), SharedHelpers.moogs_dir, @options)
        installer.run
      end
    end
end
