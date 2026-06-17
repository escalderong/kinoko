require 'rails_helper'

RSpec.describe "App::Navbar", type: :request do
  describe "GET /app/orders" do
    context "when the user is an owner" do
      it "renders navbar links and the modal turbo frame" do
        user = create(:user)
        sign_in user

        get "/app/orders"

        expect(response.body).to include(I18n.t("app.nav.orders"))
        expect(response.body).to include(I18n.t("app.nav.tables"))
        expect(response.body).to include(I18n.t("app.nav.products"))
        expect(response.body).to include('<turbo-frame id="modal">')
      end

      it "shows the Settings and Users links" do
        user = create(:user)
        sign_in user

        get "/app/orders"

        expect(response.body).to include(I18n.t("app.nav.settings"))
        expect(response.body).to include(I18n.t("app.nav.users"))
      end

      it "shows exactly two items in the avatar dropdown: Preferences and Logout" do
        user = create(:user)
        sign_in user

        get "/app/orders"

        expect(response.body).to include(I18n.t("app.nav.preferences"))
        expect(response.body).to include(I18n.t("app.nav.logout"))
      end
    end

    context "when the user is a waiter" do
      it "does not show the Settings or Users links" do
        user = create(:user, :waiter)
        sign_in user

        get "/app/orders"

        expect(response.body).not_to include(I18n.t("app.nav.settings"))
        expect(response.body).not_to include(I18n.t("app.nav.users"))
      end

      it "still shows the Orders, Tables, and Products links" do
        user = create(:user, :waiter)
        sign_in user

        get "/app/orders"

        expect(response.body).to include(I18n.t("app.nav.orders"))
        expect(response.body).to include(I18n.t("app.nav.tables"))
        expect(response.body).to include(I18n.t("app.nav.products"))
      end
    end
  end
end
