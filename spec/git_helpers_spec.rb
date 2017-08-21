require "spec_helper"
require_relative "../lib/moogerfooger/errors"
require_relative "../lib/moogerfooger/git_helpers"

RSpec.describe Mooger::GitHelpers do

  lib_name = "some_lib"

  describe "#remote_exists?" do

    $count = 0

    before(:each) do
      suffix = "#{Time.now.to_i}#{$count}"
      @repo_name = "repo_#{suffix}"
      @remote_name = "remote_#{suffix}"
      git_repo(@repo_name)
      $count += 1
    end

    it "should return true if remote exists" do
      do_in_repo(@repo_name) do
        Mooger::GitHelpers.add_remote(@remote_name, path_for_git_repo(@repo_name))
        expect(Mooger::GitHelpers.remote_exists?(@remote_name)).to be true
      end
    end

    it "should return false if remote does not exist" do
      do_in_repo(@repo_name) do
        expect(Mooger::GitHelpers.remote_exists?(@remote_name)).to be false
      end
    end
  end

  describe "#repo_has_changes?" do

    $count = 0

    before(:each) do
      suffix = "#{Time.now.to_i}#{$count}"
      @repo_name = "repo_#{suffix}"
      @remote_name = "remote_#{suffix}"
      git_repo(@repo_name)
      $count += 1
    end

    it "should return true if repo has staged files" do
      do_in_repo(@repo_name) do
        create_file
        git("add .")
        expect(Mooger::GitHelpers.repo_has_changes?).to be true
      end
    end

    it "should return false if remote has no changes" do
      do_in_repo(@repo_name) do
        expect(Mooger::GitHelpers.repo_has_changes?).to be false
      end
    end

  end

end
