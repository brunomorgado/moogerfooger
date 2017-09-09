require "moogerfooger/git_helpers"

module Mooger
  class CLI::Push

    def initialize(options, moog_name)
      @options = options
      @moog_name = moog_name
      @moog = Moog.find(moog_name)
    end

    def run
      begin
        ensure_clean
        ensure_moog_exists
        GitHelpers.push_remote(GitHelpers.subtree_path(@moog.name), @moog.name, @moog.branch)
      rescue => e
        puts e
      end
    end

    private

    def ensure_clean
      if GitHelpers.repo_has_changes?
        raise GitRepoHasChangesError, "Working tree has modifications. Cannot continue"
      end
    end

    def ensure_moog_exists
      if @moog.nil?
        raise MoogNotFound, "Moog with name: #{@moog_name} not found. Unable to push."
      end
    end
  end
end
