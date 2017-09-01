require "spec_helper"
require 'fakefs/safe'
require_relative "../../lib/moogerfooger/git_helpers"
require_relative "../../lib/moogerfooger/cli/pull"

RSpec.describe Mooger::CLI::Pull do

  let(:create_moogerfile) { 
    build_moogerfile <<-G
    moog 'awesome_moog' do |m|
      m.repo = "git@github.com:brunomorgado/RxErrorTracker.git"
      m.branch = "master"
    end
   G
  }
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

    it "should raise MoogNotFound if moog is not specified in the lockfile" do
      FakeFS.with_fresh do
        create_lockfile
        expect{Mooger::CLI::Pull.new({}, "absent_moog").run}.to raise_error(Mooger::MoogNotFound)
      end
    end

    it "should invoke pull_remote on GitHelpers"
    #do
      #FakeFS.with_fresh do
        #create_moogerfile
        #create_lockfile
        #build_moogs_dir
        #allow(Mooger::GitHelpers).to receive(:pull_remote)
        #expect(Mooger::GitHelpers).to receive(:pull_remote)
        #Mooger::CLI::Pull.new({}, "awesome_moog").run
      #end
    #end
  end
end


