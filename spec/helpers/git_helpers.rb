require "pry"

module GitHelpers

  GIT_REPOS_PATH="/../tmp/git_repos"

  def create_git_repo(name, options = {})
    path = path_for_git_repo(name)

    FileUtils.mkdir_p(path)

    Dir.chdir(path) do
      git %|init --bare .|
      git %|config core.sharedrepository 1|
      git %|config receive.denyNonFastforwards true|
      git %|config receive.denyCurrentBranch ignore|
    end

    Dir.chdir(path) do
      git %|init .|
      system %|rm HEAD|
      git %|add .|
      git %|commit -am "Initial commit for #{name}..."|

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
    repos_path_abs = File.dirname(__FILE__) + GIT_REPOS_PATH
    path = File.join(repos_path_abs, name)
  end

  def do_in_repo(repo, &block)
    path = path_for_git_repo(repo)
    return if !File.exists?(path)
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
