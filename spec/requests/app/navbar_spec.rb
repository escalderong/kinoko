require 'rails_helper'

RSpec.describe "App navbar", type: :request do
  describe "GET /app/orders" do
    context 'when the user is an owner' do
      it 'shows orders and products navigation' do
        user = create(:user, role: :owner)
        sign_in user

        get "/app/orders"

        expect(response.body).to include(app_orders_path)
        expect(response.body).to include(app_products_categories_path)
      end

      it 'shows the tables navigation' do
        user = create(:user, role: :owner)
        sign_in user

        get "/app/orders"

        expect(response.body).to include(app_tables_path)
      end
    end

    context 'when the user is an admin' do
      it 'shows orders and products navigation' do
        user = create(:user, :admin)
        sign_in user

        get "/app/orders"

        expect(response.body).to include(app_orders_path)
        expect(response.body).to include(app_products_categories_path)
      end

      it 'shows the tables navigation' do
        user = create(:user, :admin)
        sign_in user

        get "/app/orders"

        expect(response.body).to include(app_tables_path)
      end
    end

    context 'when the user is a waiter' do
      it 'shows orders navigation but not products navigation' do
        user = create(:user, :waiter)
        sign_in user

        get "/app/orders"

        expect(response.body).to include(app_orders_path)
        expect(response.body).not_to include(app_products_categories_path)
      end

      it 'shows the tables navigation' do
        user = create(:user, :waiter)
        sign_in user

        get "/app/orders"

        expect(response.body).to include(app_tables_path)
      end
    end

    context 'when the user is an owner' do
      it 'shows the settings navigation with a tables submenu' do
        user = create(:user, role: :owner)
        sign_in user

        get "/app/orders"

        expect(response.body).to include(I18n.t("app.nav.settings"))
        expect(response.body).to include(app_settings_tables_path)
        expect(response.body).to include(I18n.t("app.nav.tables"))
      end
    end

    context 'when the user is a waiter' do
      it 'does not show the settings navigation' do
        user = create(:user, :waiter)
        sign_in user

        get "/app/orders"

        expect(response.body).not_to include(I18n.t("app.nav.settings"))
      end
    end
  end
end
