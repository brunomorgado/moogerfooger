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

      it "should not raise any error" do
        create_git_repo(repo_name)
        do_in_repo(repo_name) do
          create_moogerfile  
          expect {Mooger::CLI::Install.new.run}.not_to raise_error
        end
      end

      it "should install the moogs specified on the Moogerfile" do
        create_git_repo(repo_name)
        do_in_repo(repo_name) do
          create_moogerfile
          Mooger::CLI::Install.new.run
          expect(Mooger.definition.moogs.count).to be 1
          expect(Mooger.definition.moogs[0].name).to eq("awesome_moog") 
        end
      end

      it "should finish at the original branch" do
        create_git_repo(repo_name)
        do_in_repo(repo_name) do
          create_moogerfile  
          original_branch = Mooger::GitHelpers.current_branch
          expect(original_branch).to eq("master")
          Mooger::CLI::Install.new.run
          expect(Mooger::GitHelpers.current_branch).to eq(original_branch)
        end
      end

      it "should cleanup temp branches" do
        create_git_repo(repo_name)
        do_in_repo(repo_name) do
          create_moogerfile  
          branch_count = git("branch | wc -l").strip.to_i
          expect(branch_count).to eq(1)
          Mooger::CLI::Install.new.run
          updated_branch_count = git("branch | wc -l").strip.to_i
          expect(branch_count).to eq(updated_branch_count)
        end
      end

      it "should end up with clean working tree" do
        create_git_repo(repo_name)
        do_in_repo(repo_name) do
          create_moogerfile  
          Mooger::CLI::Install.new.run
          expect(Mooger::GitHelpers.repo_has_changes?).to be false
        end
      end

      it "should change git history" do
        create_git_repo(repo_name)
        do_in_repo(repo_name) do
          create_moogerfile  
          original_rev = git("rev-parse HEAD")
          Mooger::CLI::Install.new.run
          final_rev = git("rev-parse HEAD")
          expect(original_rev).to_not eq(final_rev)
        end
      end

      context "First install" do
        it "should create the moogs_dir" do
          create_git_repo(repo_name)
          do_in_repo(repo_name) do
            create_moogerfile
            expect(Dir.exists?(Mooger::SharedHelpers.moogs_dir_path)).to be false
            Mooger::CLI::Install.new.run
            expect(Dir.exists?(Mooger::SharedHelpers.moogs_dir_path)).to be true
          end
        end

        it "should create the lockfile" do
          create_git_repo(repo_name)
          do_in_repo(repo_name) do
            create_moogerfile
            expect(File.exist?(Mooger::SharedHelpers.lockfile_path)).to be false
            Mooger::CLI::Install.new.run
            expect(File.exist?(Mooger::SharedHelpers.lockfile_path)).to be true
          end
        end
      end

      context "Subsquent install" do

        it "should not fail if moogs_dir is already present" do
          create_git_repo(repo_name)
          do_in_repo(repo_name) do
            create_moogerfile
            build_moogs_dir
            expect(Dir.exists?(Mooger::SharedHelpers.moogs_dir_path)).to be true
            Mooger::CLI::Install.new.run
            expect(Dir.exists?(Mooger::SharedHelpers.moogs_dir_path)).to be true
          end
        end

        it "should not raise any error" do
          create_git_repo(repo_name)
          do_in_repo(repo_name) do
            create_moogerfile  
            Mooger::CLI::Install.new.run
            expect {Mooger::CLI::Install.new.run}.not_to raise_error
          end
        end
      end
    end

    context "definition has no moogs" do
      let(:create_moogerfile) { build_moogerfile }

      it "should not raise any error" do
        create_git_repo(repo_name)
        do_in_repo(repo_name) do
          create_moogerfile  
          expect {Mooger::CLI::Install.new.run}.not_to raise_error
        end
      end

      it "should uninstall all the moogs" do
        create_git_repo(repo_name)
        do_in_repo(repo_name) do
          create_moogerfile
          Mooger::CLI::Install.new.run
          expect(Mooger.definition.moogs.count).to be 0
        end
      end

      it "should finish at the original branch" do
        create_git_repo(repo_name)
        do_in_repo(repo_name) do
          create_moogerfile  
          original_branch = Mooger::GitHelpers.current_branch
          expect(original_branch).to eq("master")
          Mooger::CLI::Install.new.run
          expect(Mooger::GitHelpers.current_branch).to eq(original_branch)
        end
      end
    end

    context "git repo has changes" do

      it "should finish at the original branch" do
        create_git_repo(repo_name)
        do_in_repo(repo_name) do
          create_file
          git("add .")
          original_branch = Mooger::GitHelpers.current_branch
          expect(original_branch).to eq("master")
          Mooger::CLI::Install.new.run
          expect(Mooger::GitHelpers.current_branch).to eq(original_branch)
        end
      end

      it "should cleanup temp branches" do
        create_git_repo(repo_name)
        do_in_repo(repo_name) do
          create_file
          git("add .")
          branch_count = git("branch | wc -l").strip.to_i
          expect(branch_count).to eq(1)
          Mooger::CLI::Install.new.run
          updated_branch_count = git("branch | wc -l").strip.to_i
          expect(branch_count).to eq(updated_branch_count)
        end
      end

      it "should produce no changes" do
        create_git_repo(repo_name)
        do_in_repo(repo_name) do
          create_file
          git("add .")
          original_rev = git("rev-parse HEAD")
          Mooger::CLI::Install.new.run
          final_rev = git("rev-parse HEAD")
          expect(original_rev).to eq(final_rev)
          expect(Mooger::GitHelpers.repo_has_changes?).to be true
        end
      end
    end

    context "remote already exists" do

      it "should finish at the original branch" do
        create_git_repo(repo_name)
        do_in_repo(repo_name) do
          git("remote add awesome_moog #{path_for_git_repo(repo_name)}")
          create_moogerfile  
          original_branch = Mooger::GitHelpers.current_branch
          expect(original_branch).to eq("master")
          Mooger::CLI::Install.new.run
          expect(Mooger::GitHelpers.current_branch).to eq(original_branch)
        end
      end

      it "should cleanup temp branches" do
        create_git_repo(repo_name)
        do_in_repo(repo_name) do
          git("remote add awesome_moog #{path_for_git_repo(repo_name)}")
          create_moogerfile  
          branch_count = git("branch | wc -l").strip.to_i
          expect(branch_count).to eq(1)
          Mooger::CLI::Install.new.run
          updated_branch_count = git("branch | wc -l").strip.to_i
          expect(branch_count).to eq(updated_branch_count)
        end
      end

      it "should produce no changes" do
        create_git_repo(repo_name)
        do_in_repo(repo_name) do
          git("remote add awesome_moog #{path_for_git_repo(repo_name)}")
          create_moogerfile  
          original_rev = git("rev-parse HEAD")
          Mooger::CLI::Install.new.run
          final_rev = git("rev-parse HEAD")
          expect(original_rev).to eq(final_rev)
          expect(Mooger::GitHelpers.repo_has_changes?).to be false
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

      it "should finish at the original branch" do
        create_git_repo(repo_name)
        do_in_repo(repo_name) do
          create_moogerfile  
          original_branch = Mooger::GitHelpers.current_branch
          expect(original_branch).to eq("master")
          Mooger::CLI::Install.new.run
          expect(Mooger::GitHelpers.current_branch).to eq(original_branch)
        end
      end

      it "should cleanup temp branches" do
        create_git_repo(repo_name)
        do_in_repo(repo_name) do
          create_moogerfile  
          branch_count = git("branch | wc -l").strip.to_i
          expect(branch_count).to eq(1)
          Mooger::CLI::Install.new.run
          updated_branch_count = git("branch | wc -l").strip.to_i
          expect(branch_count).to eq(updated_branch_count)
        end
      end

      it "should produce no changes" do
        create_git_repo(repo_name)
        do_in_repo(repo_name) do
          create_moogerfile  
          original_rev = git("rev-parse HEAD")
          Mooger::CLI::Install.new.run
          final_rev = git("rev-parse HEAD")
          expect(original_rev).to eq(final_rev)
          expect(Mooger::GitHelpers.repo_has_changes?).to be false
        end
      end
    end
  end
end


