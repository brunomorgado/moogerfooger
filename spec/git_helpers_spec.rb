require "spec_helper"
require_relative "../lib/moogerfooger/errors"
require_relative "../lib/moogerfooger/git_helpers"

RSpec.describe Mooger::GitHelpers do

  lib_name = "some_lib"

  before(:all) do
    git_repo(lib_name)
  end

  $count = 0

  describe "#remote_exists?" do

    before(:each) do
      @remote_name = "lib#{Time.now.to_i}#{$count}"
      $count += 1
    end

    it "should return true if remote exists" do
      Mooger::GitHelpers.add_remote(@remote_name, path_for_git_repo(lib_name))
      expect(Mooger::GitHelpers.remote_exists?(@remote_name)).to be true
    end

    it "should return false if remote does not exist" do
      expect(Mooger::GitHelpers.remote_exists?(@remote_name)).to be false
    end
  end

  describe "#repo_has_changes?" do

    before(:each) do
      @remote_name = "lib#{Time.now.to_i}#{$count}"
      $count += 1
    end

    it "should return true if repo has unstaged files" do
      create_file(path_for_git_repo(lib_name))
      expect(Mooger::GitHelpers.repo_has_changes?).to be false
    end

    it "should return false if remote has no changes" do
      git("reset --hard")
      expect(Mooger::GitHelpers.repo_has_changes?).to be false
    end

  end
end
