require "spec_helper"
require "moogerfooger"
require 'fakefs/spec_helpers'
require_relative "../lib/moogerfooger/installer/git_subtree"
require_relative "../lib/moogerfooger/git_helpers"

RSpec.describe Moogerfooger do
  it "has a version number" do
    expect(Moogerfooger::VERSION).not_to be nil
  end

  describe "#reset" do

    let(:repo_name) {"repo_#{SecureRandom.hex(5)}"}
    let(:moogs) {[build_moog("moog1", path_for_git_repo(repo_name)), build_moog("moog2", path_for_git_repo(repo_name))]}
    let(:definition) {build_definition(moogs)}
    let(:moogs_dir) {Mooger::SharedHelpers.moogs_dir}
    let(:create_lockfile) { 
      build_lockfile <<-G
        ---
        awesome_moog1:
          name: awesome_moog1
          repo: git@github.com:brunomorgado/RxErrorTracker.git
          branch: master
        awesome_moog2:
          name: awesome_moog2
          repo: git@github.com:brunomorgado/RxErrorTracker.git
          branch: master
          G
    }
    let(:subtree_installer) {build_subtree_installer(Mooger.definition(true))}

    it "should reset definition" do
      FakeFS.with_fresh do
        build_moogerfile
        definition = Mooger.definition(true)
        expect(definition).to_not be nil
        expect(Mooger.definition).to be definition
        Mooger.reset
        expect(Mooger.definition).to_not be definition
      end
    end

    it "should delete the lockfile" do
      FakeFS.with_fresh do
        build_moogerfile
        build_lockfile
        expect(Mooger::SharedHelpers.lockfile).to_not be nil
        Mooger.reset
        expect(Mooger::SharedHelpers.lockfile).to be nil
      end
    end

    it "should delete the moogs dir recursively" do
      FakeFS.with_fresh do
        create_lockfile
        build_moogerfile
        build_moogs_dir
        Dir.chdir(Mooger::SharedHelpers.moogs_dir_path) do
          Dir.mkdir("awesome_moog")
        end
        expect(Dir.exists?(Mooger::SharedHelpers.moogs_dir_path)).to be true
        Mooger.reset
        expect(Dir.exists?(Mooger::SharedHelpers.moogs_dir_path)).to be false
      end
    end

    it "should remove the installed remotes" do
      create_git_repo(repo_name)
      do_in_repo(repo_name) do
        build_moogerfile
        create_lockfile
        git("remote add awesome_moog1 http://url")
        git("remote add awesome_moog2 http://url")
        git("remote -v")
        expect(Mooger::GitHelpers.remote_exists?("awesome_moog1")).to be true
        expect(Mooger::GitHelpers.remote_exists?("awesome_moog2")).to be true
        expect(Mooger::GitHelpers.remote_exists?("non_existent")).to be false
        # Should generate 2 remotes
        expect(`git remote -v | wc -l`.to_i/2).to eq 2
        Mooger.reset
        expect(`git remote -v | wc -l`.to_i/2).to eq 0
      end
    end
  end
end
