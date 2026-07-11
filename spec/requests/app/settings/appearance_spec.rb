require "rails_helper"

RSpec.describe "App::Settings::Appearance", type: :request do
  describe "GET /app/settings/appearance" do
    context "when the user is not authenticated" do
      it "redirects to the sign-in page" do
        get "/app/settings/appearance"

        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when the user is a waiter" do
      it "redirects with an authorization error" do
        user = create(:user, :waiter)
        sign_in user

        get "/app/settings/appearance"

        expect(response).to redirect_to(app_orders_path)
        expect(flash[:error]).to eq(I18n.t("app.errors.not_authorized"))
      end
    end

    context "when the user is an admin" do
      it "redirects with an authorization error" do
        user = create(:user, :admin)
        sign_in user

        get "/app/settings/appearance"

        expect(response).to redirect_to(app_orders_path)
        expect(flash[:error]).to eq(I18n.t("app.errors.not_authorized"))
      end
    end

    context "when the user is an owner" do
      it "renders a theme-controller card for every theme and pre-checks the current one" do
        user = create(:user)
        user.commerce.update!(theme: "dracula")
        sign_in user

        get "/app/settings/appearance"

        expect(response).to have_http_status(:ok)

        doc = Nokogiri::HTML(response.body)
        radios = doc.css('input.theme-controller[name="commerce[theme]"]')
        expect(radios.size).to eq(Commerce::THEMES.size)

        checked = radios.select { |r| r["checked"] }
        expect(checked.map { |r| r["value"] }).to eq([ "dracula" ])
      end
    end
  end

  describe "PATCH /app/settings/appearance" do
    context "when the user is an owner" do
      it "persists a valid theme and redirects with a success flash" do
        user = create(:user)
        sign_in user

        patch "/app/settings/appearance", params: { commerce: { theme: "dracula" } }

        expect(response).to redirect_to(app_settings_appearance_path)
        expect(flash[:success]).to eq(I18n.t("app.appearance.saved"))
        expect(user.commerce.reload.theme).to eq("dracula")
      end

      it "rejects an invalid theme and leaves the stored theme unchanged" do
        user = create(:user)
        sign_in user

        patch "/app/settings/appearance", params: { commerce: { theme: "not-a-real-theme" } }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(user.commerce.reload.theme).to eq("light")
      end
    end

    context "when the user is a waiter" do
      it "redirects with an authorization error and does not change the theme" do
        user = create(:user, :waiter)
        sign_in user

        patch "/app/settings/appearance", params: { commerce: { theme: "dracula" } }

        expect(response).to redirect_to(app_orders_path)
        expect(flash[:error]).to eq(I18n.t("app.errors.not_authorized"))
        expect(user.commerce.reload.theme).to eq("light")
      end
    end
  end
end
