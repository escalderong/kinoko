require "rails_helper"

RSpec.describe "Table dialog reload on open", type: :system do
  let(:commerce) { create(:commerce) }
  let(:user) { create(:user, commerce: commerce) }
  let(:table) { create(:table, commerce: commerce) }
  let(:order) { create(:order, table: table, status: :open) }

  before do
    create(:order_item, order: order, product_name: "Burger", quantity: 1)

    visit new_user_session_path
    fill_in "Email", with: user.email
    fill_in "Password", with: "password123"
    click_button "Log in"
    expect(page).to have_current_path(app_orders_path, wait: 5)
  end

  it "fetches fresh order state on every open instead of showing a cached copy" do
    visit app_tables_path

    find("[data-table-number='#{table.number}']").click
    expect(page).to have_content("1x Burger", wait: 5)

    order.order_items.first.update!(quantity: 3)

    find("dialog[open] button[aria-label='#{I18n.t('app.modal.close')}']").click
    find("[data-table-number='#{table.number}']").click

    expect(page).to have_content("3x Burger", wait: 5)
  end
end
