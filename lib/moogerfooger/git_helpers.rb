require 'securerandom'

module Mooger
  module GitHelpers

    class << self 

      def is_git_repo?
        Dir.exists?(File.join(SharedHelpers.root, ".git"))
      end

      def repo_has_changes?
        has_staged_changes = !system("git diff --quiet --exit-code")
        has_unstaged_changes = !system("git diff --cached --quiet --exit-code")
        has_unstaged_changes || has_staged_changes
      end

      def current_branch
        branch_name = `git rev-parse --abbrev-ref HEAD`
        branch_name.strip
      end

      def branch_exists?(branch_name)
        return false unless branch_name
        system "git rev-parse --verify #{branch_name}"
      end

      def checkout_new_branch(name=SecureRandom.hex(4))
        unless name
          raise GitCheckoutBranchError, "Cannot checkout unspecified branch."
        end
        system "git checkout -b moogerfooger_tmp_#{name} --quiet"
        current_branch
      end

      def remote_exists?(remote_name)
        system "git config remote.#{remote_name}.url > /dev/null"
      end

      def add_remote(remote_name, remote_url)
        success = system("git remote add --no-tags -f #{remote_name} #{remote_url}")
        unless success 
          raise GitRemoteAddError, "Failed to add remote with name: #{remote_name} and url: #{remote_url}"
        end
      end

      def remove_remote(remote_name)
        return unless remote_exists?(remote_name)
        system "git remote remove #{remote_name}"
      end

      def add_subtree(path, remote_name, branch)
        success = system("git fetch #{remote_name}")
        success = success && system("git read-tree --prefix=#{path.to_s} -u #{remote_name}/#{branch}")
        unless success
          raise GitSubtreeAddError, "Failed to add subtree to remote with name: #{remote_name}"
        end
      end

      def remove_dir(path)
        return unless Dir.exists?(path)
        system "git rm -r --cached #{path}"
        system "rm -rf #{path}"
      end

      def pull_remote(path, remote_name, branch)
        system "git subtree pull --prefix=#{path.to_s} #{remote_name} #{branch}"
      end

      def push_remote(path, remote_name, branch)
        system "git subtree push --prefix=#{path.to_s} #{remote_name} #{branch}"
      end

      def subtree_path(remote_name)
        File.join(SharedHelpers.moogs_dir.split.last, remote_name)
      end
    end
  end
end
