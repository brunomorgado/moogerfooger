require "spec_helper"
require_relative "../lib/moogerfooger/errors"
require_relative "../lib/moogerfooger/dsl"

RSpec.describe Mooger::Dsl do

  describe "#evaluate" do

    context "Moogerfile not present" do

      it "should raise MoogerfileNotFound error" do
        FakeFS.with_fresh do
          expect {Mooger::Dsl.evaluate(Mooger::SharedHelpers.moogerfile)}.to raise_error(Mooger::MoogerfileNotFound)
        end
      end
    end

    context "Moogerfile is present" do

      context "and is valid" do

        let(:create_moogerfile_1) { 
          build_moogerfile <<-G
          moog "awesome_moog_1" do |m|
            m.repo = "http://awesome_moog_1.git"
            m.branch = "master"
          end

          moog "awesome_moog_2" do |m|
            m.repo = "http://awesome_moog_2.git"
            m.tag = "v1.2.3"
          end
          G
        }

        it "should generate the definition with the correct specs" do
          FakeFS.with_fresh do
            create_moogerfile_1
            definition = Mooger::Dsl.evaluate(Mooger::SharedHelpers.moogerfile).to_definition
            expect(definition.moogs.count).to be 2
            expect(definition.moogs[0].name).to eq("awesome_moog_1")
            expect(definition.moogs[0].repo).to eq("http://awesome_moog_1.git")
            expect(definition.moogs[0].branch).to eq("master")
            expect(definition.moogs[0].tag).to be nil
            expect(definition.moogs[1].name).to eq("awesome_moog_2")
            expect(definition.moogs[1].repo).to eq("http://awesome_moog_2.git")
            expect(definition.moogs[1].tag).to eq("v1.2.3")
            expect(definition.moogs[1].branch).to be nil
          end
        end
      end

      context "with syntax errors" do

        let(:create_moogerfile) { 
          build_moogerfile <<-G
          fooger 'awesome_moog'
          G
        }

        it "should raise DSLError if using wrong key" do
          FakeFS.with_fresh do
            create_moogerfile
            expect {Mooger::Dsl.evaluate(Mooger::SharedHelpers.moogerfile)}.to raise_error(Mooger::Dsl::DSLError)
          end
        end
      end

      context "with validation errors" do

        let(:create_moogerfile_1) { 
          build_moogerfile <<-G
          moog 'awesome_moog_1'
          G
        }

        let(:create_moogerfile_2) { 
          build_moogerfile <<-G
          moog :awesome_moog_2 do |m|
            m.repo = "http://awesome_moog_2.git"
            m.branch = "master"
          end
          G
        }

        let(:create_moogerfile_3) { 
          build_moogerfile <<-G
          moog "awesome moog 3" do |m|
            m.repo = "http://awesome_moog_3.git"
            m.branch = "master"
          end
          G
        }

        let(:create_moogerfile_4) { 
          build_moogerfile <<-G
          moog "" do |m|
            m.repo = "http://awesome_moog_4.git"
            m.branch = "master"
          end
          G
        }

        let(:create_moogerfile_5) { 
          build_moogerfile <<-G
          moog "moog1" do |m|
            m.repo = "http://awesome_moog_5.git"
            m.branch = "master"
          end

          moog "moog1" do |m|
            m.repo = "http://awesome_moog_6.git"
            m.branch = "master"
          end
          G
        }

        let(:create_moogerfile_6) { 
          build_moogerfile <<-G
          moog "moog6" do |m|
            m.branch = "master"
          end
          G
        }

        let(:create_moogerfile_7) { 
          build_moogerfile <<-G
          moog "moog7" do |m|
            m.repo = "http://awesome_moog_4.git"
            m.branch = "master"
            m.tag = "v1.2.3"
          end
          G
        }

        let(:create_moogerfile_8) { 
          build_moogerfile <<-G
          moog "moog8" do |m|
            m.repo = "http://awesome_moog_4.git"
          end
          G
        }

        it "should require moogs definition to have a block" do
          FakeFS.with_fresh do
            create_moogerfile_1
            expect {Mooger::Dsl.evaluate(Mooger::SharedHelpers.moogerfile)}.to raise_error(Mooger::MoogerfileError)
            expect {Mooger::Dsl.evaluate(Mooger::SharedHelpers.moogerfile)}.to raise_error(/You need to pass a config block to #moog./)
          end
        end

        it "should require moog name to be a string" do
          FakeFS.with_fresh do
            create_moogerfile_2
            expect {Mooger::Dsl.evaluate(Mooger::SharedHelpers.moogerfile)}.to raise_error(Mooger::MoogerfileError)
            expect {Mooger::Dsl.evaluate(Mooger::SharedHelpers.moogerfile)}.to raise_error(/You need to specify moog names as Strings. Use 'moog/)
          end
        end

        it "should require moog name to be a string" do
          FakeFS.with_fresh do
            create_moogerfile_3
            expect {Mooger::Dsl.evaluate(Mooger::SharedHelpers.moogerfile)}.to raise_error(Mooger::MoogerfileError)
            expect {Mooger::Dsl.evaluate(Mooger::SharedHelpers.moogerfile)}.to raise_error(/is not a valid moog name because it contains whitespace/)
          end
        end

        it "should require moog name to not be empty" do
          FakeFS.with_fresh do
            create_moogerfile_4
            expect {Mooger::Dsl.evaluate(Mooger::SharedHelpers.moogerfile)}.to raise_error(Mooger::MoogerfileError)
            expect {Mooger::Dsl.evaluate(Mooger::SharedHelpers.moogerfile)}.to raise_error(/an empty moog name is not valid/)
          end
        end

        it "should require moog names to be unique" do
          FakeFS.with_fresh do
            create_moogerfile_5
            expect {Mooger::Dsl.evaluate(Mooger::SharedHelpers.moogerfile)}.to raise_error(Mooger::MoogerfileError)
            expect {Mooger::Dsl.evaluate(Mooger::SharedHelpers.moogerfile)}.to raise_error(/multiple times/)
          end
        end

        it "should require the repo to be specified" do
          FakeFS.with_fresh do
            create_moogerfile_6
            expect {Mooger::Dsl.evaluate(Mooger::SharedHelpers.moogerfile)}.to raise_error(Mooger::MoogerfileError)
            expect {Mooger::Dsl.evaluate(Mooger::SharedHelpers.moogerfile)}.to raise_error(/You must specify a valid git repo/)
          end
        end

        it "should fail if both branch and tag are specified" do
          FakeFS.with_fresh do
            create_moogerfile_7
            expect {Mooger::Dsl.evaluate(Mooger::SharedHelpers.moogerfile)}.to raise_error(Mooger::MoogerfileError)
            expect {Mooger::Dsl.evaluate(Mooger::SharedHelpers.moogerfile)}.to raise_error(/You can't specify both the branch and the tag/)
          end
        end

        it "should fail if neither the branch or the tag are specified" do
          FakeFS.with_fresh do
            create_moogerfile_8
            expect {Mooger::Dsl.evaluate(Mooger::SharedHelpers.moogerfile)}.to raise_error(Mooger::MoogerfileError)
            expect {Mooger::Dsl.evaluate(Mooger::SharedHelpers.moogerfile)}.to raise_error(/You must specify either a branch or a tag/)
          end
        end
      end
    end
  end
end
