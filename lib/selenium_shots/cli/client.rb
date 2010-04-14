require 'rubygems'
require 'rest_client'
require 'uri'
require 'time'

class SeleniumShots::Client

	attr_reader :host, :api_key

	def initialize(api_key, host='seleniumshots.heroku.com')
		@api_key  = api_key
		@host     = host
	end

  def list
    #get list app from selenium_shots
    []
  end

############
	def resource(uri)
		RestClient::Resource.new("http://#{host}", api_key)[uri]
	end

	def get(uri)
		resource(uri).get
	end

	def post(uri)
		resource(uri).post
	end

	def put(uri)
		resource(uri).put
	end

	def delete(uri)
		resource(uri).delete
	end
end

