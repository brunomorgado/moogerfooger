require "spec_helper"
require "moogerfooger"
require 'fakefs/spec_helpers'

RSpec.describe Moogerfooger do
  it "has a version number" do
    expect(Moogerfooger::VERSION).not_to be nil
  end

  describe "#reset" do

    it "should reset definition" do
        FakeFS.with_fresh do
          build_moogerfile
          definition = Mooger.definition(true)
          expect(definition).to_not be nil
          expect(Mooger.definition).to be definition
          Mooger.reset
          expect(Mooger.definition).to_not be definition
        end
    end

    it "should delete the lockfile" do
        FakeFS.with_fresh do
          build_moogerfile
          build_lockfile
          expect(Mooger::SharedHelpers.lockfile).to_not be nil
          Mooger.reset
          expect(Mooger::SharedHelpers.lockfile).to be nil
        end
    end

    it "should delete the moogs dir recursively" do
      FakeFS.with_fresh do
        build_moogerfile
        build_moogs_dir
        Dir.chdir(Mooger::SharedHelpers.moogs_dir_path) do
          Dir.mkdir("Moog1")
          Dir.mkdir("Moog2")
          Dir.mkdir("Moog3")
        end
        expect(Mooger::SharedHelpers.installed_moogs).to eq(["Moog1", "Moog2", "Moog3"])
        Mooger.reset
        expect(Mooger::SharedHelpers.installed_moogs).to eq([])
      end
    end
  end
end
