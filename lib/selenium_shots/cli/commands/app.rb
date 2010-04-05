module SeleniumShots::Command
	class App < Base
    def create
#      unless File.exists?(config_file)
#        FileUtils.copy('selenium_shots.yml', 'config/selenium_shots.yml')
#      end
		  name    = args.shift.downcase.strip rescue nil
		  selenium_shots.create(name)
		  display "Created #{name}"
    end

    def list
			list = selenium_shots.list
			if list.size > 0
				display list.join("\n")
			else
				display "You have no apps."
			end
		end
	end
end

