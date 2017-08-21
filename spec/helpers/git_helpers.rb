require "pry"

module GitHelpers

  GIT_REPOS_PATH="spec/tmp/git_repos"

  def git_repo(name, options = {})
    path = File.join(GIT_REPOS_PATH, name)
    remote_url = "file://#{path}"

    FileUtils.mkdir_p(path)

    #Dir.chdir(path) do
    #git %|init --bare|
    #git %|config core.sharedrepository 1|
    #git %|config receive.denyNonFastforwards true|
    #git %|config receive.denyCurrentBranch ignore|
    #end

    Dir.chdir(path) do
      # Create a bogus file
      File.open('file', 'w') do
        |f| f.write('hello') 
      end

      git %|init .|
      git %|add .|
      git %|commit -am "Initial commit for #{name}..."|
      git %|remote add origin "#{remote_url}"|
      git %|push origin master|

      options[:tags].each do |tag|
        File.open('tag', 'w') { |f| f.write(tag) }
        git %|add tag|
        git %|commit -am "Create tag #{tag}"|
        git %|tag "#{tag}"|
        git %|push origin "#{tag}"|
      end if options[:tags]

      options[:branches].each do |branch|
        git %|checkout -b #{branch} master|
        File.open('branch', 'w') { |f| f.write(branch) }
        git %|add branch|
        git %|commit -am "Create branch #{branch}"|
        git %|push origin "#{branch}"|
        git %|checkout master|
      end if options[:branches]
    end

    path
  end

  def git(command)
    original_env = ENV.to_hash

    time = Time.at(680227200).utc.strftime('%c %z')

    ENV['GIT_AUTHOR_NAME']     = 'brunomorgado'
    ENV['GIT_AUTHOR_EMAIL']    = 'morgado@test.com'
    ENV['GIT_AUTHOR_DATE']     = time
    ENV['GIT_COMMITTER_NAME']  = 'bfcmorgado'
    ENV['GIT_COMMITTER_EMAIL'] = 'morgado_test@test.com'
    ENV['GIT_COMMITTER_DATE']  = time

    system "git #{command}"
  ensure
    ENV.replace(original_env.to_hash)
  end

  def path_for_git_repo(name)
    path = File.join(GIT_REPOS_PATH, name)
  end

  def do_in_repo(repo, &block)
    Dir.chdir(path_for_git_repo(repo)) do
      block.call
    end
  end

  def create_file(name = "dummy")
      File.open(name, "w") do |f|
        f.puts("DUMMY FILE")
      end
  end
end
