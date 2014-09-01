module Clash
  class Tests
    include Helpers

    attr_accessor :tests

    def initialize(options={})
      ENV['JEKYLL_ENV'] = 'test'

      @options = options
      @results = []
      @passed = []
      @failed = []

      @options[:file]    ||= '.clash.yml'
      @options[:only]    ||= []
      @options[:exit]    ||= true

      @tests = read_tests
    end

    def run
      @tests.each_with_index do |options, index|
        # If tests are limited, only run specified tests
        #
        next if options.nil?
        run_test(options, index)
      end

      print_results
    end

    def run_test(options, index)

      options['index'] = index + 1
      options['context'] = @options[:context]

      results = Test.new(options).run

      if results.nil?
        @passed << index + 1
      else
        @failed << index + 1
        @results << results
      end
    end

    def read_tests
      return [] unless File.file?(@options[:file])
      tests = SafeYAML.load_file(@options[:file])
      index = 0

      default_array(tests).map do |test|
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
