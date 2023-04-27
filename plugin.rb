# name: Genesys Cloud OAuth
# about: Log in to Discourse using Genesys Cloud authentication
# version: 0.5
# authors: Genesys
# url: https://github.com/purecloudlabs/discourse-purecloud-auth-plugin

require_relative 'auth/genesys_cloud_authenticator'
require_relative 'auth/genesys_cloud_usw2_authenticator'
require_relative 'auth/genesys_cloud_use2_authenticator'
require_relative 'auth/genesys_cloud_cac1_authenticator'
require_relative 'auth/genesys_cloud_euw1_authenticator'
require_relative 'auth/genesys_cloud_euw2_authenticator'
require_relative 'auth/genesys_cloud_euc1_authenticator'
require_relative 'auth/genesys_cloud_aps1_authenticator'
require_relative 'auth/genesys_cloud_apne1_authenticator'
require_relative 'auth/genesys_cloud_apne2_authenticator'
require_relative 'auth/genesys_cloud_apse2_authenticator'
require_relative 'auth/genesys_cloud_sae1_authenticator'

require_relative 'omniauth-genesys-cloud.rb'

#puts can be found on the docker container in /var/www/discourse/log/unicorn.stdout.log
puts 'Genesys Cloud - plugin loaded'

FRAME_WIDTH = 600
FRAME_HEIGHT = 400
LOGIN_MESSAGE = 'Authorizing with Genesys Cloud (make sure pop up blockers are not enabled)'

puts 'Genesys Cloud - Registering AuthProviders'

auth_provider :title => 'Sign in with Genesys Cloud US East (mypurecloud.com)',
            :authenticator => GenesysCloudAuthenticator.new,
            :message => LOGIN_MESSAGE,
            :frame_width => FRAME_WIDTH,
            :frame_height => FRAME_HEIGHT

auth_provider :title => 'Sign in with Genesys Cloud US East (Ohio) (use2.us-gov-pure.cloud)',
            :authenticator => GenesysCloudUse2Authenticator.new,
            :message => LOGIN_MESSAGE,
            :frame_width => FRAME_WIDTH,
            :frame_height => FRAME_HEIGHT               

auth_provider :title => 'Sign in with Genesys Cloud US West (usw2.pure.cloud)',
            :authenticator => GenesysCloudUsw2Authenticator.new,
            :message => LOGIN_MESSAGE,
            :frame_width => FRAME_WIDTH,
            :frame_height => FRAME_HEIGHT

auth_provider :title => 'Sign in with Genesys Cloud Canada (cac1.pure.cloud)',
            :authenticator => GenesysCloudCac1Authenticator.new,
            :message => LOGIN_MESSAGE,
            :frame_width => FRAME_WIDTH,
            :frame_height => FRAME_HEIGHT

auth_provider :title => 'Sign in with Genesys Cloud EU West (Ireland) (mypurecloud.ie)',
            :authenticator => GenesysCloudEuw1Authenticator.new,
            :message => LOGIN_MESSAGE,
            :frame_width => FRAME_WIDTH,
            :frame_height => FRAME_HEIGHT

auth_provider :title => 'Sign in with Genesys Cloud EU West (London) (euw2.pure.cloud)',
            :authenticator => GenesysCloudEuw2Authenticator.new,
            :message => LOGIN_MESSAGE,
            :frame_width => FRAME_WIDTH,
            :frame_height => FRAME_HEIGHT

auth_provider :title => 'Sign in with Genesys Cloud EU Central (mypurecloud.de)',
            :authenticator => GenesysCloudEuc1Authenticator.new,
            :message => LOGIN_MESSAGE,
            :frame_width => FRAME_WIDTH,
            :frame_height => FRAME_HEIGHT

auth_provider :title => 'Sign in with Genesys Cloud APAC (Mumbai) (aps1.pure.cloud)',
            :authenticator => GenesysCloudAps1Authenticator.new,
            :message => LOGIN_MESSAGE,
            :frame_width => FRAME_WIDTH,
            :frame_height => FRAME_HEIGHT

auth_provider :title => 'Sign in with Genesys Cloud APAC Northeast (Tokyo) (mypurecloud.jp)',
            :authenticator => GenesysCloudApne1Authenticator.new,
            :message => LOGIN_MESSAGE,
            :frame_width => FRAME_WIDTH,
            :frame_height => FRAME_HEIGHT

auth_provider :title => 'Sign in with Genesys Cloud APAC Northeast (Seoul) (apne2.pure.cloud)',
            :authenticator => GenesysCloudApne2Authenticator.new,
            :message => LOGIN_MESSAGE,
            :frame_width => FRAME_WIDTH,
            :frame_height => FRAME_HEIGHT

auth_provider :title => 'Sign in with Genesys Cloud APAC (Sydney) (mypurecloud.com.au)',
            :authenticator => GenesysCloudApse2Authenticator.new,
            :message => LOGIN_MESSAGE,
            :frame_width => FRAME_WIDTH,
            :frame_height => FRAME_HEIGHT

auth_provider :title => 'Sign in with Genesys Cloud South America (São Paulo) (sae1.pure.cloud)',
            :authenticator => GenesysCloudSae1Authenticator.new,
            :message => LOGIN_MESSAGE,
            :frame_width => FRAME_WIDTH,
            :frame_height => FRAME_HEIGHT

puts 'Genesys Cloud - plugin startup complete'