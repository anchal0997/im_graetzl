class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]

  # GET /users/registrierung
  def new
    if params[:graetzl_id].present?
      build_resource({})
      self.resource.graetzl = Graetzl.find(params[:graetzl_id])
      self.resource.address = Address.from_feature(params[:feature])
      respond_with self.resource
    else
      render "address_form"
    end
  end

  def set_address
    @address = Address.from_feature(params[:feature])
    @graetzls = @address ? @address.graetzls : []

    if @graetzls.size == 1
      redirect_to new_registration_url(graetzl_id: @graetzls.first.id, feature: params[:feature])
    else
      render "graetzls"
    end
  end

  def graetzls
  end

  protected

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up) do |u|
      u.permit(
        :username,
        :first_name, :last_name,
        :email,
        :password,
        :terms_and_conditions,
        :newsletter,
        :role,
        :avatar, :remove_avatar,
        :graetzl_id,
        address_attributes: [
          :street_name,
          :street_number,
          :zip,
          :city,
          :coordinates])
    end
  end

end
