module Clash
  class Test
    include Helpers

    attr_accessor :title

    def initialize(options={})
      @test_failures = []
      @options  = options
      @options['config'] ||= {}
      @options['dir'] ||= '.'
      @cleanup = []
    end

    def run
      Dir.chdir(@options['dir']) do
        clear_cache
        system_cmd(@options['before'])
        config
        build if @options['build']
        unless @options['build_only']
          compare
          enforce_missing
          system_cmd(@options['after'])
        end
        cleanup_config
      end
      print_result
      results
    end

    def clear_cache
      if File.exist? '.jekyll-metadata'
        FileUtils.rm '.jekyll-metadata'
      end
    end

    def config
      @options['config'].each do |name, file|
        if name != 'jekyll'
          config_plugin(name, file)
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

    def config_plugin(name, file)
      copy_config(file, "#{plugins_path}/#{name}/config.yml")
    end

    def plugins_path
      jekyll_site.plugin_manager.plugins_path.first
    end

    def jekyll_site
      require 'jekyll'
      config = {}
      Array(@options['config']['jekyll'] || '_config.yml').each do |c| 
        config.merge!SafeYAML.load_file(c)
      end
      Jekyll.logger.log_level = :error
      site = Jekyll::Site.new(Jekyll.configuration(config))
      Jekyll.logger.log_level = :info
      site
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
      options = "--trace"

      if config = @options['config']['jekyll']
        options << " --config #{Array(config).join(',')}"
      end

      system "jekyll build #{options}"
    end

    def system_cmd(cmds)
      cmds = Array(cmds)
      cmds.each {|cmd| 
        if @options['tasks'].include?(cmd)
          system_cmd(@options['tasks'][cmd])
        else
          system(cmd) 
        end
      }
    end

    def compare
      Array(@options['compare']).each do |files|
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
      Array(@options['enforce_missing']).each do |file|
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
