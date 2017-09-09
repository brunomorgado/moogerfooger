require "spec_helper"
require 'fakefs/safe'
require_relative "../../lib/moogerfooger/git_helpers"
require_relative "../../lib/moogerfooger/cli/push"
require_relative "../../lib/moogerfooger/cli/install"

RSpec.describe Mooger::CLI::Push do

  let(:repo_name) {"repo_#{SecureRandom.hex(5)}"}
  let(:create_moogerfile) { 
    build_moogerfile <<-G
          moog 'awesome_moog' do |m|
            m.repo = "#{path_for_git_repo(repo_name)}"
            m.branch = "master"
          end
    G
  }

  describe "#run" do

    #it "should raise MoogNotFound if moog is not specified in the lockfile" do
      #create_git_repo(repo_name)
      #do_in_repo(repo_name) do
        #create_moogerfile
        #git("add .")
        #git("commit -m 'cleanup'")
        #Mooger::CLI::Install.new.run
        #expect{Mooger::CLI::Push.new({}, "absent_moog").run}.to raise_error(Mooger::MoogNotFound)
      #end
    #end

    it "should invoke push_remote on GitHelpers" do
      create_git_repo(repo_name)
      do_in_repo(repo_name) do
        create_moogerfile
        git("add .")
        git("commit -m 'cleanup'")
        Mooger::CLI::Install.new.run
        subtree_path = Mooger::GitHelpers.subtree_path("awesome_moog")
        allow(Mooger::GitHelpers).to receive(:push_remote)
        expect(Mooger::GitHelpers).to receive(:push_remote).with(subtree_path, "awesome_moog", "master")
        Mooger::CLI::Push.new({}, "awesome_moog").run
      end
    end

    it "should invoke subtree_path on GitHelpers" do
      create_git_repo(repo_name)
      do_in_repo(repo_name) do
        create_moogerfile
        git("add .")
        git("commit -m 'cleanup'")
        Mooger::CLI::Install.new.run
        allow(Mooger::GitHelpers).to receive(:subtree_path)
        expect(Mooger::GitHelpers).to receive(:subtree_path).with("awesome_moog")
        Mooger::CLI::Push.new({}, "awesome_moog").run
      end
    end
  end
end

