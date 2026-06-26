require 'rails_helper'

RSpec.describe "App::Home", type: :request do
  describe "GET /app" do
    context 'when the user is not authenticated' do
      it 'redirects to the sign-in page' do
        get "/app"

        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when the user is authenticated' do
      it 'renders successfully with a 200 status' do
        user = create(:user)
        sign_in user

        get "/app"

        expect(response).to have_http_status(:ok)
      end
    end
  end
end
