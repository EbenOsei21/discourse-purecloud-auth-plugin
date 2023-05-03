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

  def fetch_user_details(token)
    user_json_url = "https://api.#{@region}/api/v2/users/me?expand=organization"
    bearer_token = "Bearer #{token}"
    connection = Faraday.new { |f| f.adapter FinalDestination::FaradayAdapter }
    headers = { "Authorization" => bearer_token, "Accept" => "application/json" }
    user_json_response = connection.run_request(:get, user_json_url, nil, headers)

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

  def match_by_email
    true
  end

  def find_user_by_email(auth_token)
    email = auth_token.dig(:info, :email)
    User.find_by_email(email)
  end

  def after_authenticate(auth, existing_account: nil)
    association =
      UserAssociatedAccount.find_or_initialize_by(
        provider_name: auth[:provider],
        provider_uid: @provider_name,
    )

    if existing_account && (association.user.nil? || existing_account.id != association.user_id)
      association.user = existing_account
    end

    if match_by_email && association.user.nil? && (user = find_user_by_email(auth))
      UserAssociatedAccount.where(user: user, provider_name: auth[:provider]).destroy_all # Destroy existing associations for the new user
      association.user = user
    end

    association.info = auth[:info] || {}
    association.credentials = auth[:credentials] || {}
    association.extra = auth[:extra] || {}

    association.last_used = Time.zone.now

    # Save to the DB. Do this even if we don't have a user - it might be linked up later in after_create_account
    association.save!

	  result = Auth::Result.new
  	
  	begin
	    token = auth['credentials']['token']
	    user_details = fetch_user_details(token)

	    result.name = user_details[:name]
	    result.username = user_details[:username]
	    result.email = user_details[:email]

	    # Genesys Cloud doesn't have a concept of a validated email
	    result.email_valid = false

	    # current_info = ::PluginStore.get(@provider_name, "#{@provider_name}_user_#{user_details[:user_id]}")
	    # if current_info
	    #   result.user = User.where(id: current_info[:user_id]).first
      #   puts "user exits"
      #   puts result.user
	    # end

	    result.extra_data = {
        purecloud_user_id: user_details[:user_id],
        purecloud_org_id: user_details[:org_id]
	    }

      result.user = association.user

			####### BEGIN EMPLOYEE SYNC
	    #Special logic for the prod genesys org
	    if(result.extra_data[:purecloud_org_id] == GENESYS_PROD_ORG_ID)
        result.email_valid = true
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
    auth_token = auth_result[:extra_data]
    association =
      UserAssociatedAccount.find_or_initialize_by(
        provider_name: auth_token[:provider],
        provider_uid: auth_token[:uid],
      )
    association.user = user
    association.save!
    auth_result.apply_associated_attributes!
    # ::PluginStore.set(@provider_name, "#{@provider_name}_user_#{auth[:extra_data][:purecloud_user_id]}", {user_id: user.id })
  end
end