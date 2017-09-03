require "moogerfooger/installer/git_subtree"

module Mooger
    class CLI::Install

      def initialize(options={})
        @options = options
      end

      def run
        begin
          puts "BEGIN"
          # Get a reference of the current branch's name
          original_branch = GitHelpers.current_branch
          # Ensure that the working tree is clean
          ensure_clean
          # Checkout to a new temporary branch and hold its name
          tmp_branch = GitHelpers.checkout_new_branch
          # Get a reference to the definition. Passing True will unlock the Moogerfile
          definition = Mooger.definition(true)
          # Regenerate the Moogs dir
          create_moogs_dir_if_needed
          # Clean working tree by commiting the recently changed files
          commit_moogerfooger_files
          # Proceed with subtrees installation
          installer = Mooger::Installer::GitSubtree.new(definition, @options)
          installer.run
        rescue => e
          puts "RESCUE"
          puts e
        else
          puts "ELSE"
          # Merge changes
          system "git checkout #{original_branch} --quiet"
          system "git merge #{tmp_branch} --quiet"
        ensure
          puts "ENSURE"
          # Checkout original branch
          system "git checkout #{original_branch} --quiet" unless original_branch == GitHelpers.current_branch
          # Remove temp branch
          system "git branch -D #{tmp_branch} --quiet" if GitHelpers.branch_exists?(tmp_branch)
        end
      end

      private

      def ensure_clean
        if GitHelpers.repo_has_changes?
          raise GitRepoHasChangesError, "Working tree has modifications. Cannot continue"
        end
      end

      def create_moogs_dir_if_needed
        return unless SharedHelpers.moogs_dir.nil?
        Dir.mkdir(SharedHelpers.moogs_dir_path.to_s)
      end

      def commit_moogerfooger_files
        system "git add #{Mooger::SharedHelpers.lockfile_path}" if File.exist?(Mooger::SharedHelpers.lockfile_path)
        system "git add #{Mooger::SharedHelpers.moogs_dir_path}" if Dir.exist?(Mooger::SharedHelpers.moogs_dir_path)
        system "git commit -m 'Update Moogerfooger files' --quiet"
      end
    end
end
