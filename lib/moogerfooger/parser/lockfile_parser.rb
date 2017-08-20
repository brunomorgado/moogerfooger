require 'yaml'
require 'moogerfooger/shared_herlpers'

module Mooger
  class Parser
    class LockfileParser

      def initialize(lockfile)
        @lockfile = lockfile
        @moogs = []
      end

      def self.parse(lockfile)
        new(lockfile).parse!
      end
      
      def parse!
        populate_moogs(YAML.load_file(@lockfile.to_s))
        self
      end

      def to_definition
        definition = Definition.new(@moogs)
      end

      private 

      def populate_moogs moogs_hash
        moogs_hash.each { |name, specs|
          @moogs << Moog.from_hash(specs) 
        }
      end
    end
  end
end
