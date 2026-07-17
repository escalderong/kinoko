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
      it "renders it as not clickable, without a modal, and with an open-order marker" do
        user = create(:user)
        sign_in user
        zone = create(:floor_zone, commerce: user.commerce)
        table = create(:table, commerce: user.commerce, floor_zone: zone, number: 7)
        create(:order, table: table, status: :open)

        get "/app/tables", params: { zone: zone.id }

        doc = Nokogiri::HTML(response.body)
        table_node = doc.at_css(%([data-table-number="7"]))

        expect(table_node["onclick"]).to be_nil
        expect(table_node["data-test"]).to eq("table-open")
        expect(response.body).not_to include("new_order_#{table.id}_modal")
      end
    end

    context "when a table has a closed order" do
      it "renders it as clickable with its new-order modal" do
        user = create(:user)
        sign_in user
        zone = create(:floor_zone, commerce: user.commerce)
        table = create(:table, commerce: user.commerce, floor_zone: zone, number: 8)
        create(:order, table: table, status: :closed)

        get "/app/tables", params: { zone: zone.id }

        doc = Nokogiri::HTML(response.body)
        table_node = doc.at_css(%([data-table-number="8"]))

        expect(table_node["onclick"]).to include("new_order_#{table.id}_modal")
        expect(response.body).to include("new_order_#{table.id}_modal")
      end
    end

    context "when a table has no order" do
      it "renders it as clickable with its new-order modal" do
        user = create(:user)
        sign_in user
        zone = create(:floor_zone, commerce: user.commerce)
        table = create(:table, commerce: user.commerce, floor_zone: zone, number: 9)

        get "/app/tables", params: { zone: zone.id }

        doc = Nokogiri::HTML(response.body)
        table_node = doc.at_css(%([data-table-number="9"]))

        expect(table_node["onclick"]).to include("new_order_#{table.id}_modal")
        expect(response.body).to include("new_order_#{table.id}_modal")
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
end
