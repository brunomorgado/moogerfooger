require "spec_helper"
require "pry"
require 'fakefs/safe'
require_relative "../../lib/moogerfooger/git_helpers"
require_relative "../../lib/moogerfooger/cli/install"

RSpec.describe Mooger::CLI::Install do

  let(:repo_name) {"repo_#{SecureRandom.hex(5)}"}
  let(:remote_url) {"#{path_for_git_repo(repo_name)}"}
  let(:remote_name) {"remote_#{SecureRandom.hex(5)}"}
  let(:add_valid_remote) {Mooger::GitHelpers.add_remote(remote_name, remote_url)}
  let(:add_invalid_remote) {Mooger::GitHelpers.add_remote(remote_name, "http://invalid.remote")}
  let(:create_moogerfile) { 
    build_moogerfile <<-G
          moog 'awesome_moog' do |m|
            m.repo = "#{path_for_git_repo(repo_name)}"
            m.branch = "master"
          end
    G
  }

  describe "#run" do

    context "definition has moogs and is valid" do
      it "should invoke definition method on Mooger with args true" do
        create_git_repo(repo_name)
        do_in_repo(repo_name) do
          create_moogerfile
          allow(Mooger).to receive(:definition)
          expect(Mooger).to receive(:definition).with(true)
          Mooger::CLI::Install.new.run
        end
      end

      it "should invoke reset method on Mooger" do
        create_git_repo(repo_name)
        do_in_repo(repo_name) do
          create_moogerfile  
          build_moogs_dir
          allow(Mooger).to receive(:reset)
          expect(Mooger).to receive(:reset).once
          Mooger::CLI::Install.new.run
        end
      end
    end

    context "definition has no moogs" do
      let(:create_moogerfile) { build_moogerfile }

      it "should invoke reset method on Mooger" do
        create_git_repo(repo_name)
        do_in_repo(repo_name) do
          create_moogerfile  
          Mooger.reset
          allow(Mooger).to receive(:reset)
          expect(Mooger).to receive(:reset).twice
          Mooger::CLI::Install.new.run
        end
      end
    end

    context "git repo has changes" do
      it "should invoke reset method on Mooger" do
        create_git_repo(repo_name)
        do_in_repo(repo_name) do
          create_moogerfile  
          create_file
          git("add .")
          allow(Mooger).to receive(:reset)
          expect(Mooger).to receive(:reset).twice
          Mooger::CLI::Install.new.run
        end
      end
    end

    context "remote already exists" do
      let(:create_moogerfile) { 
        build_moogerfile <<-G
          moog 'awesome_moog' do |m|
            m.repo = "git@github.com:brunomorgado/awesome_moog.git"
            m.branch = "master"
          end
        G
      }

      it "should invoke reset method on Mooger" do
        create_git_repo(repo_name)
        do_in_repo(repo_name) do
          create_moogerfile  
          build_moogs_dir
          Dir.mkdir(File.join(Mooger::SharedHelpers.moogs_dir, "awesome_moog"))
          allow(Mooger).to receive(:reset)
          expect(Mooger).to receive(:reset).twice
          Mooger::CLI::Install.new.run
        end
      end
    end

    context "invalid repo url" do
      let(:create_moogerfile) { 
        build_moogerfile <<-G
          moog 'awesome_moog' do |m|
            m.repo = "http://invalid.url.git"
            m.branch = "master"
          end
        G
      }

      it "should invoke reset method on Mooger" do
        create_git_repo(repo_name)
        do_in_repo(repo_name) do
          create_moogerfile  
          allow(Mooger).to receive(:reset)
          expect(Mooger).to receive(:reset).twice
          Mooger::CLI::Install.new.run
        end
      end
    end
  end
end


