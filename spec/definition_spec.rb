require "spec_helper"
require_relative "../lib/moogerfooger/errors"
require_relative "../lib/moogerfooger/dsl"
require_relative "../lib/moogerfooger/definition"
require_relative "../lib/moogerfooger/parser/lockfile_parser"

RSpec.describe Mooger::Definition do

  describe "#build?" do

    let(:definition) {Mooger::Definition.build}

    context "when Mooger is unlocked" do

      let(:create_moogerfile) { 
        build_moogerfile <<-G
          moog 'awesome_moog_from_moogerfile_1' do |m|
            m.repo = "http://awesome_moog.git"
            m.branch = "master"
          end
          moog 'awesome_moog_from_moogerfile_2' do |m|
            m.repo = "http://awesome_moog.git"
            m.branch = "master"
          end
        G
      }

      it "should build definition from parsing Moogefile" do
        FakeFS.with_fresh do
          create_moogerfile 
          expect(definition.moogs.first.name).to eq("awesome_moog_from_moogerfile_1")
          expect(definition.moogs[1].name).to eq("awesome_moog_from_moogerfile_2")
          expect(definition.moogs.count).to eq(2)
        end
      end

      it "should generate Lockfile" do
        FakeFS.with_fresh do
          create_moogerfile 
          expect(Mooger::SharedHelpers.lockfile).to be nil
          definition
          expect(Mooger::SharedHelpers.lockfile).to_not be nil
          expect(File.exists?(Mooger::SharedHelpers.lockfile)).to be true
        end
      end

      it "generated Lockfile should have the correct definition" do
        FakeFS.with_fresh do
          create_moogerfile 
          expect(Mooger::SharedHelpers.lockfile).to be nil
          moogerfile_def = definition
          expect(Mooger::SharedHelpers.lockfile).to_not be nil
          lockfile_def = definition
          expect(lockfile_def.moogs.count).to eq(moogerfile_def.moogs.count)
          expect(lockfile_def.moogs.first.name).to eq(moogerfile_def.moogs.first.name)
          expect(lockfile_def.moogs[1].name).to eq(moogerfile_def.moogs[1].name)
        end
      end
    end

    context "when Mooger is locked" do

      let(:create_lockfile) { 
        build_lockfile <<-G
        ---
        awesome_moog_from_lockfile:
          name: awesome_moog_from_lockfile
          repo: git@github.com:brunomorgado/RxErrorTracker.git
          branch: master
          tag: 
        G
      }

      it "should build definition from parsing Lockfile" do
        FakeFS.with_fresh do
          create_lockfile 
          expect(definition.moogs.first.name).to eq("awesome_moog_from_lockfile")
          expect(definition.moogs.count).to eq(1)
        end
      end

    end
  end
end
