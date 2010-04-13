module SeleniumShots::Command
	class App < Base
    def create
		  name    = args.shift.downcase.strip rescue nil
      if name
        api_key ||= SeleniumShots::Command.run_internal('auth:api_key', args)
		    display "Created #{name}" if make_config_file(name, api_key) == "y"
      else
        display "You need specify a name for your app. Run 'selenium_shots help' for usage information"
      end
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

