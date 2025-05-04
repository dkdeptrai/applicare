module ApiAuthentication
  extend ActiveSupport::Concern

  def authenticate_entity
    @current_user = authenticate_user
    @current_repairer = authenticate_repairer unless @current_user

    head :unauthorized unless current_entity
  end

  def current_entity
    @current_user || @current_repairer
  end

  private

  def authenticate_user
    authenticate_with_token("user_id")
  end

  def authenticate_repairer
    authenticate_with_token("repairer_id")
  end

  def authenticate_with_token(id_key)
    return nil unless token_present?

    payload = JwtToken.decode(token)
    return nil unless payload && payload[id_key]

    if id_key == "user_id"
      User.find_by(id: payload[id_key])
    else
      Repairer.find_by(id: payload[id_key])
    end
  rescue JWT::DecodeError
    nil
  end

  def token
    request.headers["Authorization"]&.split&.last
  end

  def token_present?
    !!token
  end

  def current_user
    @current_user
  end

  def current_repairer
    @current_repairer
  end
end
