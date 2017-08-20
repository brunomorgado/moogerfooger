require "spec_helper"
require_relative "../lib/moogerfooger/errors"
require_relative '../lib/moogerfooger/shared_herlpers'
require 'fakefs/safe'
require 'byebug'

RSpec.describe Mooger::SharedHelpers do

  describe "file system manipulation" do

    let(:create_moogerfile) { 
      File.open("Moogerfile", "w") do |f|
        f.puts("FAKE MOOGERFILE")
      end
    }

    let(:create_lockfile) { 
      File.open("Moogerfile.lock", "w") do |f|
        f.puts("FAKE LOCKFILE")
      end
    }

    describe "#root" do

      it "should not be nil if Moogerfile exists" do
        FakeFS.with_fresh do
          create_moogerfile
          expect(Mooger::SharedHelpers.root).not_to be nil
        end
      end

      it "Moogerfile should be a directory" do
        FakeFS.with_fresh do
          create_moogerfile
          expect(Mooger::SharedHelpers.root.directory?).to be true
        end
      end

      it "should raise MoogerfileNotFound if Moogerfile is not present" do
        FakeFS.with_fresh do
          expect { Mooger::SharedHelpers.root }.to raise_error(Mooger::MoogerfileNotFound)
        end
      end

      it "should be a Pathname" do
        FakeFS.with_fresh do
          create_moogerfile
          expect(Mooger::SharedHelpers.root).to be_a Pathname
        end
      end
    end

    describe "#moogs_dir" do

      it "should not be nil if moogs_dir exists" do
        FakeFS.with_fresh do
          Dir.mkdir("Moogs")
          expect(Mooger::SharedHelpers.moogs_dir).not_to be nil
        end
      end

      it "should create Moogs dir if not present" do
        FakeFS.with_fresh do
          create_moogerfile
          Dir.mkdir("vendr")
          expect(Mooger::SharedHelpers.moogs_dir).not_to be nil
        end
      end

      it "moogs_dir should be a directory" do
        FakeFS.with_fresh do
          Dir.mkdir("Moogs")
          expect(Mooger::SharedHelpers.moogs_dir.directory?).to be true
        end
      end

      it "should be a Pathname" do
        FakeFS.with_fresh do
          Dir.mkdir("Moogs")
          expect(Mooger::SharedHelpers.moogs_dir).to be_a Pathname
        end
      end
    end

    describe "#moogerfile" do

      it "should not be nil if moogfile exists" do
        FakeFS.with_fresh do
          create_moogerfile
          expect(Mooger::SharedHelpers.moogerfile).not_to be nil
        end
      end

      it "default_moogfile should be a file" do
        FakeFS.with_fresh do
          create_moogerfile
          expect(Mooger::SharedHelpers.moogerfile.file?).to be true
        end
      end

      it "should raise MoogerfileNotFound if Moogerfile is not present" do
        FakeFS.with_fresh do
          expect { Mooger::SharedHelpers.moogerfile }.to raise_error(Mooger::MoogerfileNotFound)
        end
      end

      it "should be a Pathname" do
        FakeFS.with_fresh do
          create_moogerfile
          expect(Mooger::SharedHelpers.moogerfile).to be_a Pathname
        end
      end
    end

    describe "#lockfile" do

      it "can be nil" do
        expect(Mooger::SharedHelpers.lockfile).to be nil
      end

      it "lockfile should be a file" do
        FakeFS.with_fresh do
          create_lockfile
          expect(Mooger::SharedHelpers.lockfile.file?).to be true
        end
      end

      it "should be a Pathname" do
        FakeFS.with_fresh do
          create_lockfile
          expect(Mooger::SharedHelpers.lockfile).to be_a Pathname
        end
      end
    end
  end
end
