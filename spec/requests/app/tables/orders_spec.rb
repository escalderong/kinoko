require "rails_helper"

RSpec.describe "App::Tables::Orders", type: :request do
  let(:user) { create(:user, :waiter) }
  let(:zone) { create(:floor_zone, commerce: user.commerce) }
  let(:table) { create(:table, commerce: user.commerce, floor_zone: zone) }
  let(:category) { create(:product_category, commerce: user.commerce) }
  let(:product) do
    create(:product, commerce: user.commerce, product_category: category, base_price: Money.new(10_000, "COP"))
  end

  describe "POST /app/tables/:table_id/orders" do
    context "when the user is not authenticated" do
      it "redirects to the sign-in page" do
        post "/app/tables/#{table.id}/orders", params: { cart: "[]" }

        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when the user is a waiter" do
      it "creates the order with its items" do
        sign_in user
        cart = [ { product_id: product.id.to_s, variant_ids: [], modifier_ids: [], quantity: 2 } ]

        expect do
          post "/app/tables/#{table.id}/orders", params: { cart: cart.to_json }
        end.to change(Order, :count).by(1)

        order = Order.open.where(table_id: table.id).first
        expect(order).to be_present
        expect(order.order_items.count).to eq(1)
        expect(order.order_items.first.product_name).to eq(product.name)
        expect(order.order_items.first.quantity).to eq(2)
        expect(response).to redirect_to(app_tables_path)
        expect(flash[:success]).to be_present
      end

      it "creates variant and modifier snapshots for the order item" do
        sign_in user
        group = create(:variant_group, product: product, name: "Size")
        variant = create(:variant, variant_group: group, name: "Large", price_delta: Money.new(2_000, "COP"))
        cart = [ { product_id: product.id.to_s, variant_ids: [ variant.id.to_s ], modifier_ids: [], quantity: 1 } ]

        post "/app/tables/#{table.id}/orders", params: { cart: cart.to_json }

        item = Order.open.where(table_id: table.id).first.order_items.first
        expect(item.order_item_variants.count).to eq(1)
        expect(item.order_item_variants.first.variant_name).to eq("Large")
        expect(item.order_item_variants.first.variant_group_name).to eq("Size")
      end
    end

    context "when the table already has an open order" do
      it "rejects the request and does not create another order" do
        sign_in user
        create(:order, table: table, status: :open)
        cart = [ { product_id: product.id.to_s, variant_ids: [], modifier_ids: [], quantity: 1 } ]

        expect do
          post "/app/tables/#{table.id}/orders", params: { cart: cart.to_json }
        end.not_to change(Order, :count)

        expect(response).to redirect_to(app_tables_path)
        expect(flash[:error]).to be_present
      end

      it "still rejects gracefully (not a 500) when two requests race past the exists? guard" do
        sign_in user
        create(:order, table: table, status: :open)
        # Simulates the TOCTOU window: the app-level guard is fooled into
        # thinking there's no open order, so the request proceeds to
        # `order.save` — where the table's partial unique index is what
        # actually has to catch it.
        allow(Order).to receive(:open_for).and_return(Order.none)
        cart = [ { product_id: product.id.to_s, variant_ids: [], modifier_ids: [], quantity: 1 } ]

        expect do
          post "/app/tables/#{table.id}/orders", params: { cart: cart.to_json }
        end.not_to change(Order, :count)

        expect(response).to redirect_to(app_tables_path)
        expect(flash[:error]).to be_present
      end
    end

    context "tenant isolation" do
      it "returns 404 for a table belonging to another commerce" do
        sign_in user
        foreign_table = create(:table, commerce: create(:commerce))

        post "/app/tables/#{foreign_table.id}/orders", params: { cart: "[]" }

        expect(response).to have_http_status(:not_found)
      end
    end

    context "when the cart is invalid" do
      it "flashes an error and does not create a partial order" do
        sign_in user
        group = create(:variant_group, product: product, is_required: true)
        create(:variant, variant_group: group)
        cart = [ { product_id: product.id.to_s, variant_ids: [], modifier_ids: [], quantity: 1 } ]

        expect do
          post "/app/tables/#{table.id}/orders", params: { cart: cart.to_json }
        end.not_to change(Order, :count)

        expect(response).to redirect_to(app_tables_path)
        expect(flash[:error]).to be_present
      end

      it "flashes an error and does not create a partial order for an empty cart" do
        sign_in user

        expect do
          post "/app/tables/#{table.id}/orders", params: { cart: "[]" }
        end.not_to change(Order, :count)

        expect(response).to redirect_to(app_tables_path)
        expect(flash[:error]).to be_present
      end
    end
  end
end
