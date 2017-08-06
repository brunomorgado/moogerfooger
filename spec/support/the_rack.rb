require "support/helpers"
require "support/path"

module Spec
  class TheRack
    include Spec::Helpers
    include Spec::Path

    attr_accessor :rack_dir

    def initialize(opts = {})
      opts = opts.dup
      @rack_dir = Pathname.new(opts.delete(:rack_dir) { bundled_app })
      raise "Too many options! #{opts}" unless opts.empty?
    end

    def to_s
      "the rack"
    end
    alias_method :inspect, :to_s
  end
end
