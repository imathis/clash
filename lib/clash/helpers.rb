module Clash
  module Helpers
    extend self

    def expand_list_of_numbers(only)
      # Used in options[:only] to expand all possibilities.
      if only.is_a?(Array)
        only = only.join(',')
      end
      only.split(',').map do |num|
        if num.include?("-")
          expand_range(num)
        else
          get_number(num)
        end
      end.flatten.sort.uniq
    end

    def expand_range(string_range)
      lower, upper = string_range.split("-").map{|n| get_number(n)}.take(2).sort
      Array.new(upper+1 - lower).fill { |i| i + lower }
    end

    def get_number(num)
      if num.start_with?(':')
        test_at_line_number(num)
      else
        num.to_i
      end
    end

    def read_test_line_numbers(path)
      @test_lines ||= []
      count = 1
      strip_tasks(File.read(path)).each_line do |line|
        @test_lines << count if line =~ /^-/
        count += 1
      end
    end

    def strip_tasks(content)
      content.gsub(/-\s+tasks:.+?^-/im) do |match|
        match.gsub(/.+?\n/,"\n")
      end
    end

    def test_at_line_number(line_number)
      ln = line_number.sub(':', '').to_i
      test_number = nil
      lines = @test_lines
      lines.each_with_index do |line, index|
        last = index == lines.size - 1

        if line <= ln && ( last || ln <= lines[index + 1] )
          test_number = index + 1
        end
      end

      if test_number
        test_number
      else
        puts "No test found on line #{ln}"
      end
    end

    def default_array(option)
      o = option || []
      o = [o] unless o.is_a?(Array)
      o
    end

    def colorize(str, color)
      if STDOUT.tty?
        str.send(color)
      else
        str
      end
    end

    def system(*cmd)
      cmd = cmd.join(' ')
      # Don't ouput to /dev/null if in debug mode
      # or if a command supplies its own ouput
      if !ENV['DEBUG'] && !(cmd =~ / > /)
        cmd << " > /dev/null"
      end

      Kernel.system cmd
    end

    # Print a single character without a newline
    #
    def pout(str)
      print str
      if STDOUT.tty?
        $stdout.flush
      end
    end

    def greenit(str)
      colorize(str, 'green')
    end

    def yellowit(str)
      colorize(str, 'yellow')
    end

    def redit(str)
      colorize(str, 'red')
    end

    def boldit(str)
      colorize(str, 'bold')
    end

    def print_fail
      pout redit('F')
    end

    def print_pass
      pout greenit('.')
    end
  end
end
