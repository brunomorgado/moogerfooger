require "spec_helper"
require 'fakefs/spec_helpers'
require "moogerfooger"

RSpec.describe Mooger::Moog do

  describe "#find" do

    let(:lockfile) { 
      build_lockfile <<-G
        ---
        awesome_moog1:
          name: awesome_moog1
          repo: git@github.com:brunomorgado/RxErrorTracker.git
          branch: master
        awesome_moog2:
          name: awesome_moog2
          repo: git@github.com:brunomorgado/RxErrorTracker.git
          branch: master
      G
    }

    it "should find the moogs present in the lockfile" do
      FakeFS.with_fresh do
        system "cat Moogerfile.lock"
        expect(Mooger::Moog.find("awesome_moog1").name).to eq("awesome_moog1")
        expect(Mooger::Moog.find("awesome_moog2").name).to eq("awesome_moog2")
        expect(Mooger::Moog.find("awesome_moog3")).to be nil 
      end
    end
  end

  context "using branch" do
    let(:moog) {build_moog("awesome_moog", "http://awesome_moog.git", "master", nil)}
    let(:moog_hash) {{"name"=>"awesome_moog", "repo"=>"http://awesome_moog.git", "branch"=>"master"}}

    describe "#to_hash" do
      it "should create a hash with the correct specs" do
        sut = moog.to_hash
        expect(sut.size).to eq(moog_hash.size)
        moog_hash.each do |key, value|
          expect(value).to eq(sut[key])
        end
      end
    end

    describe "#from_hash" do
      it "should create a hash with the correct specs" do
        sut = Mooger::Moog.from_hash(moog_hash)
        expect(sut.name).to eq(moog.name)
        expect(sut.repo).to eq(moog.repo)
        expect(sut.branch).to eq(moog.branch)
        expect(sut.tag).to eq(moog.tag)
      end
    end
  end

  context "using tag" do
    let(:moog) {build_moog("awesome_moog", "http://awesome_moog.git", nil, "v1.2.3")}
    let(:moog_hash) {{"name"=>"awesome_moog", "repo"=>"http://awesome_moog.git", "tag"=>"v1.2.3"}}

    describe "#to_hash" do
      it "should create a hash with the correct specs" do
        sut = moog.to_hash
        expect(sut.size).to eq(moog_hash.size)
        moog_hash.each do |key, value|
          expect(value).to eq(sut[key])
        end
      end
    end

    describe "#from_hash" do
      it "should create a hash with the correct specs" do
        sut = Mooger::Moog.from_hash(moog_hash)
        expect(sut.name).to eq(moog.name)
        expect(sut.repo).to eq(moog.repo)
        expect(sut.branch).to eq(moog.branch)
        expect(sut.tag).to eq(moog.tag)
      end
    end
  end
end
