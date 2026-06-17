require 'rails_helper'

RSpec.describe "App::ComingSoon i18n", type: :request do
  describe "GET /app/tables" do
    context "when the user's locale is :en" do
      it "renders the English heading and body" do
        user = create(:user, locale: "en")
        sign_in user

        get "/app/tables"

        expect(response.body).to include(I18n.t("app.sections.tables.title", locale: :en))
        expect(response.body).to include(I18n.t("app.coming_soon", locale: :en))
      end
    end

    context "when the user's locale is :es" do
      it "renders the Spanish heading and body" do
        user = create(:user, locale: "es")
        sign_in user

        get "/app/tables"

        expect(response.body).to include(I18n.t("app.sections.tables.title", locale: :es))
        expect(response.body).to include(I18n.t("app.coming_soon", locale: :es))
      end
    end
  end
end
