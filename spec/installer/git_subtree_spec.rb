require "spec_helper"
require 'fakefs/safe'
require_relative "../../lib/moogerfooger/installer/git_subtree"
require_relative "../../lib/moogerfooger/git_helpers"

RSpec.describe Mooger::Installer::GitSubtree do

  let(:repo_name) {"repo_#{SecureRandom.hex(5)}"}
  let(:moogs) {[build_moog("moog1", path_for_git_repo(repo_name)), build_moog("moog2", path_for_git_repo(repo_name))]}
  let(:definition) {build_definition(moogs)}
  let(:moogs_dir) {Mooger::SharedHelpers.moogs_dir}
  let(:subtree_installer) {build_subtree_installer(definition, moogs_dir)}

  describe "#run" do

    context "definition has moogs" do
      it "should create the moogs_dir if not present" do
        FakeFS.with_fresh do
          build_moogerfile
          installer = build_subtree_installer(definition, moogs_dir)
          allow(installer).to receive(:generate)
          expect(Dir.exists?(Mooger::SharedHelpers.moogs_dir_path)).to be false
          installer.run
          expect(Dir.exists?(Mooger::SharedHelpers.moogs_dir_path)).to be true
        end
      end

      it "should not fail if moogs_dir is already present" do
        FakeFS.with_fresh do
          build_moogerfile
          build_moogs_dir
          installer = build_subtree_installer(definition, moogs_dir)
          allow(installer).to receive(:generate)
          expect(Dir.exists?(Mooger::SharedHelpers.moogs_dir_path)).to be true
          installer.run
          expect(Dir.exists?(Mooger::SharedHelpers.moogs_dir_path)).to be true
        end
      end

      it "should invoke generate method" do
        FakeFS.with_fresh do
          build_moogerfile
          build_moogs_dir
          installer = build_subtree_installer(definition, moogs_dir)
          allow(installer).to receive(:generate)
          expect(installer).to receive(:generate)
          installer.run
        end
      end
    end

    context "definition has no moogs" do

      let(:moogs) {[]}

      it "should raise DefinitionHasNoMoogsError error" do
        FakeFS.with_fresh do
          build_moogerfile
          installer = build_subtree_installer(definition, moogs_dir)
          allow(installer).to receive(:generate)
          expect {installer.run}.to raise_error(Mooger::DefinitionHasNoMoogsError)
        end
      end

      it "should not create the moogs_dir" do
        FakeFS.with_fresh do
          build_moogerfile
          installer = build_subtree_installer(definition, moogs_dir)
          allow(installer).to receive(:generate)
          expect(Dir.exists?(Mooger::SharedHelpers.moogs_dir_path)).to be false
          expect {installer.run}.to raise_error(Mooger::DefinitionHasNoMoogsError)
          expect(Dir.exists?(Mooger::SharedHelpers.moogs_dir_path)).to be false
        end
      end

      it "should not invoke generate method" do
        FakeFS.with_fresh do
          build_moogerfile
          installer = build_subtree_installer(definition, moogs_dir)
          allow(installer).to receive(:generate)
          expect(installer).to_not receive(:generate)
          expect {installer.run}.to raise_error(Mooger::DefinitionHasNoMoogsError)
        end
      end
    end
  end

  describe "#generate" do

    it "should raise GitRepoHasChangesError if repo has changes" do
      create_git_repo(repo_name)
      do_in_repo(repo_name) do
        build_moogerfile
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
        build_moogerfile
        build_moogs_dir
        git("add .")
        git("commit -m 'Add moogerfile'")
        subtree_installer.generate
        expect(Mooger::GitHelpers.remote_exists?("moog1")).to be true
        expect(Mooger::GitHelpers.remote_exists?("moog2")).to be true
        expect(Mooger::GitHelpers.remote_exists?("non_existent")).to be false
        # Should generate 2 remotes
        expect(`git remote -v | wc -l`.to_i/2).to eq 2
      end
    end

    it "should add the subtrees to the right path" do
      create_git_repo(repo_name)
      do_in_repo(repo_name) do
        build_moogerfile
        build_moogs_dir
        git("add .")
        git("commit -m 'Add moogerfile'")
        subtree_installer.generate
        expect(Dir.exists?(File.join(moogs_dir, "moog1"))).to be true
        expect(Dir.exists?(File.join(moogs_dir, "moog2"))).to be true
      end
    end

    context "on failure" do

      let(:moogs) {[build_moog("moog1", "wrong_url"), build_moog("moog2", "wrong_url")]}
      let(:definition) {build_definition(moogs)}
      let(:subtree_installer) {build_subtree_installer(definition, moogs_dir)}

      it "should not add any remote" do
        create_git_repo(repo_name)
        do_in_repo(repo_name) do
          build_moogerfile
          build_moogs_dir
          expect {subtree_installer.generate}.to raise_error(Mooger::GitRemoteAddError)
          expect(Mooger::GitHelpers.remote_exists?("moog1")).to be false
          expect(Mooger::GitHelpers.remote_exists?("moog2")).to be false
          # Should generate 0 remotes
          expect(`git remote -v | wc -l`.to_i).to eq 0
        end
      end

      it "should not add any subtree" do
        create_git_repo(repo_name)
        do_in_repo(repo_name) do
          build_moogerfile
          build_moogs_dir
          expect {subtree_installer.generate}.to raise_error(Mooger::GitRemoteAddError)
          expect(Dir.exists?(File.join(moogs_dir, "moog1"))).to be false
          expect(Dir.exists?(File.join(moogs_dir, "moog2"))).to be false
        end
      end
    end
  end
end
