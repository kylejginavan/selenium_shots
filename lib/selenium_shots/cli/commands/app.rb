module SeleniumShots::Command
	class App < Base
    def create
		  name    = args.shift.downcase.strip rescue nil
      if name
        api_key ||= SeleniumShots::Command.run_internal('auth:api_key', args)
        if make_config_file(name, api_key) == "y"
		      display "Created #{name}\nYou can configurate selenium shots on config/selenium_shots.yml"
        end
      else
        display "You need specify a name for your app. Run 'selenium_shots help' for usage information"
      end
    end
	end
end

