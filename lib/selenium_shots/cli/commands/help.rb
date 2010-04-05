module SeleniumShots::Command
	class Help < Base
		def index
			display usage
		end

		def usage
			usage = <<EOTXT
=== General Commands

 help                         # show this usage
 create [name]                # create bucket for your app
 list                         # list your apps
=== Example story:

 rails myapp
 cd myapp
 (...make edits...)
 selenium_shots create
EOTXT
		end
	end
end

