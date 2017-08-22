module Mooger
  module GitHelpers

    class << self 

      def repo_has_changes?
        has_staged_changes = !system("git diff --quiet --exit-code")
        has_unstaged_changes = !system("git diff --cached --quiet --exit-code")
        has_unstaged_changes || has_staged_changes
      end

      def remote_exists?(remote_name)
        system "git config remote.#{remote_name}.url > /dev/null"
      end

      def add_remote(remote_name, remote_url)
        success = system("git remote add -f #{remote_name} #{remote_url}")
        unless success 
          raise GitRemoteAddError, "Failed to add remote with name: #{remote_name} and url: #{remote_url}"
        end
      end

      def remove_remote(remote_name)
        return unless remote_exists?(remote_name)
        system "git remote remove #{remote_name}"
      end

      def add_subtree(path, remote_name, branch)
        success = system("git subtree add --prefix=#{path.to_s} #{remote_name} #{branch} --squash")
        unless success
          raise GitSubtreeAddError, "Failed to add subtree to remote with name: #{remote_name}"
        end
      end
    end
  end
end
