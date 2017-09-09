require 'moogerfooger/shared_herlpers'
require 'moogerfooger/generator/lockfile_generator'
require 'moogerfooger/parser/lockfile_parser'

module Mooger
	class Definition

		attr_reader(
			:moogs
    )

    def self.build
      unless Mooger.locked?
        definition = Dsl.evaluate(SharedHelpers.moogerfile).to_definition
        # Interrupt if there are no Moogs defined
        return definition if definition.moogs.nil? || definition.moogs.empty?
        # Generate lockfile
        Generator::LockfileGenerator.generate(definition)
      end
      definition = Parser::LockfileParser.parse(SharedHelpers.lockfile).to_definition
    end

    def initialize(moogs)
      @moogs = moogs
    end
  end
end
