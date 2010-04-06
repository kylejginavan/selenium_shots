require 'fileutils'

module SeleniumShots::Command
	class Base
		attr_accessor :args
		def initialize(args)
			@args = args
		end

		def selenium_shots
			@selenium_shots ||= SeleniumShots::Command.run_internal('auth:client', args)
		end

		def display(msg, newline=true)
			newline ? puts(msg) : print(msg)
		end

		def ask
			gets.strip
		end

		def shell(cmd)
			`#{cmd}`
		end

		def home_directory
			running_on_windows? ? ENV['USERPROFILE'] : ENV['HOME']
		end

		def running_on_windows?
			RUBY_PLATFORM =~ /mswin32/
		end

    def config_file
      'config/selenium_shots.yml'
    end

    def make_config_file(name, api_key)
 			FileUtils.rm_f(config_file) if File.exists?(config_file)
      config_file_hash = <<EOFILE
  api_key: "#{api_key}"
  hub_url: 'url'
  hub_port: 'port'
  default_browser_url: 'default url'
  pics_linux_path:   'set path'
  pics_windows_path: 'set path'
  pics_macos_path:   'set path'
  bucket_name: "#{name}"
  browsers:
    - *firefox3
EOFILE
			File.open(config_file, 'w') do |f|
				f.puts config_file_hash
			end
    end

    def inside_rails_app?
      File.exists?('config/environment.rb')
    end

	end

end

