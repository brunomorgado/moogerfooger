require 'securerandom'
require "pry"

module Builder

  def build_moogerfile(*args)
    str  = args.shift || ""
    File.open("Moogerfile", "w") do |f|
      f.puts strip_whitespace(str)
    end
  end

  def build_lockfile(*args)
    str  = args.shift || ""
    File.open("Moogerfile.lock", "w") do |f|
      f.puts strip_whitespace(str)
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

  private

  def strip_whitespace(str)
    spaces = str[/\A\s+/, 0] || ""
    str.gsub(/^#{spaces}/, "")
  end

end

