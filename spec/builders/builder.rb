require 'securerandom'
require "pry"

module Builder

  def build_moogerfile
    File.open("Moogerfile", "w") do |f|
      f.puts("DUMMY FILE")
    end
  end

  def build_moogs_dir
    Dir.mkdir(Mooger::SharedHelpers.moogs_dir_path.to_s)
  end

  def build_moog(name=SecureRandom.hex(5), repo="", branch= "master", tag="v1.2.3")
    Mooger::Moog.new(name, repo, branch, tag)
  end

  def build_definition(moogs=[build_moog])
    Mooger::Definition.new(moogs)
  end

  def build_subtree_installer(definition, moogs_dir)
    Mooger::Installer::GitSubtree.new(definition, moogs_dir)
  end
end

