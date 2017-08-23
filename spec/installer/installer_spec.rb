require "spec_helper"
require 'fakefs/safe'
require_relative "../../lib/moogerfooger/installer/installer"
require "pry"

RSpec.describe Mooger::Installer do

  let(:moogs) {[]}
  let(:definition) {build_definition(moogs)}
  let(:moogs_dir) {Mooger::SharedHelpers.moogs_dir}
  let(:do_run) {Mooger::Installer.install(definition, moogs_dir).run}
  let(:subtree_installer) {build_subtree_installer(definition, moogs_dir)}

  describe "#run" do

    it "should create the moogs_dir if not present" do
      FakeFS.with_fresh do
        build_moogerfile
        expect(Dir.exists?(Mooger::SharedHelpers.moogs_dir_path)).to be false
        do_run
        expect(Dir.exists?(Mooger::SharedHelpers.moogs_dir_path)).to be true

      end
    end

    it "should not fail if moogs_dir is already present" do
      FakeFS.with_fresh do
        build_moogerfile
        build_moogs_dir
        expect(Dir.exists?(Mooger::SharedHelpers.moogs_dir_path)).to be true
        do_run
        expect(Dir.exists?(Mooger::SharedHelpers.moogs_dir_path)).to be true
      end
    end

    context "definition has no moogs"do

      it "should not invoke new on GitSubtree installer" do
        FakeFS.with_fresh do
          build_moogerfile
          stb = subtree_installer
          stb.stub(:new)
          expect(stb).to_not receive(:new)
          do_run
        end
      end

      it "should not invoke generate on GitSubtree installer" do
        FakeFS.with_fresh do
          build_moogerfile
          stb = subtree_installer
          stb.stub(:generate)
          expect(stb).to_not receive(:generate)
          do_run
        end
      end
    end

    context "definition has moogs"do

      let(:moogs) {[build_moog("moog1", "path_to_repo")]}

      it "should invoke new on GitSubtree installer" do
        FakeFS.with_fresh do
          build_moogerfile
          stb = subtree_installer
          allow(stb).to receive(:new)
          expect(stb).to receive(:new)
          do_run
        end
      end

      it "should not invoke generate on GitSubtree installer" do
        FakeFS.with_fresh do
          build_moogerfile
          stb = subtree_installer
          stb.stub(:generate)
          expect(stb).to receive(:generate)
          do_run
        end
      end
    end
  end
end


