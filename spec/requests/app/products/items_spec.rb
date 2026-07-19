require "rails_helper"

RSpec.describe "App::Products::Items", type: :request do
  describe "GET /app/products/items" do
    context "when the user is not authenticated" do
      it "redirects to the sign-in page" do
        get "/app/products/items"

        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when the user is a waiter" do
      it "redirects with an authorization error" do
        user = create(:user, :waiter)
        sign_in user

        get "/app/products/items"

        expect(response).to redirect_to(app_orders_path)
        expect(flash[:error]).to eq(I18n.t("app.errors.not_authorized"))
      end
    end

    context "when the user is an owner" do
      it "renders successfully with a no-items marker when there are none" do
        user = create(:user)
        sign_in user

        get "/app/products/items"

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('data-test="no-items"')
      end

      it "lists the commerce products" do
        user = create(:user)
        sign_in user
        category = create(:product_category, commerce: user.commerce)
        product = create(:product, commerce: user.commerce, product_category: category, name: "Cheeseburger")

        get "/app/products/items"

        expect(response).to have_http_status(:ok)
        expect(response.body).to include(%(data-item-id="#{product.id}"))
        expect(response.body).to include("Cheeseburger")
      end
    end

    context "when the user is an admin" do
      it "renders successfully" do
        user = create(:user, :admin)
        sign_in user

        get "/app/products/items"

        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "POST /app/products/items" do
    context "when the user is an owner" do
      it "creates a product with a price scoped to the commerce" do
        user = create(:user)
        sign_in user
        category = create(:product_category, commerce: user.commerce)

        expect do
          post "/app/products/items", params: {
            product: { name: "Fries", base_price: "8000", is_active: "1", product_category_id: category.id }
          }
        end.to change { user.commerce.products.count }.by(1)

        expect(response).to redirect_to(app_products_items_path)
        product = user.commerce.products.last
        expect(product.name).to eq("Fries")
        expect(product.base_price).to eq(Money.from_amount(8000, "COP"))
        expect(product.product_category).to eq(category)
      end

      it "redirects with an error when invalid" do
        user = create(:user)
        sign_in user
        category = create(:product_category, commerce: user.commerce)

        post "/app/products/items", params: {
          product: { name: "", base_price: "8000", product_category_id: category.id }
        }

        expect(response).to redirect_to(app_products_items_path)
        expect(flash[:error]).to be_present
      end
    end

    context "tenant isolation" do
      it "returns 404 when the category belongs to another commerce" do
        user = create(:user)
        sign_in user
        foreign_category = create(:product_category, commerce: create(:commerce))

        post "/app/products/items", params: {
          product: { name: "Fries", base_price: "8000", product_category_id: foreign_category.id }
        }

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "PATCH /app/products/items/:id" do
    context "when the user is an owner" do
      it "updates the product" do
        user = create(:user)
        sign_in user
        category = create(:product_category, commerce: user.commerce)
        product = create(:product, commerce: user.commerce, product_category: category)

        patch "/app/products/items/#{product.id}", params: {
          product: { name: "Double burger", base_price: "12000", is_active: "0", product_category_id: category.id }
        }

        expect(response).to redirect_to(app_products_items_path)
        product.reload
        expect(product.name).to eq("Double burger")
        expect(product.base_price).to eq(Money.from_amount(12000, "COP"))
        expect(product.is_active).to be false
      end
    end

    context "tenant isolation" do
      it "returns 404 when the product belongs to another commerce" do
        user = create(:user)
        sign_in user
        foreign = create(:product, commerce: create(:commerce))

        patch "/app/products/items/#{foreign.id}", params: { product: { name: "Hacked" } }

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "DELETE /app/products/items/:id" do
    context "when the user is an owner" do
      it "destroys the product" do
        user = create(:user)
        sign_in user
        product = create(:product, commerce: user.commerce)

        expect do
          delete "/app/products/items/#{product.id}"
        end.to change { Product.count }.by(-1)

        expect(response).to redirect_to(app_products_items_path)
      end
    end

    context "tenant isolation" do
      it "returns 404 when the product belongs to another commerce" do
        user = create(:user)
        sign_in user
        foreign = create(:product, commerce: create(:commerce))

        delete "/app/products/items/#{foreign.id}"

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
