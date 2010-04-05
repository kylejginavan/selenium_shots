require 'rubygems'
require 'rexml/document'
require 'rest_client'
require 'uri'
require 'time'

class SeleniumShots::Client

	attr_reader :host, :user, :password

	def initialize(user, password, host='seleniumshots.heroku.com')
		@user = user
		@password = password
		@host = host
	end

	def create(name)
	  puts "send request for create app"
	end

  def list
    #get list app from selenium_shots
    []
  end


end

