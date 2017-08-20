require "pathname"

module Mooger
  module SharedHelpers

    class << self 

      def root
        moogerfile = find_moogerfile
        raise MoogerfileNotFound, "Could not locate Moogerfile" unless moogerfile
        Pathname.new(moogerfile).untaint.expand_path.parent
      end

      def moogs_dir
        moogs_dir = find_directory("Moogs")
        if moogs_dir.nil? 
          moogs_dir = root + "Moogs"
        end
        Pathname.new(moogs_dir).untaint.expand_path
      end

      def moogs_dir_path
        moogs_dir_path = root + "Moogs"
        Pathname.new(moogs_dir_path).untaint.expand_path
      end

      def moogerfile
        moogerfile = find_moogerfile
        raise MoogerfileNotFound, "Could not locate Moogerfile" unless moogerfile
        Pathname.new(moogerfile).untaint.expand_path
      end

      def lockfile
        lockfile = find_lockfile
        return nil if lockfile.nil?
        Pathname.new(lockfile).untaint.expand_path
      end

      def lockfile_path
        lockfile_path = root + lockfile_names.first
        Pathname.new(lockfile_path).untaint.expand_path
      end

      def file_exists?(file)
        file && File.file?(file)
      end

      private

      def find_moogerfile()
        names = moogerfile_names
        find_file(*names)
      end

      def find_lockfile()
        names = lockfile_names
        find_file(*names)
      end

      def moogerfile_names
        ["Moogerfile"]
      end

      def lockfile_names
        ["Moogerfile.lock"]
      end

      def find_file(*names)
        current_dir = File.expand_path(pwd).untaint
        names.each do |name|
          filename = File.join(current_dir, name)
          return filename if File.file?(filename)
        end
        nil
      end

      def find_directory(*names)
        current_dir = File.expand_path(pwd).untaint
        names.each do |name|
          dirname = File.join(current_dir, name)
          return dirname if File.directory?(dirname)
        end
        nil
      end

      def pwd
        Pathname.pwd
      end
    end
  end
end
