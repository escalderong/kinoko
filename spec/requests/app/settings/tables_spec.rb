require "rails_helper"

RSpec.describe "App::Settings::Tables", type: :request do
  describe "GET /app/settings/tables" do
    context "when the user is not authenticated" do
      it "redirects to the sign-in page" do
        get "/app/settings/tables"

        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when the user is a waiter" do
      it "redirects with an authorization error" do
        user = create(:user, :waiter)
        sign_in user

        get "/app/settings/tables"

        expect(response).to redirect_to(app_orders_path)
        expect(flash[:error]).to eq(I18n.t("app.errors.not_authorized"))
      end
    end

    context "when the user is an owner" do
      it "renders successfully with a no-zones marker when there are no zones" do
        user = create(:user)
        sign_in user

        get "/app/settings/tables"

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('data-test="no-zones"')
      end

      it "eager-renders every zone's tables and marks the requested zone as active" do
        user = create(:user)
        sign_in user
        zone1 = create(:floor_zone, commerce: user.commerce)
        zone2 = create(:floor_zone, commerce: user.commerce)
        create(:table, commerce: user.commerce, floor_zone: zone1, number: 101)
        create(:table, commerce: user.commerce, floor_zone: zone2, number: 202)

        get "/app/settings/tables", params: { zone: zone1.id }

        expect(response).to have_http_status(:ok)

        doc = Nokogiri::HTML(response.body)
        panel1 = doc.at_css(%([data-zones-target="panel"][data-zone-id="#{zone1.id}"]))
        panel2 = doc.at_css(%([data-zones-target="panel"][data-zone-id="#{zone2.id}"]))

        # both zones' tables are rendered up front (eager, client-side switching)
        expect(panel1.to_s).to include('data-table-number="101"')
        expect(panel2.to_s).to include('data-table-number="202"')

        # the requested zone is visible; the others start hidden
        expect(panel1[:class]).not_to include("hidden")
        expect(panel2[:class]).to include("hidden")
      end
    end
  end

  describe "POST /app/settings/tables" do
    context "when the user is an owner" do
      it "creates a table in the given zone" do
        user = create(:user)
        sign_in user
        zone = create(:floor_zone, commerce: user.commerce)

        expect do
          post "/app/settings/tables", params: { table: { number: 5, capacity: 4, floor_zone_id: zone.id } }
        end.to change { zone.tables.count }.by(1)

        expect(response).to redirect_to(app_settings_tables_path(zone: zone.id))
      end

      it "places a new table to the right of existing ones so they do not overlap" do
        user = create(:user)
        sign_in user
        zone = create(:floor_zone, commerce: user.commerce)
        create(:table, commerce: user.commerce, floor_zone: zone, pos_x: 0, pos_y: 0, width: 2, height: 2)

        post "/app/settings/tables", params: { table: { number: 9, capacity: 4, floor_zone_id: zone.id } }

        new_table = zone.tables.where(number: 9).first
        expect(new_table.pos_x).to eq(2)
        expect(new_table.pos_y).to eq(0)
      end
    end
  end

  describe "PATCH /app/settings/tables/:id" do
    context "when the user is an owner" do
      it "updates the table position and dimensions via JSON autosave" do
        user = create(:user)
        sign_in user
        zone = create(:floor_zone, commerce: user.commerce)
        table = create(:table, commerce: user.commerce, floor_zone: zone)

        patch "/app/settings/tables/#{table.id}", params: { table: { pos_x: 3, pos_y: 4, width: 2, height: 3 } }, as: :json

        expect(response).to have_http_status(:ok)
        table.reload
        expect(table.pos_x).to eq(3)
        expect(table.pos_y).to eq(4)
        expect(table.width).to eq(2)
        expect(table.height).to eq(3)
      end

      it "updates the table via a regular HTML form submit and redirects" do
        user = create(:user)
        sign_in user
        zone = create(:floor_zone, commerce: user.commerce)
        table = create(:table, commerce: user.commerce, floor_zone: zone)

        patch "/app/settings/tables/#{table.id}", params: { table: { number: 42, capacity: 7 } }

        expect(response).to redirect_to(app_settings_tables_path(zone: table.floor_zone_id))
        table.reload
        expect(table.number).to eq(42)
        expect(table.capacity).to eq(7)
      end
    end

    context "tenant isolation" do
      it "returns 404 when the table belongs to another commerce" do
        user = create(:user)
        sign_in user
        other_commerce = create(:commerce)
        other_zone = create(:floor_zone, commerce: other_commerce)
        foreign_table = create(:table, commerce: other_commerce, floor_zone: other_zone)

        patch "/app/settings/tables/#{foreign_table.id}", params: { table: { pos_x: 1, pos_y: 1 } }, as: :json

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "DELETE /app/settings/tables/:id" do
    context "when the user is an owner" do
      it "destroys the table" do
        user = create(:user)
        sign_in user
        zone = create(:floor_zone, commerce: user.commerce)
        table = create(:table, commerce: user.commerce, floor_zone: zone)

        expect do
          delete "/app/settings/tables/#{table.id}"
        end.to change { Table.count }.by(-1)

        expect(response).to redirect_to(app_settings_tables_path(zone: zone.id))
      end
    end

    context "tenant isolation" do
      it "returns 404 when the table belongs to another commerce" do
        user = create(:user)
        sign_in user
        other_commerce = create(:commerce)
        other_zone = create(:floor_zone, commerce: other_commerce)
        foreign_table = create(:table, commerce: other_commerce, floor_zone: other_zone)

        delete "/app/settings/tables/#{foreign_table.id}"

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
