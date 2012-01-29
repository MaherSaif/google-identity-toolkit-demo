require 'uri'
# require 'restclient' # https://github.com/archiloque/rest-client

class SessionsController < ApplicationController
	GOOGLE_DEVELOPER_KEY = Rails.env.development? ? "AIzaSyDGn4SeG7MPo9NB8sV0PPAMsnfBiaQ7iSQ" : "AIzaSyCnqgWR93wn2uCSvRf8cp1nRtTjRBtosLg"

  def new
  end

  def create
  	user = login(params[:email], params[:password])
  	if user
  		redirect_back_or_to root_url, notice: "Logged in!"
  	else
  		flash.now.alert = "Email/Password doesn't match"
  		render :new
  	end
  end

  def idp_callback
  	api_params = {
		  'requestUri' => request.url,
		  'postBody' => request.post? ? request.raw_post : URI.parse(request.url).query
		}

		api_url = "https://www.googleapis.com/identitytoolkit/v1/relyingparty/" +
		          "verifyAssertion?key=#{GOOGLE_DEVELOPER_KEY}"

		assertion = get_assertion(api_url, api_params)
		logger.debug("Assersion: #{assertion.inspect}")

		if assertion && user = User.find_by_email(assertion["verifiedEmail"])
				auto_login(user)
				redirect_to action: :success
		else
			redirect_to action: :failed
		end
  end

  def destroy
  	logout
  	redirect_to root_url, notice: "Logged Out!"
  end

  def success
  end

  def failed
  end


	private

	def get_assertion(url, params)
	  begin
	  	logger.debug("Before_sending_request")
	    api_response = ::RestClient.post(url, params.to_json, :content_type => :json )
	    verified_assertion = JSON.parse(api_response)
	  	logger.debug("After_sending_request")
	    logger.debug("API_RESPONSE: #{verified_assertion.inspect}")
	    raise StandardError unless verified_assertion.include? "verifiedEmail"
	    verified_assertion
	  rescue StandardError => error
	  	logger.debug(error.inspect)
	    nil
	  end
	end



end
