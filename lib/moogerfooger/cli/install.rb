require "moogerfooger/installer/git_subtree"

module Mooger
  class CLI::Install

    def initialize(options={})
      @options = options
    end

    def run
      begin
        # Ensure that the working tree is clean
        ensure_clean
        # Get a reference to the definition.
        # Passing True will unlock the Moogerfile and regenerate the lockfile
        definition = Mooger.definition(true)
        # Stage recently generated lockfile
        stage_lockfile
        # Interrupt if there are no Moogs defined
        if definition.moogs.nil? || definition.moogs.empty?
          #TODO: Warning
          return 
        end
        # Regenerate the Moogs dir
        create_moogs_dir_if_needed
        # Proceed with subtrees installation
        installer = Mooger::Installer::GitSubtree.new(definition, @options)
        installer.run
      rescue => e
        puts e
      else
      ensure
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
      system "git add #{SharedHelpers.moogs_dir_path.to_s}"
    end

    def stage_lockfile
      system "git add #{Mooger::SharedHelpers.lockfile_path}" if File.exist?(Mooger::SharedHelpers.lockfile_path)
    end
  end
end
