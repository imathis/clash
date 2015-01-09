module Clash
  module Helpers
    extend self

    def expand_list_of_numbers(only)
      # Used in options[:only] to expand all possibilities.
      if only.is_a?(Array)
        only = only.join(',')
      end
      only.split(',').map do |n|
        if n.include?("-")
          expand_range(n)
        else
          n.to_i
        end
      end.flatten.sort.uniq
    end

    def expand_range(string_range)
      lower, upper = string_range.split("-").map(&:to_i).take(2).sort
      Array.new(upper+1 - lower).fill { |i| i + lower }
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
      Kernel.system("#{cmd.join(' ')} > #{output_file}")
    end

    def output_file
      @output_file ||= (ENV['DEBUG'] ? '/dev/stdout' : '/dev/null')
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
