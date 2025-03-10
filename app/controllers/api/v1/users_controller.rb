module Api
  module V1
    class UsersController < BaseController
      def show
        user = User.find(params[:id])
        rernder json: user
      end
    end
  end
end
