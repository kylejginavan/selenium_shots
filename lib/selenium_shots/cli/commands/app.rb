module SeleniumShots::Command
	class App < Base
    def create
		  name    = args.shift.downcase.strip rescue nil
      api_key ||= SeleniumShots::Command.run_internal('auth:api_key', args)
      make_config_file(name, api_key)
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

