require_dependency 'auth/oauth2_authenticator.rb'

#https://github.com/discourse/discourse-oauth2-basic
class GenesysCloudEuw1Authenticator < GenesysCloudAuthenticator
  def init_settings
      @region = "mypurecloud.ie"
      @provider_name = "genesys_cloud_euw1"
      puts "Initializing Genesys Cloud OAuth settings"
      puts "Provider: " + @provider_name
      puts "Region: " + @region
  end

  def register_middleware(omniauth)
  	init_settings
  	
    omniauth.provider :genesyscloud,
                      name: @provider_name,
                      setup: lambda {|env|
                      	puts "Registering middleware for Genesys Cloud OAuth provider: " + @provider_name
                      	puts "Client ID: " + SiteSetting.genesys_cloud_client_id

                        opts = env['omniauth.strategy'].options
                        opts[:client_id] = SiteSetting.genesys_cloud_client_id
                        opts[:client_secret] = SiteSetting.genesys_cloud_client_secret

                        opts[:client_options] = {
                          site: "https://login.#{@region}/"
                        }
                      }
  end
end
