require "rails_helper"

RSpec.describe "App::Tables::OrderItems", type: :request do
  let(:user) { create(:user, :waiter) }
  let(:zone) { create(:floor_zone, commerce: user.commerce) }
  let(:table) { create(:table, commerce: user.commerce, floor_zone: zone) }
  let(:category) { create(:product_category, commerce: user.commerce) }
  let(:product) do
    create(:product, commerce: user.commerce, product_category: category, base_price: Money.new(10_000, "COP"))
  end

  describe "POST /app/tables/:table_id/order_items" do
    context "when the user is not authenticated" do
      it "redirects to the sign-in page" do
        post "/app/tables/#{table.id}/order_items", params: { cart: "[]" }

        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when the table has an open order" do
      it "adds items to the existing order as a waiter" do
        sign_in user
        order = create(:order, table: table, status: :open)
        cart = [ { product_id: product.id.to_s, variant_ids: [], modifier_ids: [], quantity: 2 } ]

        expect do
          expect do
            post "/app/tables/#{table.id}/order_items", params: { cart: cart.to_json }
          end.to change(OrderItem, :count).by(1)
        end.not_to change(Order, :count)

        order.reload
        expect(order.order_items.count).to eq(1)
        expect(order.order_items.first.product_name).to eq(product.name)
        expect(order.order_items.first.quantity).to eq(2)
        expect(response).to redirect_to(app_tables_path)
        expect(flash[:success]).to be_present
      end
    end

    context "when the table has no open order" do
      it "rejects the request and does not create any order item" do
        sign_in user
        cart = [ { product_id: product.id.to_s, variant_ids: [], modifier_ids: [], quantity: 1 } ]

        expect do
          post "/app/tables/#{table.id}/order_items", params: { cart: cart.to_json }
        end.not_to change(OrderItem, :count)

        expect(response).to redirect_to(app_tables_path)
        expect(flash[:error]).to be_present
      end
    end

    context "tenant isolation" do
      it "returns 404 for a table belonging to another commerce" do
        sign_in user
        foreign_table = create(:table, commerce: create(:commerce))
        create(:order, table: foreign_table, status: :open)

        post "/app/tables/#{foreign_table.id}/order_items", params: { cart: "[]" }

        expect(response).to have_http_status(:not_found)
      end
    end

    context "when the cart is invalid" do
      it "does not corrupt the existing order's other items" do
        sign_in user
        order = create(:order, table: table, status: :open)
        existing_item = create(:order_item, order: order, product_name: "Existing Item")

        group = create(:variant_group, product: product, is_required: true)
        create(:variant, variant_group: group)
        cart = [ { product_id: product.id.to_s, variant_ids: [], modifier_ids: [], quantity: 1 } ]

        expect do
          post "/app/tables/#{table.id}/order_items", params: { cart: cart.to_json }
        end.not_to change(OrderItem, :count)

        order.reload
        expect(order.order_items.to_a).to eq([ existing_item ])
        expect(response).to redirect_to(app_tables_path)
        expect(flash[:error]).to be_present
      end

      it "flashes an error and does not add an item for an empty cart" do
        sign_in user
        create(:order, table: table, status: :open)

        expect do
          post "/app/tables/#{table.id}/order_items", params: { cart: "[]" }
        end.not_to change(OrderItem, :count)

        expect(response).to redirect_to(app_tables_path)
        expect(flash[:error]).to be_present
      end
    end
  end
end
