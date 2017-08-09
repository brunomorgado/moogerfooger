module Mooger
    class CLI::List

      def initialize(options)
        @options = options
      end

      def run
        definition = Mooger.definition
        definition.moogs.each do |moog|
          puts moog.name
        end
      end

    end
end
