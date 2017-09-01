require "moogerfooger/generator/gitignore_generator"

module Mooger
    class CLI::Init

      def initialize(options={})
        @options = options
      end

      def run

        #begin
        #installer = Mooger::Installer::GitSubtree.new(Mooger.definition(true), @options)
        #installer.run
        #rescue => e
          #puts e
          #Mooger.reset
        #end

      end
    end
end
