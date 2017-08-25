require "moogerfooger/errors"
require "moogerfooger/git_helpers"

module Mooger
  class Installer
    class GitSubtree

      def initialize(definition, moogs_dir, options = {})
        @definition = definition
        @moogs_dir = moogs_dir
      end

      def run
        ensure_definition_has_moogs
        create_moogs_dir_if_needed
        generate
      end

      def generate
        ensure_clean
        @definition.moogs.each do |moog|
          check_if_remote_exists(moog.name)
          begin
            GitHelpers.add_remote(moog.name, moog.repo)
            GitHelpers.add_subtree(subtree_path(moog.name), moog.name, moog.branch)
          rescue => e
            GitHelpers.remove_remote(moog.name)
            GitHelpers.remove_subtree(subtree_path(moog.name))
            raise e
          end
        end
      end

      private

      def create_moogs_dir_if_needed
        return unless @moogs_dir.nil?
        Dir.mkdir(SharedHelpers.moogs_dir_path.to_s)
      end

      def ensure_definition_has_moogs
        if @definition.moogs.empty?
          raise DefinitionHasNoMoogsError, "The definition has no moogs. Cannot continue"
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

      def subtree_path(remote_name)
        File.join(@moogs_dir.split.last, remote_name)
      end
    end
  end
end
