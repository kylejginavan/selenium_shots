require File.expand_path(File.dirname(__FILE__) + "/../config/environment")

class Google < SeleniumShots

  @group = "Google"

  selenium_shot "should search on google" do
    @name = "selenium shots"
    browser.open "/"
    browser.wait_for_page_to_load "30000"
    browser.type "q", "Selenium Shots"
    browser.click "btnG"
  end
end

