require "moogerfooger/errors"
require "moogerfooger/git_helpers"
require "pry"         
module Mooger
  class Installer
    class GitSubtree

      def initialize(definition)
        @definition = definition
      end

      def generate
        ensure_clean
        @definition.moogs.each do |moog|
          check_if_remote_exists(moog.name)
          begin
            GitHelpers.add_remote(moog.name, moog.repo)
            GitHelpers.add_subtree(SharedHelpers.moogs_dir.split().last + moog.name, moog.name, moog.branch)
          rescue 
            GitHelpers.remove_remote(moog.name)
          end
        end
      end

      private

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
