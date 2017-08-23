require "spec_helper"
require "pry"
require_relative "../../lib/moogerfooger/installer/git_subtree"
require_relative "../../lib/moogerfooger/git_helpers"

RSpec.describe Mooger::Installer::GitSubtree do

  let(:repo_name) {"repo_#{SecureRandom.hex(5)}"}
  let(:remote_url) {"#{path_for_git_repo(repo_name)}"}
  let(:remote_name) {"remote_#{SecureRandom.hex(5)}"}
  let(:add_valid_remote) {Mooger::GitHelpers.add_remote(remote_name, remote_url)}
  let(:moogs) {[build_moog, build_moog]}
  let(:definition) {build_definition(moogs)}
  let(:subtree_installer) {build_subtree_installer(definition)}

  before(:each) do
    moogs
    definition
    subtree_installer
  end

  describe "#generate" do

    it "should raise GitRepoHasChangesError if repo has changes" do
      create_git_repo(repo_name)
      do_in_repo(repo_name) do
        create_file
        git("add .")
        expect {subtree_installer.generate}.to raise_error(Mooger::GitRepoHasChangesError)
      end
    end

    it "should raise GitRemoteExistsError if repo does not exist" do
      do_in_repo("non_existent") do
        expect {subtree_installer.generate}.to raise_error(Mooger::GitRemoteExistsError)
      end
    end

    it "should add the specified remotes to the git repo" do
      create_git_repo(repo_name)
      do_in_repo(repo_name) do
      add_valid_remote
        expect(Mooger::GitHelpers.remote_exists?(remote_name)).to be true
        expect(Mooger::GitHelpers.remote_exists?("invalid_name")).to be false
      end
    end

    it "should add the specified remotes to the git repo" do
      create_git_repo(repo_name)
      do_in_repo("invalid_repo") do
        add_valid_remote
        expect(Mooger::GitHelpers.remote_exists?(remote_name)).to be false
      end
    end

  end
end
