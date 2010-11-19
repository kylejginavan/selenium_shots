require File.expand_path(File.dirname(__FILE__) + "/../config/environment")

class Google < SeleniumShots

  @group = "Google"

  selenium_shot "should search on google" do
    @name = "Google search"
    element = driver.find_element(:name, 'q')
    element.send_keys "Hello WebDriver!"
    element.submit
  end
end

