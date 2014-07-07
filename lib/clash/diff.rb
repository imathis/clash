module Clash
  class Diff
    include Helpers

    def initialize(a, b, options={})
      @diffs   = {}
      @a       = a
      @b       = b
      @context = options[:context] || 2
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
        diffy = Diffy::Diff.new(a,b, :source => 'files', :context => @context)
        file_diff = diffy.to_a

        if !file_diff.empty?
          file_diff = format_diff(file_diff)
          @diffs["Compared #{colorize(a, 'yellow')} to #{colorize(b,'yellow')}"] = file_diff 
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
        @test_failures << colorize("Files missing from #{dir}/", 'red')
        unique.each {|f| @test_failures << "- #{f}"}
      end
    end

    def exists(f)
      file_exists = File.exists?(f)

      if !file_exists
        @test_failures << "#{colorize('File not found:', 'red')} #{f}"
      end

      file_exists
    end


    def format_diff(diff)
      count = 0

      diff = diff.map { |line|
        case line
        when /^\+/ then 
          count = 0
          colorize(line, 'green')
        when /^-/ then 
          count = 0
          colorize(line, 'red')
        else 
          if count == @context
            count = 0
            "...\n#{line}"
          else
            count += 1
            line
          end
        end
      }
      diff.join('')
    end

  end
end
