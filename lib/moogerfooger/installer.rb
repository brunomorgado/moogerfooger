require "moogerfooger/installer/git_subtree"

module Mooger
  class Installer
    class << self
    end

    def self.install(definition, options = {})
      installer = new(definition)
      installer.run(options)
      installer
    end

    def initialize(definition)
      @definition = definition
    end

    def run(options)
      create_moogs_dir
      if @definition.moogs.empty?
        #TODO: warn empty moogerfile
        return
      end
      install
    end

		private

		def install
      subtree_installer = Mooger::Installer::GitSubtree.new(@definition, SharedHelpers.moogs_dir)
      subtree_installer.generate
		end

    def create_moogs_dir
      return if SharedHelpers.moogs_dir.exist?
      Dir.mkdir(SharedHelpers.moogs_dir_path)
    end
  end
end
