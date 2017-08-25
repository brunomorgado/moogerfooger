require "moogerfooger/installer/git_subtree"

module Mooger
    class CLI::Install

      def initialize(options={})
        @options = options
      end

      def run
        begin
        installer = Mooger::Installer::GitSubtree.new(Mooger.definition(true), SharedHelpers.moogs_dir, @options)
        installer.run
        rescue => e
          Mooger.reset
        end
      end
    end
end
