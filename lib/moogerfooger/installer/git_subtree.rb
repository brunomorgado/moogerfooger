require "moogerfooger/errors"
          
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
          system "git remote add -f #{moog.name} #{moog.repo}"
          system "git subtree add --prefix #{Mooger.default_moogs_dir.split().last.to_s + moog.name} #{moog.name} #{moog.branch} --squash"
        end
      end

      private

      def ensure_clean
        if repo_has_changes?
          raise GitRepoHasChangesError, "Working tree has modifications. Cannot continue"
        end
      end

      def repo_has_changes?
        has_staged_changes = !system("git diff --quiet --exit-code")
        has_unstaged_changes = !system("git diff --cached --quiet --exit-code")
        has_unstaged_changes || has_staged_changes
      end

      def check_if_remote_exists(remote_name)
        if remote_exists?(remote_name)
          raise GitRemoteExistsError, "There is already a remote called #{remote_name}. Cannot continue."
        end
      end

      def remote_exists?(remote_name)
        system "git config remote.#{remote_name}.url > /dev/null"
      end
    end
  end
end
