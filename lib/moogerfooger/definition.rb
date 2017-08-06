module Mooger
	class Definition

		attr_reader(
			:moogs,
      :moogerfile
    )

    def self.build(moogerfile)
      moogerfile = Pathname.new(moogerfile).expand_path
      raise MoogerfileNotFound, "#{moogerfile} not found" unless moogerfile.file?
      Dsl.evaluate(moogerfile)
    end

    def initialize(moogs, moogerfile)
      @moogs = moogs
      @moogerfile = moogerfile
    end
  end
end
