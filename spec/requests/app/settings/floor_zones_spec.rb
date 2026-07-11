require "rails_helper"

RSpec.describe "App::Settings::FloorZones", type: :request do
  describe "POST /app/settings/floor_zones" do
    context "when the user is a waiter" do
      it "redirects with an authorization error" do
        user = create(:user, :waiter)
        sign_in user

        post "/app/settings/floor_zones", params: { floor_zone: { name: "Patio" } }

        expect(response).to redirect_to(app_orders_path)
        expect(flash[:error]).to eq(I18n.t("app.errors.not_authorized"))
      end
    end

    context "when the user is an owner" do
      it "creates a floor zone and redirects to the tables index" do
        user = create(:user)
        sign_in user

        expect do
          post "/app/settings/floor_zones", params: { floor_zone: { name: "Patio" } }
        end.to change { FloorZone.count }.by(1)

        zone = FloorZone.last
        expect(response).to redirect_to(app_settings_tables_path(zone: zone.id))
      end

      it "increments the position for each new zone" do
        user = create(:user)
        sign_in user

        post "/app/settings/floor_zones", params: { floor_zone: { name: "Patio" } }
        first_zone = FloorZone.last

        post "/app/settings/floor_zones", params: { floor_zone: { name: "Salon" } }
        second_zone = FloorZone.last

        expect(second_zone.position).to be > first_zone.position
      end
    end
  end

  describe "PATCH /app/settings/floor_zones/:id" do
    context "when the user is an owner" do
      it "renames the floor zone" do
        user = create(:user)
        sign_in user
        zone = create(:floor_zone, commerce: user.commerce, name: "Old Name")

        patch "/app/settings/floor_zones/#{zone.id}", params: { floor_zone: { name: "New Name" } }

        expect(response).to redirect_to(app_settings_tables_path(zone: zone.id))
        expect(zone.reload.name).to eq("New Name")
      end
    end

    context "tenant isolation" do
      it "returns 404 when the zone belongs to another commerce" do
        user = create(:user)
        sign_in user
        other_commerce = create(:commerce)
        foreign_zone = create(:floor_zone, commerce: other_commerce)

        patch "/app/settings/floor_zones/#{foreign_zone.id}", params: { floor_zone: { name: "Hacked" } }

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "DELETE /app/settings/floor_zones/:id" do
    context "when the user is an owner" do
      it "destroys the zone and its tables" do
        user = create(:user)
        sign_in user
        zone = create(:floor_zone, commerce: user.commerce)
        create(:table, commerce: user.commerce, floor_zone: zone, number: 1)
        create(:table, commerce: user.commerce, floor_zone: zone, number: 2)

        expect do
          delete "/app/settings/floor_zones/#{zone.id}"
        end.to change { Table.count }.by(-2)

        expect(FloorZone.where(id: zone.id)).to be_empty
        expect(response).to redirect_to(app_settings_tables_path)
      end
    end

    context "tenant isolation" do
      it "returns 404 when the zone belongs to another commerce" do
        user = create(:user)
        sign_in user
        other_commerce = create(:commerce)
        foreign_zone = create(:floor_zone, commerce: other_commerce)

        delete "/app/settings/floor_zones/#{foreign_zone.id}"

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
