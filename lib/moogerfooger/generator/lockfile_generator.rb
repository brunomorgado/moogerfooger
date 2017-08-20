require 'yaml'
require 'moogerfooger/shared_herlpers'

module Mooger
  class Generator
    class LockfileGenerator

      def initialize(definition)
        @definition = definition
        @moogs_hash = Hash.new
      end

      def self.generate(definition)
        new(definition).generate!
      end

      def generate!
        generate_moogs_hash
        write_file
      end
     
      private 

      def generate_moogs_hash
        @definition.moogs.each do |moog|
          @moogs_hash[moog.name] = moog.to_hash
        end
      end

      def write_file
        File.open(SharedHelpers.lockfile_path.to_s, "w+") do |file|
          file.write(@moogs_hash.to_yaml)
        end
      end
    end
  end
end

