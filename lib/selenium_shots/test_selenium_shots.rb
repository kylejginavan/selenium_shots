require "test/unit"
require "rubygems"
require "selenium/client"
require 'active_support'
require 'active_support/test_case'
require 'ostruct'


#load config
SeleniumConfig = OpenStruct.new(YAML.load_file("#{RAILS_ROOT}/config/selenium_shots.yml"))
#
ENV["RAILS_ENV"] = "test"

#activeresource models
class SeleniumTest < ActiveResource::Base
  self.site = "http://127.0.0.1:3000"
  self.user = SeleniumConfig.api_key
end

class SeleniumShotsTest < ActiveSupport::TestCase

  attr_reader :browser, :agent

  if SeleniumConfig.mode == "remote"
    PICS_WINDOWS_PATH = "Z:"
    PICS_LINUX_PATH   = ''
    PICS_MACOS_PATH   = ''
    HOST = "staging.advisorshq.com"
    PORT = "8888"
  else
    exec("selenium_shots_local_server start") unless File.exists?("/tmp/selenium_shots.pid")
    PICS_WINDOWS_PATH = (SeleniumConfig.pics_windows_path || "")
    PICS_LINUX_PATH   = (SeleniumConfig.pics_linux_path   || "")
    PICS_MACOS_PATH   = (SeleniumConfig.pics_macos_path   || "")
    HOST = "127.0.0.1"
    PORT = "4444"
  end

    def self.selenium_shot(description, &block)
    @@description = description
    test_name = "test_#{description.gsub(/\s+/,'_')}".to_sym
    defined = instance_method(test_name) rescue false
    raise "#{test_name} is already defined in #{self}" if defined
    if block_given?
     define_method(test_name, block) do
       block.call
     end
    else
      define_method(test_name) do
        flunk "No implementation provided for #{name}"
      end
    end
  end

  def run_in_all_browsers(&block)
      SeleniumConfig.browsers.each do |browser_spec|
        begin
          run_browser(browser_spec, block)
          @error = nil
        rescue => error
          @error = error.message
        end
         assert @error.nil?, "Expected zero failures or errors, but got #{@error}\n"
      end
  end

  def run_browser(browser_spec, block)
    @browser = Selenium::Client::Driver.new(
                                           :host => "127.0.0.1",
                                           :port => 4444,
                                           :browser => browser_spec,
                                           :url => SeleniumConfig.default_browser_url,
                                           :timeout_in_second => 120)
    @browser.start_new_browser_session
    begin
      block.call(@browser)
    ensure
      @browser.close_current_browser_session
      save_test ({:selenium_test_group_name => @group, :selenium_test_name => @name,
                :description => @@description}) if SeleniumConfig.mode == "remote"

    end
  end



  def select_browser(browser, url = nil)
    @browser = Selenium::Client::Driver.new \
        :host => HOST,
        :port => PORT,
        :browser => browser,
        :url => url || SeleniumConfig.default_browser_url,
        :timeout_in_second => 60,
        :highlight_located_element => true
    @browser.start_new_browser_session
  end

  def hover_click(locator)
    browser.mouse_over locator
    browser.click locator
    browser.focus locator
  end

  def open_and_wait(url)
    browser.open url
    browser.wait_for_page_to_load "30000"
  end

  def run_test(&proc)
    begin
      proc.call
      @error = nil
    rescue => e
      @error = e.message
    end
  end

#  def setup
#    select_browser(BROWSER, "http://www.google.com")
#  end

#  def teardown
#    save_test ({:selenium_test_group_name => @group, :selenium_test_name => @name,
#                :description => @@description})
#    browser.close_current_browser_session
#  end

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

