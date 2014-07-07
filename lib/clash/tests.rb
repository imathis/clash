module Clash
  class Tests
    include Helpers

    def initialize(options={})
      @options = options

      @options[:file]    ||= '.clash.yml'
      @options[:context] ||= 2
      @options[:only]      = default_array(@options[:only])

      @tests = default_array(SafeYAML.load_file(@options[:file]))
    end

    def run
      @results = {}
      @passed = []
      @failed = []
      @tests.each_with_index do |options, index|

        # If tests are limited, only run specified tests
        #
        next if !@options[:only].empty? && !@options[:only].include?(index + 1)

        options['index'] = index + 1
        options['context'] = @options[:context]

        results = Test.new(options).run

        if results.nil?
          @passed << index + 1
        else
          @failed << index + 1
          @results[index + 1] = results
        end
      end

      print_results
    end

    def print_results
      puts # newline

      if @results.empty?
        puts vomit("Passed #{@passed.size} of #{@passed.size} tests")
      else
        @results.each do |test, results|
          if !results.empty?
            puts "\n#{results.join('')}"
          end
        end

        puts "#{vomit("Passed #{@passed.size}")}: Tests: #{@passed.join(',')}"
        puts "#{bleed("Failed #{@failed.size}")}: Tests: #{@failed.join(',')}"
      end
    end
  end
end
