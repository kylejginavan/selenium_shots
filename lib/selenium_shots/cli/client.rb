require 'rubygems'
require 'rexml/document'
require 'rest_client'
require 'uri'
require 'time'

class SeleniumShots::Client

	attr_reader :host, :api_key

	def initialize(api_key, host='127.0.0.1:3000')
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

	def xml(raw)   # :nodoc:
		REXML::Document.new(raw)
	end

	def escape(value)  # :nodoc:
		escaped = URI.escape(value.to_s, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
		escaped.gsub('.', '%2E') # not covered by the previous URI.escape
	end


end

