module ApiGuardian
  class UsersController < ApiController
    def add_phone
      resource_store.add_phone(@resource, add_phone_params)
      head :no_content
    end

    def verify_phone
      unless resource_store.verify_phone(@resource, verify_phone_params)
        return phone_verification_failed
      end

      render json: @resource
    end

    protected

    def includes
      ['role']
    end

    def create_params
      [:first_name, :last_name, :email, :role_id, :password, :password_confirmation]
    end

    def update_params
      create_params
    end

    def add_phone_params
      params.require(:data).require(:attributes).permit(:password, :phone_number)
    end

    def verify_phone_params
      params.require(:data).require(:attributes).permit(:otp)
    end
  end
end
