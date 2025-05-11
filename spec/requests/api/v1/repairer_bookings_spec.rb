require 'rails_helper'

RSpec.describe "Api::V1::RepairerBookings", type: :request do
  let(:repairer) { create(:repairer) }
  let(:user) { create(:user) }
  let(:booking) { create(:booking, repairer: repairer, user: user, start_time: Time.current.beginning_of_day + 9.hours) } # 9 AM
  let(:valid_headers) do
    {
      'Authorization' => "Bearer #{generate_repairer_jwt(repairer)}",
      'Content-Type' => 'application/json'
    }
  end

  describe "GET /api/v1/repairer/bookings" do
    it "returns only the repairer's bookings" do
      # Create bookings
      create(:booking, repairer: repairer, start_time: Time.current.beginning_of_day + 10.hours)
      create(:booking, repairer: repairer, start_time: Time.current.beginning_of_day + 13.hours)
      create(:booking, repairer: repairer, start_time: Time.current.beginning_of_day + 15.hours)
      create(:booking, repairer: create(:repairer), start_time: Time.current.beginning_of_day + 11.hours)

      get "/api/v1/repairer/bookings", headers: valid_headers
      expect(response).to have_http_status(:ok)
      expect(json_response.size).to eq(3)
    end

    context "with filters" do
      it "filters by status" do
        create(:booking, repairer: repairer, status: "confirmed", start_time: Time.current.beginning_of_day + 12.hours)
        create(:booking, repairer: repairer, status: "pending", start_time: Time.current.beginning_of_day + 14.hours)

        get "/api/v1/repairer/bookings?status=confirmed", headers: valid_headers
        expect(response).to have_http_status(:ok)
        expect(json_response.size).to eq(1)
        expect(json_response.first["status"]).to eq("confirmed")
      end

      it "filters by date range" do
        start_date = Date.today
        end_date = Date.today + 1.week
        get "/api/v1/repairer/bookings?start_date=#{start_date}&end_date=#{end_date}", headers: valid_headers
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "GET /api/v1/repairer/bookings/:id" do
    it "returns the booking details" do
      get "/api/v1/repairer/bookings/#{booking.id}", headers: valid_headers
      expect(response).to have_http_status(:ok)
      expect(json_response["id"]).to eq(booking.id)
    end

    it "returns 404 for non-existent booking" do
      get "/api/v1/repairer/bookings/999999", headers: valid_headers
      expect(response).to have_http_status(:not_found)
    end

    it "returns 404 for another repairer's booking" do
      other_booking = create(:booking, repairer: create(:repairer), start_time: Time.current.beginning_of_day + 16.hours)
      get "/api/v1/repairer/bookings/#{other_booking.id}", headers: valid_headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "PATCH /api/v1/repairer/bookings/:id" do
    let(:valid_params) do
      {
        booking: {
          status: "confirmed"
        }
      }
    end

    it "updates the booking status" do
      patch "/api/v1/repairer/bookings/#{booking.id}", params: valid_params.to_json, headers: valid_headers
      expect(response).to have_http_status(:ok)
      expect(json_response["status"]).to eq("confirmed")
    end

    it "returns 422 for invalid status" do
      invalid_params = { booking: { status: "invalid_status" } }
      patch "/api/v1/repairer/bookings/#{booking.id}", params: invalid_params.to_json, headers: valid_headers
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "returns 404 for another repairer's booking" do
      other_booking = create(:booking, repairer: create(:repairer), start_time: Time.current.beginning_of_day + 17.hours)
      patch "/api/v1/repairer/bookings/#{other_booking.id}", params: valid_params.to_json, headers: valid_headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /api/v1/repairer/bookings/:id/notes" do
    let(:valid_params) do
      {
        note: "Customer requested early morning appointment"
      }
    end

    let(:invalid_params) do
      {
        note: ""
      }
    end

    it "adds a note to the booking" do
      expect {
        post "/api/v1/repairer/bookings/#{booking.id}/notes", params: valid_params.to_json, headers: valid_headers
      }.to change { booking.reload.repairer_note }.from(nil).to(valid_params[:note])

      expect(response).to have_http_status(:ok)
      expect(json_response["repairer_note"]).to eq(valid_params[:note])
    end

    it "returns 422 for empty note" do
      post "/api/v1/repairer/bookings/#{booking.id}/notes", params: invalid_params.to_json, headers: valid_headers
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "returns 404 for another repairer's booking" do
      other_booking = create(:booking, repairer: create(:repairer), start_time: Time.current.beginning_of_day + 18.hours)
      post "/api/v1/repairer/bookings/#{other_booking.id}/notes", params: valid_params.to_json, headers: valid_headers
      expect(response).to have_http_status(:not_found)
    end
  end
end
