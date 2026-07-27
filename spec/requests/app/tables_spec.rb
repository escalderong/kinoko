require "rails_helper"

RSpec.describe "App::Tables", type: :request do
  describe "GET /app/tables" do
    context "when the user is not authenticated" do
      it "redirects to the sign-in page" do
        get "/app/tables"

        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when the user is an owner" do
      it "renders successfully" do
        user = create(:user)
        sign_in user

        get "/app/tables"

        expect(response).to have_http_status(:ok)
      end
    end

    context "when the user is an admin" do
      it "renders successfully" do
        user = create(:user, :admin)
        sign_in user

        get "/app/tables"

        expect(response).to have_http_status(:ok)
      end
    end

    context "when the user is a waiter" do
      it "renders successfully" do
        user = create(:user, :waiter)
        sign_in user

        get "/app/tables"

        expect(response).to have_http_status(:ok)
      end
    end

    context "tenant isolation" do
      it "does not render zones or tables from another commerce" do
        user = create(:user)
        sign_in user
        other_commerce = create(:commerce)
        other_zone = create(:floor_zone, commerce: other_commerce, name: "Foreign Zone")
        create(:table, commerce: other_commerce, floor_zone: other_zone, number: 999)

        get "/app/tables"

        expect(response.body).not_to include("Foreign Zone")
        expect(response.body).not_to include('data-table-number="999"')
      end
    end

    context "when a table has an open order" do
      it "renders it as clickable with its modal and an open-order marker" do
        user = create(:user)
        sign_in user
        zone = create(:floor_zone, commerce: user.commerce)
        table = create(:table, commerce: user.commerce, floor_zone: zone, number: 7)
        create(:order, table: table, status: :open)

        get "/app/tables", params: { zone: zone.id }

        doc = Nokogiri::HTML(response.body)
        table_node = doc.at_css(%([data-table-number="7"]))

        expect(table_node["href"]).to eq(app_table_path(table))
        expect(table_node["data-turbo-frame"]).to eq("table_#{table.id}_frame")
        expect(table_node["data-action"]).to eq("click->dialog#open")
        expect(table_node["data-test"]).to eq("table-open")
        expect(response.body).to include("table_#{table.id}_modal")
        expect(response.body).to include(I18n.t("app.tables.existing_order_for_table", number: table.number))
      end
    end

    context "when a table has a closed order" do
      it "renders it as clickable with its modal" do
        user = create(:user)
        sign_in user
        zone = create(:floor_zone, commerce: user.commerce)
        table = create(:table, commerce: user.commerce, floor_zone: zone, number: 8)
        create(:order, table: table, status: :closed)

        get "/app/tables", params: { zone: zone.id }

        doc = Nokogiri::HTML(response.body)
        table_node = doc.at_css(%([data-table-number="8"]))

        expect(table_node["href"]).to eq(app_table_path(table))
        expect(table_node["data-turbo-frame"]).to eq("table_#{table.id}_frame")
        expect(table_node["data-action"]).to eq("click->dialog#open")
        expect(response.body).to include("table_#{table.id}_modal")
        expect(response.body).to include(I18n.t("app.tables.new_order_for_table", number: table.number))
      end
    end

    context "when a table has no order" do
      it "renders it as clickable with its modal" do
        user = create(:user)
        sign_in user
        zone = create(:floor_zone, commerce: user.commerce)
        table = create(:table, commerce: user.commerce, floor_zone: zone, number: 9)

        get "/app/tables", params: { zone: zone.id }

        doc = Nokogiri::HTML(response.body)
        table_node = doc.at_css(%([data-table-number="9"]))

        expect(table_node["href"]).to eq(app_table_path(table))
        expect(table_node["data-turbo-frame"]).to eq("table_#{table.id}_frame")
        expect(table_node["data-action"]).to eq("click->dialog#open")
        expect(response.body).to include("table_#{table.id}_modal")
        expect(response.body).to include(I18n.t("app.tables.new_order_for_table", number: table.number))
      end
    end

    context "zone selection" do
      it "marks the requested zone as active" do
        user = create(:user)
        sign_in user
        zone1 = create(:floor_zone, commerce: user.commerce)
        zone2 = create(:floor_zone, commerce: user.commerce)
        create(:table, commerce: user.commerce, floor_zone: zone1, number: 101)
        create(:table, commerce: user.commerce, floor_zone: zone2, number: 202)

        get "/app/tables", params: { zone: zone2.id }

        doc = Nokogiri::HTML(response.body)
        panel1 = doc.at_css(%([data-zones-target="panel"][data-zone-id="#{zone1.id}"]))
        panel2 = doc.at_css(%([data-zones-target="panel"][data-zone-id="#{zone2.id}"]))

        expect(panel1[:class]).to include("hidden")
        expect(panel2[:class]).not_to include("hidden")
      end
    end
  end

  describe "GET /app/tables/:id" do
    context "when the user is not authenticated" do
      it "redirects to the sign-in page" do
        table = create(:table)

        get "/app/tables/#{table.id}"

        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when the table has no open order" do
      it "renders successfully with the product picker" do
        user = create(:user)
        sign_in user
        zone = create(:floor_zone, commerce: user.commerce)
        table = create(:table, commerce: user.commerce, floor_zone: zone)
        category = create(:product_category, commerce: user.commerce, name: "Drinks")
        create(:product, commerce: user.commerce, product_category: category, name: "Lemonade")

        get "/app/tables/#{table.id}"

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Drinks")
        expect(response.body).to include("Lemonade")
      end
    end

    context "when the table has an open order" do
      it "renders elapsed time, current items, and the add-items picker" do
        user = create(:user)
        sign_in user
        zone = create(:floor_zone, commerce: user.commerce)
        table = create(:table, commerce: user.commerce, floor_zone: zone)
        order = create(:order, table: table, status: :open, opened_at: 10.minutes.ago)
        create(:order_item, order: order, product_name: "Burger", quantity: 2)
        category = create(:product_category, commerce: user.commerce, name: "Sides")
        create(:product, commerce: user.commerce, product_category: category, name: "Fries")

        get "/app/tables/#{table.id}"

        expect(response).to have_http_status(:ok)
        expect(response.body).to include(I18n.t("app.tables.orders.current_items"))
        expect(response.body).to include("2x Burger")
        expect(response.body).to include(I18n.t("app.tables.orders.add_items"))
        expect(response.body).to include("Fries")
      end

      it "shows the checkout button to an owner" do
        user = create(:user)
        sign_in user
        table = create(:table, commerce: user.commerce)
        create(:order, table: table, status: :open)

        get "/app/tables/#{table.id}"

        expect(response.body).to include(I18n.t("app.tables.orders.checkout"))
      end

      it "shows the checkout button to an admin" do
        user = create(:user, :admin)
        sign_in user
        table = create(:table, commerce: user.commerce)
        create(:order, table: table, status: :open)

        get "/app/tables/#{table.id}"

        expect(response.body).to include(I18n.t("app.tables.orders.checkout"))
      end

      it "shows the checkout button to a cashier" do
        user = create(:user, :cashier)
        sign_in user
        table = create(:table, commerce: user.commerce)
        create(:order, table: table, status: :open)

        get "/app/tables/#{table.id}"

        expect(response.body).to include(I18n.t("app.tables.orders.checkout"))
      end

      it "hides the checkout button from a waiter" do
        user = create(:user, :waiter)
        sign_in user
        table = create(:table, commerce: user.commerce)
        create(:order, table: table, status: :open)

        get "/app/tables/#{table.id}"

        expect(response.body).not_to include(I18n.t("app.tables.orders.checkout"))
      end
    end

    context "tenant isolation" do
      it "returns 404 for a table belonging to another commerce" do
        user = create(:user)
        sign_in user
        foreign_table = create(:table, commerce: create(:commerce))

        get "/app/tables/#{foreign_table.id}"

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
