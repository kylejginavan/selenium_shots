require File.dirname(__FILE__) + '/../base'

module SeleniumShots::Command
  describe Server do
    before do
      @cli = prepare_command(Server)
    end

    it "run local instance of selenium server" do
      @cli.start
      File.exists?("/tmp/selenium_shots.pid") == true
    end

    it "stop local instance of selenium server" do
      @cli.stop
      File.exists?("/tmp/selenium_shots.pid") == false
    end


  end
end

