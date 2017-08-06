
module Spec
  module Builders

    def build_moog(name, *args, &blk)
      build_with(MoogBuilder, name, args, &blk)
    end

    private

    def build_with(builder, name, args, &blk)
      @_build_path ||= nil
      @_build_repo ||= nil
      options  = args.last.is_a?(Hash) ? args.pop : {}
      versions = args.last || "1.0"
      spec     = nil

      options[:path] ||= @_build_path
      options[:source] ||= @_build_repo

      Array(versions).each do |version|
        spec = builder.new(self, name, version)
        spec.authors = ["no one"] if !spec.authors || spec.authors.empty?
        yield spec if block_given?
        spec._build(options)
      end

      spec
    end

    class MoogBuilder
      def initialize(context, name, version)
        @context = context
        @name    = name
        @spec = Gem::Specification.new do |s|
          s.name        = name
          s.version     = version
          s.summary     = "This is just a fake gem for testing"
          s.description = "This is a completely fake gem, for testing purposes."
          s.author      = "no one"
          s.email       = "foo@bar.baz"
          s.homepage    = "http://example.com"
          s.license     = "MIT"
        end
        @files = {}
      end

      def method_missing(*args, &blk)
        @spec.send(*args, &blk)
      end

      def write(file, source = "")
        @files[file] = source
      end

      def executables=(val)
        @spec.executables = Array(val)
        @spec.executables.each do |file|
          executable = "#{@spec.bindir}/#{file}"
          shebang = if Bundler.current_ruby.jruby?
                      "#!/usr/bin/env jruby\n"
                    else
                      "#!/usr/bin/env ruby\n"
                    end
          @spec.files << executable
          write executable, "#{shebang}require '#{@name}' ; puts #{Builders.constantize(@name)}"
        end
      end

      def add_c_extension
        require_paths << "ext"
        extensions << "ext/extconf.rb"
        write "ext/extconf.rb", <<-RUBY
          require "mkmf"
          # exit 1 unless with_config("simple")
          extension_name = "very_simple_binary_c"
          dir_config extension_name
          create_makefile extension_name
        RUBY
        write "ext/very_simple_binary.c", <<-C
          #include "ruby.h"
          void Init_very_simple_binary_c() {
            rb_define_module("VerySimpleBinaryInC");
          }
        C
      end

      def _build(options)
        path = options[:path] || _default_path

        if options[:rubygems_version]
          @spec.rubygems_version = options[:rubygems_version]
          def @spec.mark_version; end

          def @spec.validate; end
        end

        case options[:gemspec]
        when false
          # do nothing
        when :yaml
          @files["#{name}.gemspec"] = @spec.to_yaml
        else
          @files["#{name}.gemspec"] = @spec.to_ruby
        end

        unless options[:no_default]
          gem_source = options[:source] || "path@#{path}"
          @files = _default_files.
            merge("lib/#{name}/source.rb" => "#{Builders.constantize(name)}_SOURCE = #{gem_source.to_s.dump}").
            merge(@files)
        end

        @spec.authors = ["no one"]

        @files.each do |file, source|
          file = Pathname.new(path).join(file)
          FileUtils.mkdir_p(file.dirname)
          File.open(file, "w") {|f| f.puts source }
        end
        @spec.files = @files.keys
        path
      end

      def _default_files
        @_default_files ||= begin
                              platform_string = " #{@spec.platform}" unless @spec.platform == Gem::Platform::RUBY
                              { "lib/#{name}.rb" => "#{Builders.constantize(name)} = '#{version}#{platform_string}'" }
                            end
      end

      def _default_path
        @context.tmp("libs", @spec.full_name)
      end
    end
  end
end
