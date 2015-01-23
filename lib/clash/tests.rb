module Clash
  class Tests
    include Helpers

    attr_accessor :tests

    def initialize(options={})
      @options = options

      ENV['JEKYLL_ENV'] = 'test'

      if @options[:debug]
        ENV['DEBUG'] = 'true'
      end

      @results = []
      @passed = []
      @failed = []
      @tasks = {}

      @options[:only]    ||= []
      @options[:exit]    ||= true
      @options[:path]    ||= '.'
      @options[:file]    ||= '_clash.yml'

      @tests = read_tests
    end

    def list
      @tests.each_with_index do |options, index|
        # If tests are limited, only run specified tests
        #
        next if options.nil?
        list_test(options, index)
      end
    end

    def list_test(options, index)
      number = boldit((index + 1).to_s.rjust(3))
      title = options['title'] || "Untitled test"
      puts "#{number}) #{title}"
    end

    def run

      Dir.chdir(@options[:path]) do
        @tests.each_with_index do |options, index|
          # If tests are limited, only run specified tests
          #
          next if options.nil?
          run_test(options, index)
        end
      end

      print_results
    end

    def run_test(options, index)

      options['index'] = index + 1
      options['context'] = @options[:context]
      options['tasks'] = @tasks

      results = Test.new(options).run

      if results.nil?
        @passed << index + 1
      else
        @failed << index + 1
        @results << results
      end
    end

    def read_tests
      tests = read_config
      index = 0
      delete_tests = []

      tests = default_array(tests).map do |test|
        if !test['tasks'].nil?
          @tasks.merge! test['tasks']
          delete_tests << test
        else
          index += 1

          # Admit all tests if no tests are excluded
          if @options[:only].empty?
            test
          # Only admit selected tests
          elsif @options[:only].include?(index)
            test
          # Remove tests not selected
          else
            nil
          end
        end
      end
      tests - [delete_tests]

    end

    def read_config
      # Find the config file
      path = config_path

      if !path
        # Look for legacy file name
        path = config_path('.clash.yml')
      end
      
      # If config file still not found, complain
      if !path
        raise "Config file #{@options[:file]} not found."
      end

      SafeYAML.load_file(path)
    end

    def config_path(file=nil)
      file ||= @options[:file]
      path = File.join('./', @options[:path])
      paths = []

      (path.count('/') + 1).times do
        paths << File.join(path, file)
        path.sub!(/\/[^\/]+$/, '')
      end

      paths.find {|p| File.file?(p) }
    end

    def print_results


      puts boldit("\n\nFailures:") unless @results.empty?
      @results.each do |results|
        puts "\n#{results.join('')}"
      end

      puts boldit("\n\nTest summary:")
      puts yellowit(" Tests run: #{@passed.dup.concat(@failed).size}")
      puts "#{greenit(" Passed #{@passed.size}")} #{list_tests(@passed)}"
      puts "#{redit(" Failed #{@failed.size}")} #{list_tests(@failed)}"

      exit 1 if @options[:exit] && !@results.empty?
    end

    def list_tests(tests)
      if tests.empty?
        ''
      else
        "- Tests: #{tests.join(',')}"
      end
    end
  end
end
