require 'rails_helper'

RSpec.describe "App::Preferences", type: :request do
  describe "GET /app/preferences/edit" do
    it "renders the language form inside the modal turbo frame" do
      user = create(:user, locale: "en")
      sign_in user

      get "/app/preferences/edit"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('<turbo-frame id="modal">')
      expect(response.body).to include(I18n.t("app.preferences.title"))
      expect(response.body).to include(I18n.t("app.preferences.locales.en"))
      expect(response.body).to include(I18n.t("app.preferences.locales.es"))
    end
  end

  describe "PATCH /app/preferences" do
    it "updates the current user's locale and responds with a turbo stream" do
      user = create(:user, locale: "en")
      sign_in user

      patch "/app/preferences", params: { user: { locale: "es" } }, as: :turbo_stream

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq(Mime[:turbo_stream].to_s)
      expect(user.reload.locale).to eq("es")
    end

    it "ignores unsupported locale values" do
      user = create(:user, locale: "en")
      sign_in user

      patch "/app/preferences", params: { user: { locale: "fr" } }, as: :turbo_stream

      expect(response).to have_http_status(:ok)
      expect(user.reload.locale).to eq("en")
    end

    it "falls back to redirecting back when the request is a plain HTML form submission" do
      user = create(:user, locale: "en")
      sign_in user

      patch "/app/preferences", params: { user: { locale: "es" } }, headers: { "HTTP_REFERER" => "/app/orders" }

      expect(response).to redirect_to("/app/orders")
      expect(user.reload.locale).to eq("es")
    end
  end
end
