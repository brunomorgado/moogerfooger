require "moogerfooger/errors"
require "moogerfooger/git_helpers"

module Mooger
  class Installer
    class GitSubtree

      def initialize(definition, options = {})
        @definition = definition
      end

      def run
        ensure_definition_exists
        warn_if_no_moogs
        generate
      end

      def generate
        #ensure_clean
        @definition.moogs.each do |moog|
          check_if_remote_exists(moog.name)
          begin
            GitHelpers.add_remote(moog.name, moog.repo)
            GitHelpers.add_subtree(GitHelpers.subtree_path(moog.name), moog.name, moog.branch)
          rescue => e
            GitHelpers.remove_remote(moog.name)
            GitHelpers.remove_dir(GitHelpers.subtree_path(moog.name))
            raise e
          end
        end
      end

      private

      def ensure_definition_exists
        if @definition.nil?
          raise DefinitionIsNilError, "The definition is nil. Cannot continue"
        end
      end

      def warn_if_no_moogs
        if @definition.moogs.empty?
          #TODO: Warning
          #raise DefinitionHasNoMoogsError, "The definition has no moogs. Cannot continue"
        end
      end

      def ensure_clean
        if GitHelpers.repo_has_changes?
          raise GitRepoHasChangesError, "Working tree has modifications. Cannot continue"
        end
      end

      def check_if_remote_exists(remote_name)
        if GitHelpers.remote_exists?(remote_name)
          raise GitRemoteExistsError, "There is already a remote called #{remote_name}. Cannot continue."
        end
      end
    end
  end
end
