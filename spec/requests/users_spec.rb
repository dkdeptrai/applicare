require 'rails_helper'

RSpec.describe "Users", type: :request do
  describe "GET /users/new" do
    it "returns a successful response" do
      get new_user_path
      expect(response).to be_successful
    end
  end

  describe "POST /users" do
    context "with valid parameters" do
      let(:valid_attributes) {
        {
          user: {
            email_address: "test@example.com",
            password: "password123",
            password_confirmation: "password123"
          }
        }
      }

      it "creates a new User" do
        expect {
          post users_path, params: valid_attributes
        }.to change(User, :count).by(1)
      end

      it "sends a verification email" do
        # Use a spy to test that send_verification_email is called
        user_spy = spy('User')
        allow(User).to receive(:new).and_return(user_spy)
        allow(user_spy).to receive(:save).and_return(true)

        post users_path, params: valid_attributes
        expect(user_spy).to have_received(:send_verification_email)
      end

      it "redirects to the login page" do
        post users_path, params: valid_attributes
        expect(response).to redirect_to(new_session_path)
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) {
        {
          user: {
            email_address: "",
            password: "password",
            password_confirmation: "different"
          }
        }
      }

      it "does not create a new User" do
        expect {
          post users_path, params: invalid_attributes
        }.to change(User, :count).by(0)
      end

      it "renders the new template" do
        post users_path, params: invalid_attributes
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /verify_email/:token" do
    context "with a valid token" do
      let(:user) { create(:user, :unverified) }

      it "verifies the user's email" do
        get verify_email_path(token: user.email_verification_token)
        user.reload
        expect(user.email_verified).to be true
        expect(user.email_verification_token).to be_nil
      end

      it "redirects to the login page with a success message" do
        get verify_email_path(token: user.email_verification_token)
        expect(response).to redirect_to(new_session_path)
        expect(flash[:notice]).to include("Email verified successfully")
      end
    end

    context "with an expired token" do
      let(:user) { create(:user, :unverified, email_verification_sent_at: 25.hours.ago) }

      it "sends a new verification email" do
        expect do
          get verify_email_path(token: user.email_verification_token)
        end.to change { user.reload.email_verification_sent_at }
      end

      it "redirects to the login page with an alert" do
        # No need to stub send_verification_email, we're testing the redirect behavior
        get verify_email_path(token: user.email_verification_token)
        expect(response).to redirect_to(new_session_path)
        expect(flash[:alert]).to include("Verification link expired")
      end
    end

    context "with an invalid token" do
      it "redirects to the login page with an error message" do
        get verify_email_path(token: "invalid-token")
        expect(response).to redirect_to(new_session_path)
        expect(flash[:alert]).to include("Invalid verification link")
      end
    end
  end

  describe "GET /users/:id" do
    context "when authenticated" do
      let(:user) { create(:user, :verified) }

      before do
        # Simulate a logged in user by mocking the authenticated? method and setting Current.user
        allow_any_instance_of(UsersController).to receive(:authenticated?).and_return(true)
        session = double(user: user)
        allow(Current).to receive(:session).and_return(session)
      end

      it "returns a successful response" do
        get user_path(user)
        expect(response).to be_successful
      end
    end

    context "when not authenticated" do
      let(:user) { create(:user, :verified) }

      it "redirects to login" do
        get user_path(user)
        expect(response).to redirect_to(new_session_path)
      end
    end
  end
end
