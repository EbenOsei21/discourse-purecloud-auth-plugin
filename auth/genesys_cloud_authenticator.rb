##GENESYS_PROD_ORG_ID = "845c9858-a978-4313-b8ed-2a85b289cffb"

GENESYS_PROD_ORG_ID = "8d6f6281-c096-4dab-b194-a6f1667d7dd4"

#https://github.com/discourse/discourse-oauth2-basic
class GenesysCloudAuthenticator < Auth::ManagedAuthenticator
  def init_settings
    @region = "mypurecloud.com"
    @provider_name = "use1"
    puts "Initializing Genesys Cloud OAuth settings"
    puts "Provider: " + @provider_name
    puts "Region: " + @region
  end

  def name
   @provider_name
  end

  def enabled?
    true
  end

  def register_middleware(omniauth)
  	init_settings

    omniauth.provider :genesysCloud,
                      name: name,
                      setup: 
                      lambda {|env|
                      	puts "Registering middleware for Genesys Cloud OAuth provider: " + @provider_name
                      	puts "Client ID: " + SiteSetting.genesys_cloud_client_id

                        opts = env['omniauth.strategy'].options
                        opts[:client_id] = SiteSetting.genesys_cloud_client_id
                        opts[:client_secret] = SiteSetting.genesys_cloud_client_secret

                        opts[:client_options] = {
                          authorize_url: "https://login.#{@region}/oauth/authorize",
                          token_url: "https://login.#{@region}/oauth/token"
                        }
                      }
  end

  def log(info)
    Rails.logger.warn("OAuth2 Debugging: #{info}")
  end

  def fetch_user_details(token)
    log("fetch user got called")
    puts "fetch user happend"
    user_json_url = "https://api.#{@region}/api/v2/users/me?expand=organization"
    bearer_token = "Bearer #{token}"
    connection = Faraday.new { |f| f.adapter FinalDestination::FaradayAdapter }
    headers = { "Authorization" => bearer_token, "Accept" => "application/json" }
    user_json_response = connection.run_request(:get, user_json_url, nil, headers)

    log("user_json_response: #{user_json_response.inspect}")

    puts user_json_response.inspect

    user_json = JSON.parse(user_json_response.body)

    result = {
      :name     => user_json['name'],
      :email    => user_json['email'],
      :user_id => user_json["id"],
      :username => user_json["name"],
      :org_id => user_json["organization"]["id"]
    }
    puts "sucessfully got user data"
    result
  end

  def basic_auth_header
    "Basic " +
      Base64.strict_encode64("#{SiteSetting.genesys_cloud_client_id}:#{SiteSetting.genesys_cloud_client_secret}")
  end

  def after_authenticate(auth)
	  result = Auth::Result.new
  	
  	begin
	    token = auth['credentials']['token']
	    user_details = fetch_user_details(token)

	    result.name = user_details[:name]
	    result.username = user_details[:username]
	    result.email = user_details[:email]

	    # Genesys Cloud doesn't have a concept of a validated email
	    result.email_valid = false

	    current_info = ::PluginStore.get(@provider_name, "#{@provider_name}_user_#{user_details[:user_id]}")
	    if current_info
	      result.user = User.where(id: current_info[:user_id]).first
	    end
      puts result.user
      log(result.user)
	    result.extra_data = {
        purecloud_user_id: user_details[:user_id],
        purecloud_org_id: user_details[:org_id]
	    }

			####### BEGIN EMPLOYEE SYNC
	    #Special logic for the prod genesys org
	    if(result.extra_data[:purecloud_org_id] == GENESYS_PROD_ORG_ID)
        puts "Sync happend"
	    	query = "SELECT user_id FROM email_tokens WHERE email='" + result.email.downcase + "' ORDER BY id DESC LIMIT 1"
	    	email_user_object = ActiveRecord::Base.connection.exec_query(query)
        puts email_user_object
        log(email_user_object)
	    	if email_user_object != nil
	    		result.user = User.where(id: email_user_object.getvalue(0,0)).first
	    	end
        puts result.user
        log(result.user)
	    	if result.user != nil
	    		result.email_valid = true
          log(result.email_valid)
	    	end
	    end
			####### END EMPLOYEE SYNC
	  rescue => e
	  	puts "Exception Class: #{ e.class.name }"
		  puts "Exception Message: #{ e.message }"
		  puts "Exception Backtrace: #{ e.backtrace }"
	  end

	  result
  end

  def after_create_account(user, auth)
    ::PluginStore.set(@provider_name, "#{@provider_name}_user_#{auth[:extra_data][:purecloud_user_id]}", {user_id: user.id })
  end
end