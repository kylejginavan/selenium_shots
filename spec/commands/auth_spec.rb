require File.dirname(__FILE__) + '/../base'

module SeleniumShots::Command
	describe Auth do
		before do
			@cli = prepare_command(Auth)
		end

		it "reads api key from the api keys file" do
			sandbox = "/tmp/cli_spec_#{Process.pid}"
			File.open(sandbox, "w") { |f| f.write "api_key" }
			@cli.stub!(:api_key_file).and_return(sandbox)
			@cli.read_api_key.should == %w(api_key)
		end

		it "takes the apikey from the file" do
			@cli.stub!(:read_api_key).and_return(%w(api_key))
			@cli.api_key.should == %w(api_key)
		end

		it "asks for api_key when the file doesn't exist" do
			sandbox = "/tmp/cli_spec_#{Process.pid}"
			FileUtils.rm_rf(sandbox)
			@cli.stub!(:api_key_file).and_return(sandbox)
			@cli.should_receive(:ask_for_api_key).and_return(['u', 'p'])
			@cli.should_receive(:save_api_key)
			@cli.get_api_key.should == [ 'u', 'p' ]
		end

		it "writes the api_key to a file" do
			sandbox = "/tmp/cli_spec_#{Process.pid}"
			FileUtils.rm_rf(sandbox)
			@cli.stub!(:api_key_file).and_return(sandbox)
			@cli.stub!(:api_key_hash).and_return(['api_key'])
			@cli.should_receive(:set_api_key_permissions)
			@cli.write_api_key
			File.read(sandbox).should == "api_key\n"
		end

		it "sets ~/.selenium_shots/api_key to be readable only by the user" do
			sandbox = "/tmp/cli_spec_#{Process.pid}"
			FileUtils.rm_rf(sandbox)
			FileUtils.mkdir_p(sandbox)
			fname = "#{sandbox}/file"
			system "touch #{fname}"
			@cli.stub!(:api_key_file).and_return(fname)
			@cli.set_api_key_permissions
			File.stat(sandbox).mode.should == 040700
			File.stat(fname).mode.should == 0100600
		end

		it "writes api_key when the account is ok" do
			@cli.stub!(:api_key)
			@cli.should_receive(:write_api_key)
			@cli.should_receive(:get_api_key_from_host).and_return("api_key")
			@cli.save_api_key
		end

		it "save_api_key deletes the api_key when the resquest api_key is unauthorized" do
			@cli.stub!(:write_api_key)
			@cli.stub!(:retry_login?).and_return(false)
			@cli.should_receive(:get_api_key_from_host).and_raise(RestClient::Unauthorized)
			@cli.should_receive(:delete_api_key)
			lambda { @cli.save_api_key }.should raise_error(RestClient::Unauthorized)
		end


		it "asks for login again when not authorized, for three times" do
			@cli.stub!(:read_api_key)
			@cli.stub!(:write_api_key)
			@cli.stub!(:delete_api_key)
			@cli.should_receive(:get_api_key_from_host).exactly(3).times.and_raise(RestClient::Unauthorized)
			@cli.should_receive(:ask_for_api_key).exactly(4).times
			lambda { @cli.save_api_key }.should raise_error(RestClient::Unauthorized)
		end

		it "deletes the api_key file" do
			FileUtils.should_receive(:rm_f).with(@cli.api_key_file)
			@cli.delete_api_key
		end
	end
end

