require 'yaml'
require 'moogerfooger/shared_herlpers'

module Mooger
  class Parser
    class LockfileParser

      def initialize(lockfile)
        @lockfile = lockfile
      end

      def self.parse(lockfile)
        new(lockfile).parse!
      end

      def to_definition
      end

      private 

      def parse!
      end

    end
  end
end
