require "spec_helper"
require 'fakefs/safe'
require_relative "../../lib/moogerfooger/git_helpers"
require_relative "../../lib/moogerfooger/cli/pull"

RSpec.describe Mooger::CLI::Pull do

  let(:repo_name) {"repo_#{SecureRandom.hex(5)}"}
  let(:remote_url) {"#{path_for_git_repo(repo_name)}"}
  let(:remote_name) {"remote_#{SecureRandom.hex(5)}"}
  let(:add_valid_remote) {Mooger::GitHelpers.add_remote(remote_name, remote_url)}
  let(:add_invalid_remote) {Mooger::GitHelpers.add_remote(remote_name, "http://invalid.remote")}
  let(:create_lockfile) { 
    build_lockfile <<-G
    ---
    awesome_moog:
      name: awesome_moog
      repo: git@github.com:brunomorgado/RxErrorTracker.git
      branch: master
    G
  }

  describe "#run" do

    it "should raise MoogNotFound if moog is not specified in the lokcfile" do
      FakeFS.with_fresh do
        create_lockfile
        expect{Mooger::CLI::Pull.new({}, "absent_moog").run}.to raise_error(Mooger::MoogNotFound)
      end
    end

    it "should invoke pull_remote on GitHelpers" do
      FakeFS.with_fresh do
        build_moogerfile
        create_lockfile
        build_moogs_dir
        allow(Mooger::GitHelpers).to receive(:pull_remote)
        expect(Mooger::GitHelpers).to receive(:pull_remote)
        Mooger::CLI::Pull.new({}, "awesome_moog").run
      end
    end
  end
end


