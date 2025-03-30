require 'rails_helper'

RSpec.describe "Sessions", type: :request do
  describe "GET /session/new" do
    it "returns a successful response" do
      get new_session_path
      expect(response).to be_successful
    end
  end

  describe "POST /session" do
    context "with valid login credentials and verified email" do
      let(:user) { create(:user, :verified, password: 'password123') }
      let(:valid_params) { { email_address: user.email_address, password: 'password123' } }

      it "creates a new session" do
        expect {
          post session_path, params: valid_params
        }.to change(Session, :count).by(1)
      end

      it "redirects to the root path" do
        allow_any_instance_of(SessionsController).to receive(:after_authentication_url).and_return(root_url)
        post session_path, params: valid_params
        expect(response).to redirect_to(root_url)
      end

      it "sets a session cookie" do
        post session_path, params: valid_params
        # Just verify that a cookie was set
        expect(response.cookies).to have_key('session_id')
      end
    end

    context "with valid login credentials but unverified email" do
      let(:user) { create(:user, :unverified, password: 'password123') }
      let(:valid_params) { { email_address: user.email_address, password: 'password123' } }

      it "does not create a new session" do
        expect {
          post session_path, params: valid_params
        }.not_to change(Session, :count)
      end

      it "redirects to the login page with an alert" do
        post session_path, params: valid_params
        expect(response).to redirect_to(new_session_path)
        expect(flash[:alert]).to include("Please verify your email")
      end
    end

    context "with invalid credentials" do
      let(:invalid_params) { { email_address: 'wrong@example.com', password: 'wrongpassword' } }

      it "does not create a new session" do
        expect {
          post session_path, params: invalid_params
        }.not_to change(Session, :count)
      end

      it "redirects to the login page with an error message" do
        post session_path, params: invalid_params
        expect(response).to redirect_to(new_session_path)
        expect(flash[:alert]).to include("Try another email address or password")
      end
    end
  end

  describe "DELETE /session" do
    let(:user) { create(:user, :verified) }
    let(:session) { user.sessions.create!(ip_address: '127.0.0.1', user_agent: 'test') }

    before do
      # Simulate a logged in user by directly mocking the Current module and controller methods
      current_double = double(session: session)
      allow(Current).to receive(:session).and_return(session)
      allow_any_instance_of(SessionsController).to receive(:authenticated?).and_return(true)
      allow_any_instance_of(SessionsController).to receive(:find_session_by_cookie).and_return(session)
    end

    it "destroys the session" do
      expect {
        delete session_path
      }.to change(Session, :count).by(-1)
    end

    it "clears the session cookie" do
      delete session_path
      expect(cookies[:session_id]).to be_nil
    end

    it "redirects to the login page" do
      delete session_path
      expect(response).to redirect_to(new_session_path)
    end
  end
end
