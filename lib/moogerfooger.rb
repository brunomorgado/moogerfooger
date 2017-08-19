require "pathname"
require "moogerfooger/version"

module Mooger

	require "moogerfooger/errors"
	require "moogerfooger/dsl"
  require "moogerfooger/definition"
  require "moogerfooger/shared_herlpers"
  require "moogerfooger/cli"

	class << self

    def definition
      @definition ||= begin
                        Definition.build(moogerfile)
                      end
    end
  end
end
