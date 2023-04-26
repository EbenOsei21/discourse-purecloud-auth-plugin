require "omniauth/strategies/oauth2"

class ::OmniAuth::Strategies::GenesysCloud < ::OmniAuth::Strategies::OAuth2
  option :name, "genesysCloud"
  option :authorize_options, [:scope]

  def callback_url
    Discourse.base_url_no_prefix + script_name + callback_path
  end
end