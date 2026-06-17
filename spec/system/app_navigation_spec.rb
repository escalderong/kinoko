require 'rails_helper'

RSpec.describe "App navigation", type: :system do
  before do
    driven_by(:rack_test)
  end

  it "shows the navbar with top-level sections and the avatar dropdown" do
    user = create(:user, locale: "en")
    sign_in user

    visit "/app/orders"

    expect(page).to have_link(I18n.t("app.nav.orders"))
    expect(page).to have_link(I18n.t("app.nav.tables"))
    expect(page).to have_content(I18n.t("app.nav.products"))
    expect(page).to have_link(I18n.t("app.nav.preferences"))
    expect(page).to have_link(I18n.t("app.nav.logout"))
  end

  it "opens the Preferences modal showing the language form" do
    user = create(:user, locale: "en")
    sign_in user

    visit "/app/orders"
    click_link I18n.t("app.nav.preferences")

    expect(page).to have_content(I18n.t("app.preferences.title"))
    expect(page).to have_content(I18n.t("app.preferences.locales.en"))
    expect(page).to have_content(I18n.t("app.preferences.locales.es"))
  end

  it "switches the locale to Spanish via the Preferences modal and re-renders the navbar" do
    user = create(:user, locale: "en")
    sign_in user

    visit "/app/orders"
    click_link I18n.t("app.nav.preferences")

    choose "user_locale_es"
    click_button I18n.t("app.preferences.save")

    expect(user.reload.locale).to eq("es")

    # rack_test has no JS, so the Turbo Stream `:refresh` action (ADR-5) cannot be
    # exercised here. Visiting the navbar again proves the persisted locale is
    # applied per-request and the navbar re-renders in Spanish.
    visit "/app/orders"
    expect(page).to have_link(I18n.t("app.nav.orders", locale: :es))
    expect(page).to have_link(I18n.t("app.nav.preferences", locale: :es))
  end
end
