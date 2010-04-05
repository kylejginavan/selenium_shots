#if defined? RAILS_ROOT
#  require File.expand_path(RAILS_ROOT,"config","environment.rb")
#end

#module SeleniumShots
#  class ActiveSupport::TestCase

#    SeleniumConfig = OpenStruct.new(YAML.load_file("#{RAILS_ROOT}/config/selenium.yml")[RAILS_ENV])

#    attr_reader :browser, :agent

#    def self.selenium_shot(description, &block)
#      #set vars
#      @group ||= "default group"
#      @name  ||= "default name"
#      @description = description
#      #
#      test_name = "test_#{description.gsub(/\s+/,'_')}".to_sym
#      defined = instance_method(test_name) rescue false
#      raise "#{test_name} is already defined in #{self}" if defined
#      if block_given?
#        define_method(test_name, &block)
#      else
#        define_method(test_name) do
#          flunk "No implementation provided for #{name}"
#        end
#      end
#    end

#    def select_browser(browser, url = nil)
#      @browser = Selenium::Client::Driver.new \
#          :host => SeleniumConfig.hub_url,
#          :port => SeleniumConfig.hub_port,
#          :browser => browser,
#          :url => url || SeleniumConfig.default_browser_url,
#          :timeout_in_second => 60,
#          :highlight_located_element => true
#      @browser.start_new_browser_session
#    end

#    def hover_click(locator)
#      browser.mouse_over locator
#      browser.click locator
#      browser.focus locator
#    end

#    def open_and_wait(url)
#      browser.open url
#      browser.wait_for_page_to_load "30000"
#    end

#    def run_test(&proc)
#      begin
#        proc.call
#        @error = nil
#      rescue => e
#        @error = e.message
#      end
#    end

#    def teardown
#      save_test ({:selenium_test_group_name => @group, :selenium_test_name => @name,
#                  :description => @description})
#      browser.close_current_browser_session
#    end

#    def capture_screenshot_on(src)
#      browser.window_focus
#      browser.window_maximize
#      sleep(2)
#      if browser.browser_string.match(/XP/)
#        browser.capture_entire_page_screenshot("#{SeleniumConfig.pics_windows_path}\\#{src}", "background=#FFFFFF")
#      elsif browser.browser_string.match(/SnowLeopard/)
#        browser.capture_entire_page_screenshot("#{SeleniumConfig.pics_macos_path}/#{src}", "background=#FFFFFF")
#      elsif browser.browser_string.match(/Linux/)
#        browser.capture_entire_page_screenshot("#{SeleniumConfig.pics_linux_path}/#{src}", "background=#FFFFFF")
#      end
#    end

#    def save_test(params)
#      src = "#{SeleniumConfig.bucket_name}_#{params[:selenium_test_group_name]}_#{params[:selenium_test_name]}_" +
#            "#{browser.browser_string.gsub(" ","_").downcase}.png"
#      capture_screenshot_on(src)

#      SeleniumTest.create(:selenium_test_name => params[:selenium_test_name], :description => params[:description],
#        :url => browser.location, :error_message => @error, :is_error => !@error.nil?, :environment => browser.browser_string,
#        :selenium_test_group_name => params[:selenium_test_group_name], :bucket_name => SeleniumConfig.bucket_name)
#    end

#  end
#end

