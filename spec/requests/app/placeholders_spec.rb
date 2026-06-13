require 'rails_helper'

RSpec.describe "App::Placeholders", type: :request do
  describe "GET /app/orders" do
    context 'when the user is not authenticated' do
      it 'redirects to the sign-in page' do
        get "/app/orders"

        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when the user is authenticated' do
      it 'renders the coming soon page with a 200 status' do
        user = create(:user)
        sign_in user

        get "/app/orders"

        expect(response).to have_http_status(:ok)
      end
    end
  end
end
