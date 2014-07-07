module Clash
  module Helpers
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
