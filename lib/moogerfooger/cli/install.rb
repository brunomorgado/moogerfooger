require "moogerfooger/installer/git_subtree"

module Mooger
    class CLI::Install

      def initialize(options={})
        @options = options
      end

      def run
        begin
          ensure_clean
          definition = Mooger.definition(true)
          commit_moogerfooger_files
          installer = Mooger::Installer::GitSubtree.new(definition, @options)
          installer.run
        rescue => e
          Mooger.reset
        end
      end

      private

      def ensure_clean
        if GitHelpers.repo_has_changes?
          raise GitRepoHasChangesError, "Working tree has modifications. Cannot continue"
        end
      end

      def commit_moogerfooger_files
        system "git add Moogerfile.lock"
        system "git add Moogs"
        system "git commit -m 'Update Moogerfooger files'"
      end
    end
end
