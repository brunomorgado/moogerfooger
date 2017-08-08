require "moogerfooger/installer/git_subtree"

module Mooger
  class Installer
    class << self
    end

    def self.install(root, definition, options = {})
      installer = new(root, definition)
      installer.run(options)
      installer
    end

    def initialize(root, definition)
      @root = root
      @definition = definition
    end

    def run(options)
      create_moogs_path
      if @definition.moogs.empty?
        #TODO: warn empty moogerfile
        return
      end
      install
    end

		private

		def install
      subtree_installer = Mooger::Installer::GitSubtree.new(@definition)
      subtree_installer.generate
		end

		def create_moogs_path
			SharedHelpers.filesystem_access(Mooger.moogs_path.to_s) do |p|
				Mooger.mkdir_p(p)
			end unless Mooger.moogs_path.exist?
		rescue Errno::EEXIST
			raise PathError, "Could not install to path `#{Mooger.moogs_path}` " \
				"because a file already exists at that path. Either remove or rename the file so the directory can be created."
		end
	end
end
