module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_entity

    def connect
      self.current_entity = find_verified_entity || reject_unauthorized_connection
    end

    private
      def find_verified_entity
        token = request.params[:token]
        return nil unless token

        payload = JwtToken.decode(token)

        if payload && payload["user_id"]
          User.find_by(id: payload["user_id"])
        elsif payload && payload["repairer_id"]
          Repairer.find_by(id: payload["repairer_id"])
        end
      rescue JWT::DecodeError
        nil
      end
  end
end
