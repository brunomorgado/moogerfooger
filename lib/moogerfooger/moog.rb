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

   def self.from_hash hash
     moog = new(hash[:name])
     moog.repo = hash[:repo]
     moog.branch = hash[:branch]
     moog.tag = hash[:tag]
   end

   def to_hash
     hash = Hash.new
     hash["name"] = @name
     hash["repo"] = @repo
     hash["branch"] = @branch
     hash["tag"] = @tag
     hash
   end

   def self.find(moog_name)
     definition = Mooger.definition
     definition.moogs.select { |moog| moog.name == moog_name }.first
   end

  end
end
