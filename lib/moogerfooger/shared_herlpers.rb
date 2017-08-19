require "pathname"

module Mooger
  module SharedHelpers

    def self.root
      moogerfile = find_moogerfile
      raise MoogerfileNotFound, "Could not locate Moogerfile" unless moogerfile
      Pathname.new(moogerfile).untaint.expand_path.parent
    end

    def self.default_moogs_dir
			moogs_dir = find_directory("vendor")
      if moogs_dir.nil? 
        moogs_dir = root + "vendor"
      end
      Pathname.new(moogs_dir).untaint.expand_path
		end

    def self.default_moogerfile
      moogerfile = find_moogerfile
			raise MoogerfileNotFound, "Could not locate Moogerfile" unless moogerfile
			Pathname.new(moogerfile).untaint.expand_path
		end

    def self.default_lockfile
      lockfile = find_lockfile
      if lockfile.nil? 
        lockfile = root + lockfile_names.first
      end
      Pathname.new(lockfile).untaint.expand_path
    end

    def self.filesystem_access(path, action = :write, &block)
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

    def self.mkdir_p(path)
      filesystem_access(path, :write) do |p|
        FileUtils.mkdir_p(p)
      end
    end

    def self.read_file(file)
      filesystem_access(path, :write) do |p|
        File.open(file, "rb", &:read)
      end
    end

    private

    def self.find_moogerfile()
      names = moogerfile_names
      find_file(*names)
    end

    def self.find_lockfile()
      names = lockfile_names
      find_file(*names)
    end

    def self.moogerfile_names
      ["Moogerfile"]
    end

    def self.lockfile_names
      ["Moogerfile.lock"]
    end

    def self.find_file(*names)
      current_dir = File.expand_path(pwd).untaint
      names.each do |name|
        filename = File.join(current_dir, name)
        return filename if File.file?(filename)
      end
      nil
    end

    def self.find_directory(*names)
      current_dir = File.expand_path(pwd).untaint
      names.each do |name|
        dirname = File.join(current_dir, name)
        return dirname if File.directory?(dirname)
      end
      nil
    end

    def self.pwd
      Pathname.pwd
    end
  end
end
