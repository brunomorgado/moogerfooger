require "spec_helper"
require 'securerandom'
require_relative "../lib/moogerfooger/errors"
require_relative "../lib/moogerfooger/git_helpers"

RSpec.describe Mooger::GitHelpers do

  let(:repo_name) {"repo_#{SecureRandom.hex(5)}"}
  let(:remote_url) {"#{path_for_git_repo(repo_name)}"}
  let(:remote_name) {"remote_#{SecureRandom.hex(5)}"}
  let(:add_valid_remote) {Mooger::GitHelpers.add_remote(remote_name, remote_url)}
  let(:add_invalid_remote) {Mooger::GitHelpers.add_remote(remote_name, "http://invalid.remote")}

  before(:each) do
    repo_name
    remote_url
    remote_name
  end

  describe "#remote_exists?" do

    it "should return true if remote exists" do
      create_git_repo(repo_name)
      do_in_repo(repo_name) do
        Mooger::GitHelpers.add_remote(remote_name, remote_url)
        expect(Mooger::GitHelpers.remote_exists?(remote_name)).to be true
      end
    end

    it "should return false if remote does not exist" do
      expect(Mooger::GitHelpers.remote_exists?(remote_name)).to be false
    end
  end

  describe "#repo_has_changes?" do

    before(:each) do
      create_git_repo(repo_name)
    end

    it "should return true if repo has uncommited files" do
      do_in_repo(repo_name) do
        create_file
        git("add .")
        expect(Mooger::GitHelpers.repo_has_changes?).to be true
      end
    end

    it "should return false if repo has commited files" do
      do_in_repo(repo_name) do
        create_file
        git("add .")
        git("commit -m 'test commit'")
        expect(Mooger::GitHelpers.repo_has_changes?).to be false
      end
    end

    it "should return false if remote has no changes" do
      do_in_repo(repo_name) do
        expect(Mooger::GitHelpers.repo_has_changes?).to be false
      end
    end

  end

  describe "#add_remote" do

    before(:each) do
      create_git_repo(repo_name)
    end

    it "should add a remote with a valid url" do
      do_in_repo(repo_name) do
        add_valid_remote
        expect(Mooger::GitHelpers.remote_exists?(remote_name)).to be true
      end
    end

    it "should raise an exception when adding a remote with an invalid url" do
      do_in_repo(repo_name) do
        expect {add_invalid_remote}.to raise_error(Mooger::GitRemoteAddError)
      end
    end

    it "should not add a remote with an invalid url" do
      do_in_repo(repo_name) do
        expect(Mooger::GitHelpers.remote_exists?(remote_name)).to be false
      end
    end
  end

  describe "#remove_remote" do

    let(:remove_remote) {Mooger::GitHelpers.remove_remote(remote_name)}

    before(:each) do
      create_git_repo(repo_name)
    end

    it "should remove an existing remote" do
      do_in_repo(repo_name) do
        add_valid_remote
        expect(Mooger::GitHelpers.remote_exists?(remote_name)).to be true
        remove_remote
        expect(Mooger::GitHelpers.remote_exists?(remote_name)).to be false
      end
    end

    it "should not crash when removing a non-existing remote" do
      do_in_repo(repo_name) do
        remove_remote
        expect(Mooger::GitHelpers.remote_exists?(remote_name)).to be false
      end
    end
  end


  describe "#add_subtree" do

    let(:add_subtree) {Mooger::GitHelpers.add_subtree(remote_name, remote_name, "master")}

    before(:each) do
      create_git_repo(repo_name)
    end

    it "should raise GitSubtreeAddError if there are uncommited files" do
      do_in_repo(repo_name) do
        add_valid_remote
        create_file
        git("add .")
        expect {add_subtree}.to raise_error(Mooger::GitSubtreeAddError)
      end
    end
  end

  describe "#remove_subtree" do

    let(:add_subtree) {Mooger::GitHelpers.add_subtree(remote_name, remote_name, "master")}
    let(:remove_subtree) {Mooger::GitHelpers.remove_subtree(remote_name)}

    before(:each) do
      create_git_repo(repo_name)
    end

    it "should raise GitSubtreeAddError if there are uncommited files" do
      do_in_repo(repo_name) do
        add_valid_remote
        add_subtree
        expect(Dir.exists?(remote_name)).to be true
        remove_subtree
        expect(Dir.exists?(remote_name)).to be false
      end
    end
  end

  describe "#subtree_path" do

    it "should return the correct path for the subtree"
  end
end
