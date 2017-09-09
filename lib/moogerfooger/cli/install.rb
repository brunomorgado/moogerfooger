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
        # Ensure definition has moogs
        ensure_definition_has_moogs(definition)
        # Create the Moogs dir
        create_moogs_dir_if_needed
        # Proceed with subtrees installation
        installer = Mooger::Installer::GitSubtree.new(definition, @options)
        installer.run
      rescue DefinitionHasNoMoogsError => e
        #TODO: Warning
      rescue => e
        puts e
      else
      ensure
        stage_generated_files
      end
    end

    private

    def ensure_clean
      if GitHelpers.repo_has_changes?
        raise GitRepoHasChangesError, "Working tree has modifications. Cannot continue"
      end
    end

    def ensure_definition_has_moogs definition
      if definition.moogs.nil? || definition.moogs.empty?
        raise DefinitionHasNoMoogsError
      end
    end

    def create_moogs_dir_if_needed
      return unless SharedHelpers.moogs_dir.nil?
      Dir.mkdir(SharedHelpers.moogs_dir_path.to_s)
    end

    def stage_generated_files
      system "git add #{SharedHelpers.moogs_dir_path.to_s}"
      system "git add #{Mooger::SharedHelpers.lockfile_path}"
    end
  end
end
