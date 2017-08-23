require 'securerandom'
require "pry"

module Builder

  def build_moog(name=SecureRandom.hex(5), repo="", branch= "master", tag="v1.2.3")
    Mooger::Moog.new(name, repo, branch, tag)
  end

  def build_definition(moogs=[build_moog])
    Mooger::Definition.new(moogs)
  end

  def build_subtree_installer(definition)
    Mooger::Installer::GitSubtree.new(definition)
  end
end

