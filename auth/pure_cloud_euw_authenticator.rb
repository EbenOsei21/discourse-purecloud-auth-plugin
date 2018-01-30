require_dependency 'auth/oauth2_authenticator.rb'

#https://github.com/discourse/discourse-oauth2-basic
class PureCloudEuwAuthenticator < PureCloudAuthenticator
  def init_settings
      @region = "mypurecloud.ie"
      @provider_name = "purecloud_euw"
      puts "Initializing PureCloud OAuth settings"
      puts "Provider: " + @provider_name
      puts "Region: " + @region
  end

  def register_middleware(omniauth)
    @region = "mypurecloud.com"
    @provider_name = "purecloud"
    omniauth.provider :purecloud,
                      name: @provider_name,
                      setup: lambda {|env|
                      	puts "Registering middleware for PureCloud OAuth provider: " + @provider_name
                      	puts "Client ID: " + SiteSetting.purecloud_euw_client_id

                        opts = env['omniauth.strategy'].options
                        opts[:client_id] = SiteSetting.purecloud_euw_client_id
                        opts[:client_secret] = SiteSetting.purecloud_euw_client_secret

                        opts[:client_options] = {
                          site: "https://login.#{@region}/"
                        }
                      }
  end
end
