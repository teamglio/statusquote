require 'dotenv'
require 'firebase'
require 'nestful'
require_relative 'mxit_api.rb'

class RandomQuoteBroadcast

	def self.broadcast
		Dotenv.load 
		#users = ['m41162520002', 'm47975403002']

		Firebase.base_uri = "https://glio-mxit-users.firebaseio.com/#{ENV['MXIT_APP_NAME']}/"
		users = JSON.load(Firebase.get('').response.body).keys
		
		quote = Nestful.get 'http://www.iheartquotes.com/api/v1/random?source=oneliners'
		
		users.each_slice(500) do |users_slice|
			begin
			MxitAPI.send_message(users_slice.join(','), '*Quote of the day*: ' + quote)
			rescue
				next
			end
		end
	end

end