require "test/unit"
require "rubygems"
require "selenium/client"
require "selenium-webdriver"
require 'active_support'
require 'active_support/test_case'
require 'ostruct'

#load config
SeleniumConfig = OpenStruct.new(YAML.load_file("#{Rails.root.to_s}/config/selenium_shots.yml"))
#

#activeresource models
class SeleniumTest < ActiveResource::Base
  self.site = "http://seleniumshots.com"
  self.user = SeleniumConfig.api_key
end

class SeleniumShots < ActionController::IntegrationTest

  attr_reader :driver, :agent, :take_screenshot
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
    ["firefox", "ie", "chrome"]
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
  
  def self.core_test(description, take_screenshot = true, &block)
    @@group = (@group || "Default")
    test_name = "test_#{description.gsub(/\s+/,'_')}".to_sym
    defined = instance_method(test_name) rescue false
    raise "#{test_name} is already defined in #{self}" if defined
    if block_given?
      define_method(test_name) do
        @description     = description
        @take_screenshot = take_screenshot
        run_in_all_browsers do
          instance_eval &block
        end
      end
    else
      define_method(test_name) do
        flunk "No implementation provided for #{name}"
      end
    end
  end

  def self.selenium_test(description, &block)
    core_test(description, nil, &block)
  end

  def self.selenium_shot(description, &block)
    core_test(description, true, &block)
  end

  def run_in_all_browsers(&block)
    @error = nil
    browsers = (@selected_browser || selected_browsers)
    browsers.each do |browser_spec|
      begin
        run_webdriver(browser_spec, block)
      rescue  => error
        @driver.quit if @driver
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
    end
    assert @error.nil?, "Expected zero failures or errors, but got #{@error}\n"
  end
  
  def run_webdriver(browser_spec, block)
    
    client = Selenium::WebDriver::Remote::Http::Default.new
    client.timeout = 20 # seconds
    
    if SeleniumConfig.mode == "local"
      if /(firefox)/i.match(browser_spec)
        profile = Selenium::WebDriver::Firefox::Profile.new
        profile.native_events = false
        @driver = Selenium::WebDriver.for(:firefox, :profile => profile, :http_client => client)
      elsif /(chrome)/i.match(browser_spec)
        @driver = Selenium::WebDriver.for(:chrome, :http_client => client)
      elsif /(ie)/i.match(browser_spec)
        @driver = Selenium::WebDriver.for(:ie, :http_client => client)
      end
    else
      caps = nil
      if /(firefox)/i.match(browser_spec)
        caps = WebDriver::Remote::Capabilities.firefox
      elsif /(chrome)/i.match(browser_spec)
        caps = WebDriver::Remote::Capabilities.chrome
      elsif /(ie)/i.match(browser_spec)
        caps = WebDriver::Remote::Capabilities.internet_explorer
      elsif /(safari)/i.match(browser_spec)
        caps = WebDriver::Remote::Capabilities.safari
      elsif /(htmlunit)/i.match(browser_spec)
        caps = WebDriver::Remote::Capabilities.htmlunit
        caps.javascript_enabled = true
      end

      @driver = Selenium::WebDriver.for(:remote, :desired_capabilities => caps, :http_client => client) if caps
    end
    
    @driver.manage.timeouts.implicit_wait = 2 #seconds
    @driver.navigate.to SeleniumConfig.default_browser_url

    begin
      block.call
    rescue  => error
      @error = error.message
      puts error.message
      puts error.backtrace
    ensure
      save_test({:selenium_test_group_name => @@group, :selenium_test_name => @name,
                :description => @description}) if SeleniumConfig.mode == "remote"
      @driver.quit
    end 
  end

  def capture_screenshot_on(src)
    browser.window_focus
    browser.window_maximize
    sleep(2)
    if @driver.browser.to_s.match(/XP/)
      @driver.capture_entire_page_screenshot("#{PICS_WINDOWS_PATH}\\#{src}", "background=#FFFFFF")
    elsif @driver.browser.to_s.match(/SnowLeopard/)
      @driver.capture_entire_page_screenshot("#{PICS_MACOS_PATH}/#{src}", "background=#FFFFFF")
    elsif @driver.browser.to_s.match(/Linux/)
      @driver.capture_entire_page_screenshot("#{PICS_LINUX_PATH}/#{src}", "background=#FFFFFF")
    end
  end

  def save_test(params)
    src = "#{SeleniumConfig.application_name}_#{params[:selenium_test_group_name]}_#{params[:selenium_test_name]}_" +
           "#{@driver.browser.to_s.gsub(/\s+/,"_").downcase}.png"

    capture_screenshot_on(src)

    SeleniumTest.create(:selenium_test_name => params[:selenium_test_name], :description => params[:description],
      :url => @driver.current_url, :error_message => @error, :is_error => !@error.nil?, :environment => @driver.browser.to_s,
      :selenium_test_group_name => params[:selenium_test_group_name], :application_name => SeleniumConfig.application_name)
  end
end
