require 'moogerfooger'

module Mooger
  class Moog

   attr_accessor(
     :name,
     :repo,
     :branch,
     :tag
   ) 

    def initialize(name)
      @name = name
      @repo = nil
      @branch = nil
      @tag = nil
    end

    def self.find(moog_name)
      definition = Mooger.definition
      definition.moogs.select { |moog| moog.name == moog_name }.first
    end
  end
end
