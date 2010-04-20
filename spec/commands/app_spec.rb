require File.dirname(__FILE__) + '/../base'

module SeleniumShots::Command
	describe App do
		before do
			@cli  = prepare_command(App)
			@auth = prepare_command(Auth)
		end

		it "creates with a name" do
			@cli.stub!(:args).and_return([ 'myapp' ])
      @cli.stub!(:selenium_shots_api_key).and_return("api_key")
      @cli.should_receive(:make_config_file)
			@cli.create
		end

		it "cant creates app without a name" do
			@cli.stub!(:args).and_return([ nil ])
      @cli.stub!(:selenium_shots_api_key)
      @cli.should_not_receive(:make_config_file)
			@cli.create
		end

	end
end

