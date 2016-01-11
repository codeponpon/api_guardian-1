require 'rails-api'
require 'active_job'
require 'action_mailer'
require 'pundit'
require 'paranoia'
require 'rack/cors'
require 'kaminari'
require 'zxcvbn'
require 'phony'
require 'colorize'
require 'twilio-ruby'
require 'active_model_otp'
require 'active_model_serializers'
require 'acts_as_tenant'
require 'api_guardian/logs'
require 'api_guardian/helpers/helpers'
require 'api_guardian/configuration'
require 'api_guardian/validation'
require 'api_guardian/errors'
require 'api_guardian/engine'

require 'active_support/lazy_load_hooks'

module ApiGuardian
  ActiveSupport.run_load_hooks(:api_guardian_configuration, Configuration)

  module Concerns
    module ApiErrors
      autoload :Handler, 'api_guardian/concerns/api_errors/handler'
      autoload :Renderer, 'api_guardian/concerns/api_errors/renderer'
    end

    module ApiRequest
      autoload :Validator, 'api_guardian/concerns/api_request/validator'
    end

    module Models
      autoload :User, 'api_guardian/concerns/models/user'
      autoload :Role, 'api_guardian/concerns/models/role'
      autoload :Permission, 'api_guardian/concerns/models/permission'
      autoload :RolePermission, 'api_guardian/concerns/models/role_permission'
      autoload :Identity, 'api_guardian/concerns/models/identity'
      autoload :Organization, 'api_guardian/concerns/models/organization'
    end

    autoload :TwilioVoiceOtpHelper, 'api_guardian/concerns/twilio_voice_otp_helper'
  end

  module Stores
    autoload :Base, 'api_guardian/stores/base'
    autoload :UserStore, 'api_guardian/stores/user_store'
    autoload :RoleStore, 'api_guardian/stores/role_store'
    autoload :PermissionStore, 'api_guardian/stores/permission_store'
  end

  module Policies
    autoload :ApplicationPolicy, 'api_guardian/policies/application_policy'
    autoload :PermissionPolicy, 'api_guardian/policies/permission_policy'
    autoload :RolePolicy, 'api_guardian/policies/role_policy'
    autoload :UserPolicy, 'api_guardian/policies/user_policy'
  end

  module Validators
    autoload :PasswordLengthValidator, 'api_guardian/validators/password_length_validator'
    autoload :PasswordScoreValidator, 'api_guardian/validators/password_score_validator'
  end

  module Strategies
    module Registration
      module_function

      def self.find(provider)
        strategy = Base.providers[provider.to_sym]
        fail ApiGuardian::Errors::InvalidRegistrationProvider, "Could not find provider '#{provider}'" unless strategy
        strategy
      end
    end
  end

  module Jobs
    autoload :SendOtp, 'api_guardian/jobs/send_otp'
    autoload :SendSms, 'api_guardian/jobs/send_sms'
  end

  module Mailers
    autoload :Mailer, 'api_guardian/mailers/mailer'
  end

  class << self
    attr_accessor :current_request
    attr_writer :configuration

    def zxcvbn_tester
      @zxcvbn_tester ||= ::Zxcvbn::Tester.new
    end

    def twilio_client
      unless configuration.enable_2fa
        fail Configuration::ConfigurationError.new('2FA is not enabled!')
      end
      @twilio_client ||= ::Twilio::REST::Client.new configuration.twilio_id, configuration.twilio_token
    end
  end

  module_function

  def configuration
    @configuration ||= Configuration.new
  end

  def configure
    yield(configuration)
  end

  def logger
    @logger ||= ApiGuardian::Logging::Logger.new(STDOUT)
  end
end

require 'api_guardian/strategies/authentication/authentication'
require 'api_guardian/strategies/registration/base'
require 'api_guardian/strategies/registration/email'
require 'api_guardian/strategies/registration/digits'
