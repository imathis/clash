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

    def print_fail
      pout colorize('F', 'red')
    end

    def print_pass
      pout colorize('.', 'green')
    end
  end
end
