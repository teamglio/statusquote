require 'sinatra'
require 'rest-client'
require 'json'

get '/' do
	@quote = RestClient.get 'http://www.iheartquotes.com/api/v1/random?source=oneliners'
	@mixup_ad = RestClient.get 'http://serve.mixup.hapnic.com/9766793'
	erb :quote
end