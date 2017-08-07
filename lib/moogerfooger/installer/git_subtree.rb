module Mooger
  class Installer
    class GitSubtree

      def initialize(definition)
        @definition = definition
      end

      def generate
        puts @definition.moogs
        @definition.moogs.each do |moog|
          system "git remote add -f #{moog.name} #{moog.repo}"
          system "git subtree add --prefix #{Mooger.default_moogs_dir} #{moog.name} #{moog.branch} --squash"
        end
      end
    end
  end
end
