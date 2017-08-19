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

    describe "#default_moogs_dir" do

      it "should not be nil if default_moogs_dir exists" do
        FakeFS.with_fresh do
          Dir.mkdir("vendor")
          expect(Mooger::SharedHelpers.default_moogs_dir).not_to be nil
        end
      end

      it "should create vendor dir if not present" do
        FakeFS.with_fresh do
          create_moogerfile
          Dir.mkdir("vendr")
          expect(Mooger::SharedHelpers.default_moogs_dir).not_to be nil
        end
      end

      it "default_moogs_dir should be a directory" do
        FakeFS.with_fresh do
          Dir.mkdir("vendor")
          expect(Mooger::SharedHelpers.default_moogs_dir.directory?).to be true
        end
      end

      it "should be a Pathname" do
        FakeFS.with_fresh do
          Dir.mkdir("vendor")
          expect(Mooger::SharedHelpers.default_moogs_dir).to be_a Pathname
        end
      end
    end

    describe "#default_moogerfile" do

      it "should not be nil if moogfile exists" do
        FakeFS.with_fresh do
          create_moogerfile
          expect(Mooger::SharedHelpers.default_moogerfile).not_to be nil
        end
      end

      it "default_moogfile should be a file" do
        FakeFS.with_fresh do
          create_moogerfile
          expect(Mooger::SharedHelpers.default_moogerfile.file?).to be true
        end
      end

      it "should raise MoogerfileNotFound if Moogerfile is not present" do
        FakeFS.with_fresh do
          expect { Mooger::SharedHelpers.default_moogerfile }.to raise_error(Mooger::MoogerfileNotFound)
        end
      end

      it "should be a Pathname" do
        FakeFS.with_fresh do
          create_moogerfile
          expect(Mooger::SharedHelpers.default_moogerfile).to be_a Pathname
        end
      end
    end

    describe "#default_lockfile" do

      it "should create a lockfile if it does not exist" do
        FakeFS.with_fresh do
          create_moogerfile
          expect(Mooger::SharedHelpers.default_lockfile).not_to be nil
        end
      end


      it "should raise MoogerfileNotFound if Moogerfile is not present" do
        FakeFS.with_fresh do
          expect { Mooger::SharedHelpers.default_lockfile }.to raise_error(Mooger::MoogerfileNotFound)
        end
      end

      it "default_lockfile should be a file" do
        FakeFS.with_fresh do
          create_lockfile
          expect(Mooger::SharedHelpers.default_lockfile.file?).to be true
        end
      end

      it "should be a Pathname" do
        FakeFS.with_fresh do
          create_lockfile
          expect(Mooger::SharedHelpers.default_lockfile).to be_a Pathname
        end
      end
    end
  end
end
