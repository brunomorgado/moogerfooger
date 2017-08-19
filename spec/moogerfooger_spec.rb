require "spec_helper"
require "moogerfooger"
require 'fakefs/spec_helpers'

RSpec.describe Moogerfooger do
  it "has a version number" do
    expect(Moogerfooger::VERSION).not_to be nil
  end

end
