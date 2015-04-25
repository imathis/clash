module Clash
  class Scaffold
    attr_accessor :options

    def initialize(options = {})
      @options = {
        path: 'test',
        title: 'Test Build',
        dir: 'test-site',
        force: false
      }.merge(options)

      @options[:path] = File.expand_path(@options[:path], Dir.pwd)
    end

    def add_test
      config = File.join(@options[:path], '_clash.yml')

      prevent_dir_name_collisions
      content = test_content

      if !File.exist?(config)
        content.lstrip!
      end

      path = File.join(@options[:path], @options[:dir])

      FileUtils.mkdir_p path
      FileUtils.cp_r test_template + '/.', path


      File.open(config, 'a') do |f|
        f.write content
      end
      
      puts "New Clash test added to " + @options[:path].yellow
      print_test_files(path)
      puts "Tests:"
    end

    private

    def print_test_files(path)
      FileUtils.cd path do
        files = Dir['**/*']
        files.map! { |f|
          if f.match /\//
            f.gsub!(/[^\/]+\//, '  ')
          end
          if File.directory?(f)
            f += '/'
          end
          "+    #{f}"
        }
        puts "\n+  #{@options[:dir]}/\n#{files.join("\n")}\n".green
      end
    end

    def test_template
      File.expand_path("../../scaffold/site", File.dirname(__FILE__))
    end

    # If necessary append a number to directory to avoid directory collision
    #
    def prevent_dir_name_collisions
      
      # Find directories beginning with test directory name
      #
      dirs = Dir.glob("#{@options[:path]}/*").select { |d|
        File.directory?(d) && d.match(/#{@options[:dir]}($|-\d+$)/)
      }.size

      # If matching directories are found, increment the dir name
      # e.g. "test-site-2"
      #
      if dirs > 0
        @options[:dir] << "-#{dirs += 1}"
      end
    end

    def preserve_source_location?
      !@options[:force] && !Dir["#{@options[:path]}/**/*"].empty?
    end

    def dasherize(string)
      string.gsub(/ /,'-').gsub(/[^\w-]/,'').gsub(/-{2,}/,'-').downcase
    end

    def test_content
%Q{
- 
  title: "#{@options[:title]}"
  dir: #{@options[:dir]}
  build: true
  compare: _expected _site
}
    end
  end
end
