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
      File.dirname(__FILE__) + '/config/selenium_shots.yml'
    end

    def inside_rails_app?
      File.exists?('config/environment.rb')
    end

	end

end

