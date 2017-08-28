require "spec_helper"
require_relative "../lib/moogerfooger/errors"
require_relative '../lib/moogerfooger/shared_herlpers'
require 'fakefs/safe'

RSpec.describe Mooger::SharedHelpers do

  describe "file system manipulation" do
    
    let(:create_moogerfile) { 
      build_moogerfile <<-G
          moog 'awesome_moog' do |m|
            m.repo = "http://awesome_moog.git"
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
      tag: 
      G
    }

    let(:create_moogs_dir) {
      Dir.mkdir(Mooger::SharedHelpers.moogs_dir_path.to_s)
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
          create_moogerfile
          create_moogs_dir
          expect(Mooger::SharedHelpers.moogs_dir).not_to be nil
        end
      end

      it "should create Moogs dir if not present" do
        FakeFS.with_fresh do
          create_moogerfile
          create_moogs_dir
          expect(Mooger::SharedHelpers.moogs_dir).not_to be nil
        end
      end

      it "moogs_dir should be a directory" do
        FakeFS.with_fresh do
          create_moogerfile
          create_moogs_dir
          expect(Mooger::SharedHelpers.moogs_dir.directory?).to be true
        end
      end

      it "should be a Pathname" do
        FakeFS.with_fresh do
          create_moogerfile
          create_moogs_dir
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
        FakeFS.with_fresh do
          expect(Mooger::SharedHelpers.lockfile).to be nil
        end
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

    describe "#file_exists" do

      it "should return true if file exists and it is a File" do
        FakeFS.with_fresh do
          create_moogerfile
          create_lockfile
          expect(Mooger::SharedHelpers.file_exists?(Mooger::SharedHelpers.lockfile_path)).to be true
        end
      end

      it "should return false if file exists but it is not a File" do
        FakeFS.with_fresh do
          create_moogerfile
          create_moogs_dir
          expect(File.exists?(Mooger::SharedHelpers.moogs_dir_path)).to be true
          expect(Mooger::SharedHelpers.file_exists?(Mooger::SharedHelpers.moogs_dir_path)).to be false
        end
      end

      it "should return false if file does not exist" do
        FakeFS.with_fresh do
          expect(Mooger::SharedHelpers.file_exists?("some-random-file.txt")).to be false
        end
      end
    end

    describe "#moogs_dir_path" do

      it "should be equal to the root path + /Moogs" do
        FakeFS.with_fresh do
          create_moogerfile
          moogs_dir_path = Mooger::SharedHelpers.root + "Moogs"
          expect(Mooger::SharedHelpers.moogs_dir_path.to_s).to eq(Pathname.new(moogs_dir_path).untaint.expand_path.to_s)
        end
      end
    end

    describe "#lockfile_path" do

      it "should be in the root with the name: Moogerfile.lock" do
        FakeFS.with_fresh do
          create_moogerfile
          lockfile_path = Mooger::SharedHelpers.root + "Moogerfile.lock"
          expect(Mooger::SharedHelpers.lockfile_path.to_s).to eq(Pathname.new(lockfile_path).untaint.expand_path.to_s)
        end
      end
    end

    describe "#installed_moogs" do

      it "should return an array with the names of the installed moogs" do
        FakeFS.with_fresh do
          create_lockfile
          expect(Mooger::SharedHelpers.installed_moogs.map{ |moog| moog.name }).to eq(["awesome_moog"])
        end
      end

      it "should return an empty array if lockfile does not exist" do
        FakeFS.with_fresh do
          expect(Mooger::SharedHelpers.installed_moogs).to eq([])
        end
      end

      #context "no moogs installed" do

      #let(:create_lockfile) { 
      #build_lockfile <<-G
      #---
      #G
      #}

      #it "should return an empty array if there are no installed moogs" do
      #FakeFS.with_fresh do
      #create_lockfile
      #expect(Mooger::SharedHelpers.installed_moogs).to eq([])
      #end
      #end
      #end

    end
  end
end
