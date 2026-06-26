require 'rails_helper'

RSpec.describe "App navbar", type: :request do
  describe "GET /app/orders" do
    context 'when the user is an owner' do
      it 'shows orders and products navigation' do
        user = create(:user, role: :owner)
        sign_in user

        get "/app/orders"

        expect(response.body).to include(app_orders_path)
        expect(response.body).to include(app_product_categories_path)
      end
    end

    context 'when the user is an admin' do
      it 'shows orders and products navigation' do
        user = create(:user, :admin)
        sign_in user

        get "/app/orders"

        expect(response.body).to include(app_orders_path)
        expect(response.body).to include(app_product_categories_path)
      end
    end

    context 'when the user is a waiter' do
      it 'shows orders navigation but not products navigation' do
        user = create(:user, :waiter)
        sign_in user

        get "/app/orders"

        expect(response.body).to include(app_orders_path)
        expect(response.body).not_to include(app_product_categories_path)
      end
    end
  end
end
