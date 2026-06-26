require 'rails_helper'

RSpec.describe "Flash messages", type: :system do
  let(:user) { create(:user) }

  before do
    visit new_user_session_path
    fill_in "Email", with: user.email
    fill_in "Password", with: "password123"
    click_button "Log in"
  end

  it "appears in the DOM after a flash-triggering action" do
    expect(page).to have_css('[role="alert"]')
  end

  it "disappears from the DOM after the delay" do
    expect(page).to have_css('[role="alert"]')
    expect(page).to have_no_css('[role="alert"]', wait: 5)
  end
end
