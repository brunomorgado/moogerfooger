require "spec_helper"
require "moogerfooger"

RSpec.describe Moogerfooger do
  it "has a version number" do
    expect(Moogerfooger::VERSION).not_to be nil
  end

  it "does something useful" do
    expect(false).to eq(true)
  end
end
