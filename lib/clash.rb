require 'colorator'
require 'find'
require 'safe_yaml'
require 'diffy'

module Clash
  def self.test(options={})
    @results = {}

    test_file = options[:config]  || '.clash.yml'
    test_list = default_array(options[:tests])
    tests = default_array(SafeYAML.load_file(test_file))

    if !test_list.empty?
      list = []
      test_list.each do |t|
        list << tests[t - 1] if tests[t - 1]
      end
      tests = list
    end

    tests.each_with_index do |options, index|
      test = Test.new(options)
      test.run

      results = test.results
      if !results.empty?
        @results[index + 1] = results
      end
    end
    
    print_results
  end

  def self.print_results
    puts "" # newline

    if @results.empty?
      puts 'All passed'.green
    else
      @results.each do |test, results|
        if !results.empty?
          puts "\nFailed test ##{test}:\n-"
          puts "#{results.join('').strip}-"
        end
      end
    end
  end

  def self.default_array(option)
    o = option || []
    o = [o] unless o.is_a?(Array)
    o
  end

  # Print a single character without a newline
  #
  def self.pout(str)
    print str
    $stdout.flush
  end

  def self.print_fail
    pout "F".red
  end

  def self.print_pass
    pout ".".green
  end

  class Test
    def initialize(options={})
      @test_failures = []
      @build    = options['build']
      @compare  = Clash.default_array(options['compare'])
      @missing  = Clash.default_array(options['enforce_missing'])
      @before   = Clash.default_array(options['before'])
      @after    = Clash.default_array(options['after'])
    end

    def run
      system_cmd(@before)
      build
      compare
      enforce_missing
      system_cmd(@after)
    end

    def build
      if @build
        system("jekyll build --trace")
      end
    end

    def system_cmd(cmds)
      cmds.each {|cmd| system(cmd) }
    end

    def compare
      @compare.each do |files|
        f = files.split(',')
        diff = Diff.new(f[0].strip, f[1].strip).diff
        diff.each do |title, diff|
          @test_failures << "#{title}\n#{format_diff(diff)}\n"
        end
      end
    end

    def enforce_missing
      @missing.each do |files|
        if File.exists?(file)
          @test_failures << "File #{file} shouldn't exist."
          print_fail
        else
          Clash.print_pass
        end
      end
    end

    def format_diff(diff)

      diff = diff.map { |line|
        case line
        when /^\+/ then line.green
        when /^-/ then line.red
        else line
        end
      }
      diff.join('')
    end

    def results
      @test_failures
    end

  end

  class Diff
    def initialize(a, b)
      @diffs = {}
      @a     = a
      @b     = b
    end

    def diff
      if File.directory?(@a)
        diff_dirs(@a, @b)
      else
        diff_files(@a, @b)
      end

      @diffs
    end

    def diff_files(a, b)
      if exists(a) && exists(b)
        diffy = Diffy::Diff.new(a,b, :source => 'files', :context => 0)
        file_diff = diffy.to_a

        if !file_diff.empty?
          @diffs["Compared #{a.yellow} to #{b.yellow}"] = file_diff 
          Clash.print_fail
        else
          Clash.print_pass
        end
      end
    end
    
    # Recursively diff common files between dir1 and dir2
    #
    def diff_dirs(dir1, dir2)
      mattching_dir_files(dir1, dir2).each do |file|
        a = File.join(dir1, file)
        b = File.join(dir2, file)
        diff_files(a,b)
      end
    end

    # Return files that exist in both directories (without dir names)
    #
    def mattching_dir_files(dir1, dir2)
      dir1_files = dir_files(dir1).map {|f| f.sub(dir1,'') }
      dir2_files = dir_files(dir2).map {|f| f.sub(dir2,'') }

      matches = dir1_files & dir2_files

      unique_files(dir1, dir1_files, matches)
      unique_files(dir2, dir2_files, matches)

      matches
    end

    # Find all files in a given directory
    #
    def dir_files(dir)
      Find.find(dir).to_a.reject!{|f| File.directory?(f) }
    end

    # Find files which aren't common to both directories
    #
    def unique_files(dir, dir_files, common_files)
      unique = dir_files - common_files
      if !unique.empty?
        @test_failures << "Files missing from #{dir}/".red
        unique.each {|f| @test_failures << "- #{f}"}
        Clash.print_fail
      end
    end

    def exists(f)
      file_exists = File.exists?(f)

      if !file_exists
        @test_failures << "File not found: #{f}"
        Clash.print_fail
      end

      file_exists
    end
  end
end
