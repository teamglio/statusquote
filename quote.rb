require 'sinatra'
require 'rest_client'
require 'json'

get '/' do
	@quote = 'http://www.iheartquotes.com/api/v1/random?source=oneliners'
	@mixup_ad = RestClient.get 'http://serve.mixup.hapnic.com/9392697'
	erb :quote
end