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

  describe "GET /app/settings" do
    context 'when the user is a waiter' do
      it 'redirects with an authorization error' do
        user = create(:user, :waiter)
        sign_in user

        get "/app/settings"

        expect(response).to redirect_to(app_orders_path)
        expect(flash[:error]).to eq(I18n.t("app.errors.not_authorized"))
      end
    end

    context 'when the user is an owner' do
      it 'renders the coming soon page with a 200 status' do
        user = create(:user)
        sign_in user

        get "/app/settings"

        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "GET /app/users" do
    context 'when the user is a waiter' do
      it 'redirects with an authorization error' do
        user = create(:user, :waiter)
        sign_in user

        get "/app/users"

        expect(response).to redirect_to(app_orders_path)
        expect(flash[:error]).to eq(I18n.t("app.errors.not_authorized"))
      end
    end

    context 'when the user is an owner' do
      it 'renders the coming soon page with a 200 status' do
        user = create(:user)
        sign_in user

        get "/app/users"

        expect(response).to have_http_status(:ok)
      end
    end
  end
end
