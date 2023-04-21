# require_dependency 'auth/oauth2_authenticator.rb'

#https://github.com/discourse/discourse-oauth2-basic
class GenesysCloudApne2Authenticator < GenesysCloudAuthenticator
  def init_settings
      @region = "apne2.pure.cloud"
      @provider_name = "apne2"
      puts "Initializing Genesys Cloud OAuth settings"
      puts "Provider: " + @provider_name
      puts "Region: " + @region
  end

  def register_middleware(omniauth)
  	init_settings
  	
    omniauth.provider :genesysCloud,
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
