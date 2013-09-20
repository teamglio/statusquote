require 'rest-client'
require 'json'
require 'base64'

class MxitAPI

	def self.get_app_token(scope)
		response = RestClient.post 'https://auth.mxit.com/token', {:grant_type => 'client_credentials', :scope => URI.encode(scope)}, {:content_type => 'application/x-www-form-urlencoded', :authorization => 'Basic ' + Base64.encode64(ENV['MXIT_KEY'] + ':' + ENV['MXIT_SECRET']).to_s.gsub!("\n","")}
		JSON.load(response)['access_token']
	end

	def self.request_access(scope, redirect_url)
		'https://auth.mxit.com/authorize?response_type=code&client_id=' + ENV['MXIT_KEY'] + '&redirect_uri=' + URI.encode(redirect_url) + '&scope=' + URI.encode(scope) + '&state=your_state'
	end

	def self.get_user_token(code, scope, redirect_url)
		response = RestClient.post 'https://auth.mxit.com/token', {:grant_type => 'authorization_code', :code => URI.encode(code), :redirect_uri => URI.encode(redirect_url)}, {:content_type => 'application/x-www-form-urlencoded', :authorization => 'Basic ' + Base64.encode64(ENV['MXIT_KEY'] + ':' + ENV['MXIT_SECRET']).to_s.gsub!("\n","")}
		JSON.load(response)['access_token']
	end

	def self.get_user_profile(mxit_user_id)
		response = RestClient.get 'http://api.mxit.com/user/profile/' + mxit_user_id, :accept => 'application/json', :authorization => 'Bearer ' + get_app_token('profile/public') do |response, request, result|
			case response.code
			when 200
				JSON.load(response)
			else
				nil
			end
		end
	end

	def self.upload_gallery_image(mxit_user_id, folder, filename, file, code, redirect_url)
		response = RestClient.post 'http://api.mxit.com/user/media/file/' + URI.encode(folder) + '?fileName=' + filename, file, {:authorization => 'Bearer ' + get_user_token(code, 'content/write', redirect_url)}
	end

	#Limits: http://code.mxit.com/forum/showthread.php?t=571&highlight=message+limits
	#1. Message maximum length -- Recommended maximum length is 1000 chars or less.
	#2. Maximum recipients -- Recommend no more than 500 recipients in a Messaging API call.
	#3. Minimum time between requests -- It depends on how many concurrent threads you use. We don't limit developers at the moment, but if somebody causes too much load on the server we will implement rate-limit them as needed. If you have 1 thread, then you can make another request as soon as the current one finishes..	

	#Example of message with links: Hey I thought you may like {0}! 
	def self.send_message(recipient_mxit_user_ids, message, link_app_name=nil, link_text=nil)
		unless link_app_name.nil? && link_text.nil?
			link = [{:CreateTemporaryContact => true, :TargetService => link_app_name, :Text => link_text}]
		else
			link = nil
		end
		request = {:ContainsMarkup => true, :From => ENV['MXIT_APP_NAME'], :To => recipient_mxit_user_ids, :Spool => true, :Body => message, :Links => link}
		response = RestClient.post 'http://api.mxit.com/message/send/', request.to_json, :authorization => 'Bearer ' + get_app_token('message/send'), :content_type => 'application/json'
	end

	def self.set_avatar(code, file, redirect_url)
		response = RestClient.post 'http://api.mxit.com/user/avatar', file, {:authorization => 'Bearer ' + get_user_token(code, 'avatar/write', redirect_url), :content_type => 'image/png'}		
	end
	

end