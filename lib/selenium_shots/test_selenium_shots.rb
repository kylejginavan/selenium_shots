require "test/unit"
require "rubygems"
require "selenium/client"
require 'active_support'
require 'active_support/test_case'
require 'ostruct'

#load config
SeleniumConfig = OpenStruct.new(YAML.load_file("#{RAILS_ROOT}/config/selenium_shots.yml"))
#

#activeresource models
class SeleniumTest < ActiveResource::Base
  self.site = "http://seleniumshots.com"
  self.user = SeleniumConfig.api_key
end

class SeleniumShots < ActionController::IntegrationTest

  attr_reader :browser, :agent
  cattr_accessor :expected_test_count

  if SeleniumConfig.mode == "remote"
    PICS_WINDOWS_PATH = "Z:"
    PICS_LINUX_PATH   = ''
    PICS_MACOS_PATH   = ''
    HOST = "staging.advisorshq.com"
    PORT = "8888"
  else
    HOST = "127.0.0.1"
    PORT = "4444"
  end

  def pid_file
    "/tmp/selenium_shots.pid"
  end

  def local_browsers
    ["*firefox3", "*iexplore", "*safari"]
  end

  def selected_browsers
    if SeleniumConfig.mode == "remote"
      SeleniumConfig.browsers
    else
      if defined?(SeleniumConfig.local_browser)
        [SeleniumConfig.local_browser]
     else
        [local_browsers.first]
     end
    end
  end

  def setup
    if(not self.class.expected_test_count)
      self.class.expected_test_count = (self.class.instance_methods.reject{|method| method[0..3] != 'test'}).length
      if  !File.exists?(pid_file) && SeleniumConfig.mode == "local"
        IO.popen("selenium_shots_local_server start 2>&1")
        sleep(2)
      end
    end
  end

  def teardown
    if((self.class.expected_test_count-=1) == 0)
      if File.exists?(pid_file) && SeleniumConfig.mode == "local"
        IO.popen("selenium_shots_local_server stop 2>&1")
      end
    end
  end

  def self.selenium_shot(description, &block)
    @@description = description
    @@group = (@group || "Default")
    test_name = "test_#{description.gsub(/\s+/,'_')}".to_sym
    defined = instance_method(test_name) rescue false
    raise "#{test_name} is already defined in #{self}" if defined
    if block_given?
     define_method(test_name) do
       run_in_all_browsers do |browser|
         instance_eval &block
       end
     end
    else
      define_method(test_name) do
        flunk "No implementation provided for #{name}"
      end
    end
  end

  def run_in_all_browsers(&block)
    browsers = (@selected_browser || selected_browsers)
    browsers.each do |browser_spec|
      begin
        run_browser(browser_spec, block)
        @error = nil
      rescue  => error
        @error = error.message
        if @error.match(/Failed to start new browser session/) && SeleniumConfig.mode == "local"
          @tmp_browsers ||= local_browsers
          @tmp_browsers.delete(browser_spec)
          @selected_browser  = [@tmp_browsers.shift]
          unless @selected_browser.empty?
            puts "The browser #{browser_spec} is not available, selenium_shots going to try with #{@selected_browser} browser"
            run_in_all_browsers(&block)
          end
        end
      end
      assert @error.nil?, "Expected zero failures or errors, but got #{@error}\n"
    end
  end

  def run_browser(browser_spec, block)
    @browser = Selenium::Client::Driver.new(
                                           :host => HOST,
                                           :port => PORT,
                                           :browser => browser_spec,
                                           :url => SeleniumConfig.default_browser_url,
                                           :timeout_in_second => 120)
    @browser.start_new_browser_session
    begin
      block.call(@browser)
    ensure
      save_test({:selenium_test_group_name => @@group, :selenium_test_name => @name,
                :description => @@description}) if SeleniumConfig.mode == "remote"
      @browser.close_current_browser_session
    end
  end

  def capture_screenshot_on(src)
    browser.window_focus
    browser.window_maximize
    sleep(2)
    if browser.browser_string.match(/XP/)
      browser.capture_entire_page_screenshot("#{PICS_WINDOWS_PATH}\\#{src}", "background=#FFFFFF")
    elsif browser.browser_string.match(/SnowLeopard/)
      browser.capture_entire_page_screenshot("#{PICS_MACOS_PATH}/#{src}", "background=#FFFFFF")
    elsif browser.browser_string.match(/Linux/)
      browser.capture_entire_page_screenshot("#{PICS_LINUX_PATH}/#{src}", "background=#FFFFFF")
    end
  end

  def save_test(params)
    src = "#{SeleniumConfig.application_name}_#{params[:selenium_test_group_name]}_#{params[:selenium_test_name]}_" +
          "#{browser.browser_string.gsub(/\s+/,"_").downcase}.png"

    capture_screenshot_on(src)

    SeleniumTest.create(:selenium_test_name => params[:selenium_test_name], :description => params[:description],
      :url => browser.location, :error_message => @error, :is_error => !@error.nil?, :environment => browser.browser_string,
      :selenium_test_group_name => params[:selenium_test_group_name], :application_name => SeleniumConfig.application_name)
  end
end

