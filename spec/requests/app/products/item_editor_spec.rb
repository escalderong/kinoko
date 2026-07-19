require "rails_helper"

RSpec.describe "App::Products item editor (variants & modifiers)", type: :request do
  let(:user) { create(:user) }
  let(:product) { create(:product, commerce: user.commerce) }

  describe "GET /app/products/items/:id/edit" do
    context "when the user is not authenticated" do
      it "redirects to the sign-in page" do
        get "/app/products/items/#{product.id}/edit"

        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when the user is a waiter" do
      it "redirects with an authorization error" do
        waiter = create(:user, :waiter)
        sign_in waiter
        item = create(:product, commerce: waiter.commerce)

        get "/app/products/items/#{item.id}/edit"

        expect(response).to redirect_to(app_orders_path)
      end
    end

    context "when the user is an owner" do
      it "renders the variant and modifier sections" do
        sign_in user
        group = create(:variant_group, product: product, name: "Soda")
        create(:variant, variant_group: group, name: "Coke")

        get "/app/products/items/#{product.id}/edit"

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Soda")
        expect(response.body).to include("Coke")
      end
    end

    context "tenant isolation" do
      it "returns 404 for a product from another commerce" do
        sign_in user
        foreign = create(:product, commerce: create(:commerce))

        get "/app/products/items/#{foreign.id}/edit"

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "variant groups" do
    before { sign_in user }

    it "creates a variant group" do
      expect do
        post "/app/products/items/#{product.id}/variant_groups", params: {
          variant_group: { name: "Size", is_required: "1" }
        }
      end.to change { product.reload.variant_groups.count }.by(1)

      expect(response).to redirect_to(edit_app_products_item_path(product))
    end

    it "updates a variant group" do
      group = create(:variant_group, product: product, name: "Size")

      patch "/app/products/items/#{product.id}/variant_groups/#{group.id}", params: {
        variant_group: { name: "Portion", is_required: "0" }
      }

      expect(response).to redirect_to(edit_app_products_item_path(product))
      expect(group.reload.name).to eq("Portion")
    end

    it "destroys a variant group" do
      group = create(:variant_group, product: product)

      expect do
        delete "/app/products/items/#{product.id}/variant_groups/#{group.id}"
      end.to change { VariantGroup.count }.by(-1)
    end

    it "returns 404 when the product belongs to another commerce" do
      foreign = create(:product, commerce: create(:commerce))

      post "/app/products/items/#{foreign.id}/variant_groups", params: { variant_group: { name: "X" } }

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "variants" do
    before { sign_in user }

    let(:group) { create(:variant_group, product: product) }

    it "creates a variant" do
      expect do
        post "/app/products/items/#{product.id}/variant_groups/#{group.id}/variants", params: {
          variant: { name: "Large", sku: "LG-1", price_delta: "500" }
        }
      end.to change { group.reload.variants.count }.by(1)

      expect(response).to redirect_to(edit_app_products_item_path(product))
      variant = group.variants.last
      expect(variant.price_delta).to eq(Money.from_amount(500, "COP"))
    end

    it "destroys a variant" do
      variant = create(:variant, variant_group: group)

      expect do
        delete "/app/products/items/#{product.id}/variant_groups/#{group.id}/variants/#{variant.id}"
      end.to change { Variant.count }.by(-1)
    end
  end

  describe "modifier groups" do
    before { sign_in user }

    it "creates a modifier group" do
      expect do
        post "/app/products/items/#{product.id}/modifier_groups", params: {
          modifier_group: { name: "Extras", is_required: "0", min_selected: "0", max_selected: "3" }
        }
      end.to change { product.reload.modifier_groups.count }.by(1)

      expect(response).to redirect_to(edit_app_products_item_path(product))
    end

    it "destroys a modifier group" do
      group = create(:modifier_group, product: product)

      expect do
        delete "/app/products/items/#{product.id}/modifier_groups/#{group.id}"
      end.to change { ModifierGroup.count }.by(-1)
    end
  end

  describe "modifiers" do
    before { sign_in user }

    let(:group) { create(:modifier_group, product: product) }

    it "creates a modifier" do
      expect do
        post "/app/products/items/#{product.id}/modifier_groups/#{group.id}/modifiers", params: {
          modifier: { name: "No pickles", price_delta: "0" }
        }
      end.to change { group.reload.modifiers.count }.by(1)

      expect(response).to redirect_to(edit_app_products_item_path(product))
    end
  end
end
