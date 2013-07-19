require 'sinatra'
require 'rest-client'
require 'json'
require 'dotenv'
require 'firebase'
require 'stathat'
require_relative 'lib/statusquote.rb'

configure do
	Dotenv.load if settings.development?
	Firebase.base_uri = "https://glio-mxit-users.firebaseio.com/#{ENV['MXIT_APP_NAME']}/"	
end

get '/' do
	create_user unless get_user	
	@quote = RestClient.get 'http://www.iheartquotes.com/api/v1/random?source=oneliners'
	@mixup_ad = RestClient.get 'http://serve.mixup.hapnic.com/9766793'
	StatHat::API.ez_post_count('statusquote - quotes requested', 'emile@silvis.co.za', 1)	
	erb :quote
end

helpers do
	def get_user
		mxit_user = MxitUser.new(request.env)
		data = Firebase.get(mxit_user.user_id).response.body
		data == "null" ? nil : data
	end
	def create_user
		mxit_user = MxitUser.new(request.env)
		Firebase.set(mxit_user.user_id, {:date_joined => Time.now})
	end
end