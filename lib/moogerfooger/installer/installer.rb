require "moogerfooger/installer/git_subtree"

module Mooger
  class Installer
    class << self
    end

    def self.install(definition, moogs_dir, options = {})
      installer = new(definition, moogs_dir)
      installer.run
      installer
    end

    def initialize(definition, moogs_dir)
      @definition = definition
      @moogs_dir = moogs_dir
    end

    def run
      create_moogs_dir_if_needed
      if @definition.moogs.empty?
        #TODO: warn empty moogerfile
        return
      end
      install
    end

		private

		def install
      subtree_installer = Mooger::Installer::GitSubtree.new(@definition, @moogs_dir)
      subtree_installer.generate
		end

    def create_moogs_dir_if_needed
      return if @moogs_dir.exist?
      Dir.mkdir(SharedHelpers.moogs_dir_path.to_s)
    end
  end
end
