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
  end
end
