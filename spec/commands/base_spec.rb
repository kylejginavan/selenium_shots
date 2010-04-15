require File.dirname(__FILE__) + '/../base'

module SeleniumShots::Command
	describe Base do
		before do
			@args = [1, 2]
			@base = Base.new(@args)
			@base.stub!(:display)
		end

		it "initializes the selenium_shots client with the Auth command" do
			SeleniumShots::Command.should_receive(:run_internal).with('auth:client', @args)
			@base.selenium_shots
		end

    it "creates or overwrite the selenium_shots yml file" do
			sandbox = "/tmp/cli_spec_selenium_shots"
			@base.stub!(:config_file).and_return(sandbox)
      @base.should_receive(:ask_for_config_file).and_return("y")
      @base.make_config_file("myapp", "api_key")
      File.exists?(sandbox) == true
    end

    it "not overwrite the selenium_shots yml file" do
			sandbox = "/tmp/cli_spec_selenium_shots"
			@base.stub!(:config_file).and_return(sandbox)
      @base.should_receive(:ask_for_config_file).and_return("n")
      @base.make_config_file("myapp", "api_key")
      File.exists?(sandbox) == false
    end

    it "return the config file name" do
      @base.config_file.should == 'config/selenium_shots.yml'
    end

	end
end

