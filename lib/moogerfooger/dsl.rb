require 'moogerfooger/errors'
require 'moogerfooger/moog'
require 'pathname'

module Mooger
	class Dsl

		def self.evaluate(moogerfile)
			builder = new
			builder.eval_moogerfile(moogerfile)
      builder
    end

    def initialize
      @moogs = []
      @moogerfile = nil
    end

    def eval_moogerfile(moogerfile)
      @moogerfile = moogerfile
      contents ||= File.read(@moogerfile)
      instance_eval(contents.dup.untaint, moogerfile.to_s, 1)
    rescue Exception => e
      message = "There was an error parsing " \
        "`#{File.basename moogerfile.to_s}`: #{e.message}"

      raise DSLError.new(message, moogerfile, e.backtrace, contents)
    end

    def to_definition()
      Definition.new(@moogs)
    end

    def moog(name, &block)
      raise MoogerfileError, "You need to pass a config block to #moog" if !block_given?
      validate_moog_name(name)
      moog = Moog.new(name)
      yield(moog)
      validate_moog_def(moog)
      @moogs << moog
    end

    private

    def validate_moog_name(name)
      if name.is_a?(Symbol)
        raise MoogerfileError, %(You need to specify moog names as Strings. Use 'moog "#{name}"' instead)
      end
      if name =~ /\s/
        raise MoogerfileError, %('#{name}' is not a valid moog name because it contains whitespace)
      end
      if name.empty?
        raise MoogerfileError, %(an empty moog name is not valid)
      end
      if @moogs.any?{|m| m.name == name}
        raise MoogerfileError, %(You specified: #{name} multiple times)
      end
    end

    def validate_moog_def(moog)
      if moog.repo.nil?
        raise MoogerfileError, %(You must specify a valid git repo)
      end
      if moog.branch.nil? && moog.tag.nil?
        raise MoogerfileError, %(You must specify either a branch or a tag)
      end
      if !moog.branch.nil? && !moog.tag.nil?
        raise MoogerfileError, %(You can't specify both the branch and the tag)
      end
    end

    class DSLError < Mooger::MoogerfileError
      # @return [String] the description that should be presented to the user.
      #
      attr_reader :description

      # @return [String] the path of the dsl file that raised the exception.
      #
      attr_reader :dsl_path

      # @return [Exception] the backtrace of the exception raised by the
      #         evaluation of the dsl file.
      #
      attr_reader :backtrace

      # @param [Exception] backtrace @see backtrace
      # @param [String]    dsl_path  @see dsl_path
      #
      def initialize(description, dsl_path, backtrace, contents = nil)
        @status_code = $!.respond_to?(:status_code) && $!.status_code

        @description = description
        @dsl_path    = dsl_path
        @backtrace   = backtrace
        @contents    = contents
      end

      def status_code
        @status_code || super
      end

      # @return [String] the contents of the DSL that cause the exception to
      #         be raised.
      #
      def contents
        @contents ||= begin
                        dsl_path && File.exist?(dsl_path) && File.read(dsl_path)
                      end
      end

      def to_s
        @to_s ||= begin
                    trace_line, description = parse_line_number_from_description

                    m = String.new("\n[!] ")
                    m << description
                    m << ". MoogerFooger cannot continue.\n"

                    return m unless backtrace && dsl_path && contents

                    trace_line = backtrace.find {|l| l.include?(dsl_path.to_s) } || trace_line
                    return m unless trace_line
                    line_numer = trace_line.split(":")[1].to_i - 1
                    return m unless line_numer

                    lines      = contents.lines.to_a
                    indent     = " #  "
                    indicator  = indent.tr("#", ">")
                    first_line = line_numer.zero?
                    last_line  = (line_numer == (lines.count - 1))

                    m << "\n"
                    m << "#{indent}from #{trace_line.gsub(/:in.*$/, "")}\n"
                    m << "#{indent}-------------------------------------------\n"
                    m << "#{indent}#{lines[line_numer - 1]}" unless first_line
                    m << "#{indicator}#{lines[line_numer]}"
                    m << "#{indent}#{lines[line_numer + 1]}" unless last_line
                    m << "\n" unless m.end_with?("\n")
                    m << "#{indent}-------------------------------------------\n"
                  end
      end

      private

      def parse_line_number_from_description
        description = self.description
        if dsl_path && description =~ /((#{Regexp.quote File.expand_path(dsl_path)}|#{Regexp.quote dsl_path.to_s}):\d+)/
            trace_line = Regexp.last_match[1]
          description = description.sub(/#{Regexp.quote trace_line}:\s*/, "").sub("\n", " - ")
        end
        [trace_line, description]
      end
    end
  end
end
