require 'rubygems'
require 'spec'
require 'fileutils'

require File.dirname(__FILE__) + '/../lib/selenium_shots/cli/init'

%w(app auth base server).each { |c| require c }

def prepare_command(klass)
	command = klass.new([])
	command.stub!(:display)
	command
end

