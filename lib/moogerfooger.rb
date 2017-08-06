require "pathname"
require "moogerfooger/version"

module Mooger

	require "moogerfooger/errors"
	require "moogerfooger/dsl"
  require "moogerfooger/definition"
  require "moogerfooger/shared_herlpers"
  require "moogerfooger/cli"

	class << self

		def root_path
			@root ||= begin
							 SharedHelpers.root
								rescue MoogerfileNotFound
									moogs_dir = default_moogs_dir
									raise MoogerfileNotFound, "Could not locate Moogerfile" unless moogs_dir
									Pathname.new(File.expand_path("..", moogs_dir))
								end
		end

		def default_moogs_dir
			SharedHelpers.default_moogs_dir
		end

    def default_moogerfile
      SharedHelpers.default_moogerfile
    end

    def moogs_path
      @moogs_path ||= Pathname.new(default_moogs_dir).expand_path(root_path)
    end

    def definition
      @definition ||= begin
                        Definition.build(default_moogerfile)
                      end
    end

    def read_file(file)
      File.open(file, "rb", &:read)
    end

    def mkdir_p(path)
      SharedHelpers.filesystem_access(path, :write) do |p|
        FileUtils.mkdir_p(p)
      end
    end
  end
end
