RSpec.describe "Mooger install with moogerfile that uses eval_moggerfile" do
  context "eval-ed Moogerfile points to an internal gemspec" do
    before do
      create_file "Gemfile-other", <<-G
        gemspec :path => 'gems/gunks'
      G
    end

    it "installs the gemspec specified gem" do
      install_gemfile <<-G
        eval_gemfile 'Gemfile-other'
      G
      expect(out).to include("Resolving dependencies")
      expect(out).to include("Bundle complete")

      expect(the_bundle).to include_gem "gunks 0.0.1", :source => "path@#{bundled_app("gems", "gunks")}"
    end
  end
end
