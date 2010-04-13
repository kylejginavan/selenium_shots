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


  def ask_for_config_file
    if File.exists?(config_file)
			print "The config file exists, do you want overwrite this? (y/n): "
			ask
    else
      "y"
    end
  end

    def make_config_file(name, api_key)
      overwrite_or_create_file = ask_for_config_file
      if overwrite_or_create_file == "y"
        config_file_hash = <<EOFILE
#remote way
api_key: "#{api_key}"
mode: "remote" # "local" for run test locally
default_browser_url: "http://www.myapp.com"
application_name: "#{name}"
browsers:
    - IE8 on XP          #browser for remote way
    - Firefox3.6 on XP   #browser for remote way
#   - "*firefox3" #browser for local way
EOFILE
			File.open(config_file, 'w') do |f|
				f.puts config_file_hash
			end
    end
    overwrite_or_create_file
  end

    def inside_rails_app?
      File.exists?('config/environment.rb')
    end

	end

end

