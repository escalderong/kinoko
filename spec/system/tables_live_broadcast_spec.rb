require "rails_helper"

RSpec.describe "Tables view live broadcast", type: :system do
  let(:commerce) { create(:commerce) }
  let(:waiter) { create(:user, :waiter, commerce: commerce) }
  let!(:table) { create(:table, commerce: commerce) }

  before do
    visit new_user_session_path
    fill_in "Email", with: waiter.email
    fill_in "Password", with: "password123"
    click_button "Log in"
    expect(page).to have_current_path(app_orders_path, wait: 5)
  end

  it "shows the aura on an already-open tables view when another user opens an order, without a reload" do
    visit app_tables_path
    expect(page).to have_css("[data-table-number='#{table.number}']")
    expect(page).to have_no_css("[data-table-number='#{table.number}'][data-test='table-open']")

    # Simulates another user/process opening an order on this table from
    # somewhere else entirely — this browser never navigates or reloads.
    create(:order, table: table, status: :open)

    expect(page).to have_css("[data-table-number='#{table.number}'][data-test='table-open']", wait: 5)
  end
end
