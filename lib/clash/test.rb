module Clash
  class Test
    include Helpers

    attr_accessor :title

    def initialize(options={})
      @test_failures = []
      @options  = options
      @options['config'] ||= {}
      @cleanup = []
    end

    def run
      system_cmd(@options['before'])
      config
      build if @options['build']
      compare
      enforce_missing
      system_cmd(@options['after'])
      cleanup_config
      print_result
      results
    end

    def config
      @options['config'].each do |name, file|
        case name
        when 'jekyll' then next
        when 'octopress' then config_octopress(file)
        else config_plugin(name, file)
        end
      end
    end

    def cleanup_config
      @cleanup.each do |file|
        if File.extname(file) == '.bak'
          FileUtils.mv(file, file.sub(/\.bak$/,''), force: true)
        else
          FileUtils.rm(file)
        end
      end
    end

    def config_octopress(file)
      copy_config(file, '_octopress.yml')
    end

    def config_plugin(name, file)
      copy_config(file, "_plugins/#{name}/config.yml")
    end

    def copy_config(file, target)
      if File.exists?(file)
        # Make a backup of existing files first
        #
        if File.exists?(target)
          FileUtils.mv target, "#{target}.bak"
          @cleanup << "#{target}.bak"
        else
          @cleanup << target
        end

        FileUtils.mkdir_p(File.dirname(target))
        FileUtils.cp file, target
      else
        @test_failures << "Config file: #{file} cannot be found.\n"
      end
    end

    def build
      if jekyll_config = @options['config']['jekyll']
        configs = default_array(jekyll_config).join(',')
        system("jekyll build --trace --config #{configs}")
      else
        system("jekyll build --trace")
      end
    end

    def system_cmd(cmds)
      cmds = default_array(cmds)
      cmds.each {|cmd| system(cmd) }
    end

    def compare
      default_array(@options['compare']).each do |files|
        f = files.gsub(',',' ').split

        differ = Diff.new(f.first, f.last, context: @options['context'])
        diff = differ.diff

        @test_failures.concat differ.test_failures

        diff.each do |title, diff|
          @test_failures << "#{title}\n#{diff}\n"
        end
      end
    end

    def enforce_missing
      default_array(@options['enforce_missing']).each do |file|
        if File.exists?(file)
          message = yellowit("\nFile #{file} shouldn't exist.") + "\n  But it does!"
          @test_failures << message
        end
      end
    end

    def print_result
      if @test_failures.empty?
        print_pass
      else
        print_fail
      end
    end

    def results
      if !@test_failures.empty?
        @test_failures.unshift(test_title)
        @test_failures
      end
    end

    def test_title
      title = boldit("#{@options['index']})")
      title << " #{@options['title']}" unless @options['title'].nil?
      <<-HERE
#{title}
========================================================
HERE
    end

  end
end
