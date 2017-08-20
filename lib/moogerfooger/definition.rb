require 'moogerfooger/shared_herlpers'
require 'moogerfooger/generator/lockfile_generator'
require 'moogerfooger/parser/lockfile_parser'

module Mooger
	class Definition

		attr_reader(
			:moogs,
    )

    def self.build
      unless Mooger.locked?
        definition = Dsl.evaluate(SharedHelpers.moogerfile)
        Generator::LockfileGenerator.generate(definition)
      end
      definition = Parser::LockfileParser.parse(SharedHelpers.lockfile).to_definition
      definition
    end

    def initialize(moogs)
      @moogs = moogs
    end
  end
end
