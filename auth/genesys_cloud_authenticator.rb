require_dependency 'omniauth-genesys-cloud.rb'

GENESYS_PROD_ORG_ID = "845c9858-a978-4313-b8ed-2a85b289cffb"

#https://github.com/discourse/discourse-oauth2-basic
class ::GenesysCloudAuthenticator < Auth::ManagedAuthenticator
  @provider_name = "use1"
  @region = "mypurecloud.com"

  def name
    "genesysCloud"
  end

  def enabled?
    true
  end

  def init_settings
      @region = "mypurecloud.com"
      @provider_name = "use1"
      puts "Initializing Genesys Cloud OAuth settings"
      puts "Provider: " + @provider_name
      puts "Region: " + @region
  end

  def register_middleware(omniauth)
  	init_settings

    omniauth.provider :genesysCloud,
                      name: name,
                      setup: 
                      lambda {|env|
                      	puts "Registering middleware for Genesys Cloud OAuth provider: " + @provider_name
                      	puts "Client ID: " + SiteSetting.genesys_cloud_client_id

                        #opts = env['omniauth.strategy'].options
                        opts[:client_id] = SiteSetting.genesys_cloud_client_id
                        opts[:client_secret] = SiteSetting.genesys_cloud_client_secret

                        opts[:client_options] = {
                          authorize_url: "https://login.#{@region}/oauth/authorize",
                          token_url: "https://login.#{@region}/oauth/token"
                        }
                      }
  end

  def fetch_user_details(token)
    user_json_url = "https://api.#{@region}/api/v2/users/me?expand=organization"
    user_json = JSON.parse(open(user_json_url, 'Authorization' => "Bearer #{token}" ).read)
    puts user_json

    result = {
      :name     => user_json['name'],
      :email    => user_json['email'],
      :user_id => user_json["id"],
      :username => user_json["name"],
      :org_id => user_json["organization"]["id"]
    }

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

	    result.extra_data = {
        purecloud_user_id: user_details[:user_id],
        purecloud_org_id: user_details[:org_id]
	    }

			####### BEGIN EMPLOYEE SYNC
	    #Special logic for the prod genesys org
	    if(result.extra_data[:purecloud_org_id] == GENESYS_PROD_ORG_ID)
	    	query = "SELECT user_id FROM email_tokens WHERE email='" + result.email.downcase + "' ORDER BY id DESC LIMIT 1"
	    	email_user_object = ActiveRecord::Base.exec_sql(query)

	    	if email_user_object != nil
	    		result.user = User.where(id: email_user_object.getvalue(0,0)).first
	    	end

	    	if result.user != nil
	    		result.email_valid = true
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