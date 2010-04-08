module SeleniumShots::Command
	class Auth < Base
		attr_accessor :api_key_hash

		def client
			@client ||= init_selenium_shots
		end

		def init_selenium_shots
			SeleniumShots::Client.new(api_key)
		end

		def api_key
      get_api_key
		end

    def get_api_key_from_host
      RestClient.post 'http://127.0.0.1:3000/selenium_tests/get_api_key', :user_session => { :login => @api_key_hash[0],
                                                                                    :password => @api_key_hash[1]}
    end

		def api_key_file
			"#{home_directory}/.selenium_shots/api_key"
		end

		def get_api_key
			return if @api_key_hash
			unless @api_key_hash = read_api_key
				@api_key_hash = ask_for_api_key
				save_api_key
			end
			@api_key_hash
		end

		def read_api_key
			if File.exists? api_key_file
				return File.read(api_key_file).split("\n")
			end
		end

		def echo_off
			system "stty -echo"
		end

		def echo_on
			system "stty echo"
		end

		def ask_for_api_key
			puts "Enter your SeleniumShots Account"

			print "Login: "
			user = ask

			print "Password: "
			password = running_on_windows? ? ask_for_password_on_windows : ask_for_password

			[ user, password ]
		end

		def ask_for_password_on_windows
			require "Win32API"
			char = nil
			password = ''

			while char = Win32API.new("crtdll", "_getch", [ ], "L").Call do
				break if char == 10 || char == 13 # received carriage return or newline
				if char == 127 || char == 8 # backspace and delete
					password.slice!(-1, 1)
				else
					password << char.chr
				end
			end
			puts
			return password
		end

		def ask_for_password
			echo_off
			password = ask
			puts
			echo_on
			return password
		end

		def save_api_key
			begin
        @api_key_hash = get_api_key_from_host
				write_api_key
			rescue RestClient::Unauthorized => e
				delete_api_key
				raise e unless retry_login?
				display "\nAuthentication failed"
				@api_key_hash = ask_for_api_key
				@client = init_selenium_shots
				retry
			rescue Exception => e
				delete_api_key
				raise e
			end
		end

		def retry_login?
			@login_attempts ||= 0
			@login_attempts += 1
			@login_attempts < 3
		end

		def write_api_key
			FileUtils.mkdir_p(File.dirname(api_key_file))
			File.open(api_key_file, 'w') do |f|
				f.puts self.api_key_hash
			end
			set_api_key_permissions
		end

		def set_api_key_permissions
			FileUtils.chmod 0700, File.dirname(api_key_file)
			FileUtils.chmod 0600, api_key_file
		end

		def delete_api_key
			FileUtils.rm_f(api_key_file)
		end
	end
end

