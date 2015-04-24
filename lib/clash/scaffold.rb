module Clash
  class Scaffold
    attr_accessor :options

    def initialize(options = {})
      @options = {
        path: 'test',
        name: 'site',
        force: false
      }.merge(options)

      @options[:path] = File.expand_path(@options[:path], Dir.pwd)
    end

    def test_template
      File.expand_path("../../scaffold", File.dirname(__FILE__))
    end

    def create
      FileUtils.mkdir_p @options[:path]

      if preserve_source_location?
        abort "Conflict: #{@options[:path]} exists and is not empty."
      end

      FileUtils.cp_r test_template + '/.', @options[:path]

      puts "Clash test added to #{@options[:path]}."
    end

    def add
    end

    private

    def preserve_source_location?
      !@options[:force] && !Dir["#{@options[:path]}/**/*"].empty?
    end

    def dasherize(string)
      string.gsub(/ /,'-').gsub(/[^\w-]/,'').gsub(/-{2,}/,'-').downcase
    end
  end
end
