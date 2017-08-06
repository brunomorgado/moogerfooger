require "pathname"

module Mooger
  module SharedHelpers

    def root
      moogerfile = find_moogerfile
      raise MoogerfileNotFound, "Could not locate Moogerfile" unless moogerfile
      Pathname.new(moogerfile).untaint.expand_path.parent
    end

		def default_moogs_dir
			moogs_dir = find_directory("Moogs")
			return nil unless moogs_dir
			moogs_dir = Pathname.new(moogs_dir)
			moogs_dir
		end

    def self.default_moogerfile
      moogerfile = SharedHelpers.find_moogerfile
			raise MoogerfileNotFound, "Could not locate Moogerfile" unless moogerfile
			Pathname.new(moogerfile).untaint.expand_path
		end

		def filesystem_access(path, action = :write, &block)
			# Use block.call instead of yield because of a bug in Ruby 2.2.2
			# See https://github.com/bundler/bundler/issues/5341 for details
			block.call(path.dup.untaint)
		rescue Errno::EACCES
			raise PermissionError.new(path, action)
		rescue Errno::EAGAIN
			raise TemporaryResourceError.new(path, action)
		rescue Errno::EPROTO
			raise VirtualProtocolError.new
		rescue Errno::ENOSPC
			raise NoSpaceOnDeviceError.new(path, action)
		rescue *[const_get_safely(:ENOTSUP, Errno)].compact
			raise OperationNotSupportedError.new(path, action)
		rescue Errno::EEXIST, Errno::ENOENT
			raise
		rescue SystemCallError => e
			raise GenericSystemCallError.new(e, "There was an error accessing `#{path}`.")
		end

		private

    def self.find_moogerfile()
			given = ENV["MOOGERFILE_PATH"]
			return given if given && !given.empty?
      names = SharedHelpers.moogerfile_names
      SharedHelpers.find_file(*names)
		end

    def self.moogerfile_names
			["Moogerfile"]
		end

    def self.find_file(*names)
      SharedHelpers.search_up(*names) do |filename|
				return filename if File.file?(filename)
			end
		end

		def find_directory(*names)
			search_up(*names) do |dirname|
				return dirname if File.directory?(dirname)
			end
		end

    def self.search_up(*names)
			previous = nil
			current  = File.expand_path(SharedHelpers.pwd).untaint

			until !File.directory?(current) || current == previous
				names.each do |name|
					filename = File.join(current, name)
					yield filename
				end
				previous = current
				current = File.expand_path("..", current)
			end
		end

    def self.pwd
			Pathname.pwd
		end
	end
end
