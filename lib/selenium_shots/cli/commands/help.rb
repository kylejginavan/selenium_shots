module SeleniumShots::Command
	class Help < Base
		def index
			display usage
		end

		def usage
			usage = <<EOTXT
=== General Commands

 help                     # show this usage
 create [name]            # create file config for your app

=== Example story:

 rails myapp
 cd myapp
 (...make edits...)
 selenium_shots create example_one
EOTXT
		end
	end
end

