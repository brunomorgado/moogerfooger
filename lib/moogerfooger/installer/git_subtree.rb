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
          add_remote(moog.name, moog.repo)
          add_subtree(Mooger.default_moogs_dir.split().last.to_s + moog.name, moog.name, moog.branch)
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

      def add_remote(remote_name, remote_url)
        success = system("git remote add -f #{remote_name} #{remote_url}")
        unless success 
          remove_remote(remote_name)
          raise GitRemoteAddError, "Failed to add remote with name: #{remote_name} and url: #{remote_url}"
        end
      end

      def remove_remote(remote_name)
        return unless remote_exists?(remote_name)
        system "git remote remove #{remote_name}"
      end

      def add_subtree(prefix, remote_name, branch)
        success = system("git subtree add --prefix=#{prefix} #{remote_name} #{branch} --squash")
        unless success
          remove_remote(remote_name)
          raise GitSubtreeAddError, "Failed to add subtree to remote with name: #{remote_name}"
        end
      end
    end
  end
end
