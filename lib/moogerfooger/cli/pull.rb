module Mooger
  class CLI::Pull
    attr_reader :options
    def initialize(options, moog_name)
      @options = options
      @moog_name = moog_name
      @moog = Moog.find(moog_name)
    end

    def run
      if @moog.nil?
        puts "Moog with name: #{@moog_name} not found. Unable to pull."
        return
      end

      pull_remote(Mooger.default_moogs_dir.split().last + @moog.name, @moog.name, @moog.branch)
    end

    private

    def pull_remote(path, remote_name, branch)
      system "git subtree pull —-prefix=#{path.to_s} #{remote_name} #{branch}"
    end
  end
end
