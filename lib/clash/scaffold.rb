module Clash
  class Scaffold
    attr_accessor :options

    def initialize(args, options = {})
      raise 'You must specify a path.' if args.empty?

      test_path = File.expand_path(args.join(" "), Dir.pwd)
      FileUtils.mkdir_p test_path
      if preserve_source_location?(test_path, options)
        abort "Conflict: #{test_path} exists and is not empty."
      end

      add_test_scaffold test_path

      puts "Clash test added to #{test_path}."
    end

    def add_test_scaffold(path)
      FileUtils.cp_r test_template + '/.', path
    end

    def test_template
      File.expand_path("../../scaffold", File.dirname(__FILE__))
    end

    private

    def preserve_source_location?(path, options)
      !options[:force] && !Dir["#{path}/**/*"].empty?
    end
  end
end
