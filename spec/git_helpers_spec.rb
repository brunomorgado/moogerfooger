require "spec_helper"
require 'securerandom'
require_relative "../lib/moogerfooger/errors"
require_relative "../lib/moogerfooger/git_helpers"
require_relative "../lib/moogerfooger/cli/install"

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

  describe "#is_git_repo?" do
    it "should return true if .git folder exists in the root" do
      create_git_repo(repo_name)
      do_in_repo(repo_name) do
        build_moogerfile
        expect(Mooger::GitHelpers.is_git_repo?).to be true
      end
    end

    it "should return false if .git does not folder exist in the root" do
      FakeFS.with_fresh do
        build_moogerfile
        expect(Mooger::GitHelpers.is_git_repo?).to be false
      end
    end
  end

  describe "#current_branch" do
    it "should return the correct name of the current branch" do
      create_git_repo(repo_name)
      do_in_repo(repo_name) do
        expect(Mooger::GitHelpers.current_branch).to eq "master"
      end
    end
  end

  describe "#branch_exists?" do
    it "should return true if specified branch exists" do
      create_git_repo(repo_name)
      do_in_repo(repo_name) do
        sut_branch_name = "sut_branch"
        git("checkout -b #{sut_branch_name}")
        expect(Mooger::GitHelpers.branch_exists?(sut_branch_name)).to be true
      end
    end

    it "should return false if specified branch does not exist" do
      create_git_repo(repo_name)
      do_in_repo(repo_name) do
        expect(Mooger::GitHelpers.branch_exists?("nonexistent_sut_branch")).to be false
      end
    end

    it "should return false if no branch specified" do
      create_git_repo(repo_name)
      do_in_repo(repo_name) do
        expect(Mooger::GitHelpers.branch_exists?(nil)).to be false
      end
    end
  end

  describe "#checkout_new_branch" do
    it "should raise GitCheckoutBranchError if branch name is nil" do
      create_git_repo(repo_name)
      do_in_repo(repo_name) do
        expect{Mooger::GitHelpers.checkout_new_branch(nil)}.to raise_error(Mooger::GitCheckoutBranchError)
      end
    end

    it "should switch to the specified branch" do
      create_git_repo(repo_name)
      do_in_repo(repo_name) do
        expect(Mooger::GitHelpers.current_branch).to eq "master"
        Mooger::GitHelpers.checkout_new_branch("new_branch")
        expect(Mooger::GitHelpers.current_branch).to eq "moogerfooger_tmp_new_branch"
      end
    end

    it "should switch to a new random branch when name not specified" do
      create_git_repo(repo_name)
      do_in_repo(repo_name) do
        expect(Mooger::GitHelpers.current_branch).to eq "master"
        Mooger::GitHelpers.checkout_new_branch
        expect(Mooger::GitHelpers.current_branch).to include("moogerfooger_tmp")
      end
    end

    it "should return the name of the created branch" do
      create_git_repo(repo_name)
      do_in_repo(repo_name) do
        expect(Mooger::GitHelpers.checkout_new_branch("new_branch")).to eq "moogerfooger_tmp_new_branch"
      end
    end
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

  describe "#pull_remote" do

    it "should pull the latest changes to the current repo"
  end

  #describe "#push_remote" do
    #let(:moog_repo_name) {"repo_#{SecureRandom.hex(5)}"}
    #let(:moog_repo_remote_url) {"#{path_for_git_repo(moog_repo_name)}"}

    #let(:consumer_repo_name) {"repo_#{SecureRandom.hex(5)}"}
    #let(:consumer_repo_remote_url) {"#{path_for_git_repo(consumer_repo_name)}"}
    #let(:create_moogerfile) { 
      #build_moogerfile <<-G
          #moog 'awesome_moog' do |m|
            #m.repo = "#{path_for_git_repo(moog_repo_name)}"
            #m.branch = "master"
          #end
      #G
    #}
    #it "should push the changes made in the remote's folder to the remote's repo" do
      #create_git_repo(moog_repo_name)
      #create_git_repo(consumer_repo_name)

      ##do_in_repo(consumer_repo_remote_name) do
      ##create_moogerfile
      ##git("add .")
      ##git("commit -m 'cleanup'")
      ##Mooger::CLI::Install.new.run
      ##expect(File.exist?("new_file.txt")).to be false
      ##end

      #do_in_repo(consumer_repo_name) do
        #create_moogerfile
        #Mooger::CLI::Install.new.run

        #Dir.chdir("Moogs/awesome_moog/") do
          #File.open("new_file.txt", "w") do |f|
            #f.puts("DUMMY FILE")
          #end
        #git("status")
        #end


          #git("add Moogs/awesome_moog/new_file.txt")
          #git("commit -m 'Add new file'")

        #git("status")
        #expect(File.exist?("Moogs/awesome_moog/new_file.txt")).to be true
        #Mooger::GitHelpers.push_remote(Mooger::GitHelpers.subtree_path("awesome_moog"), "awesome_moog", "master")
      #end

      #do_in_repo(moog_repo_name) do
        ##expect(File.exist?("Moogs/awesome_moog/new_file.txt")).to be true
      #end
    #end
  #end

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

    it "should remove the folder corresponding to the removed subtree" do
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
