require "rails_helper"

RSpec.describe "App::Products::Categories", type: :request do
  describe "GET /app/products/categories" do
    context "when the user is not authenticated" do
      it "redirects to the sign-in page" do
        get "/app/products/categories"

        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when the user is a waiter" do
      it "redirects with an authorization error" do
        user = create(:user, :waiter)
        sign_in user

        get "/app/products/categories"

        expect(response).to redirect_to(app_orders_path)
        expect(flash[:error]).to eq(I18n.t("app.errors.not_authorized"))
      end
    end

    context "when the user is an owner" do
      it "renders successfully with a no-categories marker when there are none" do
        user = create(:user)
        sign_in user

        get "/app/products/categories"

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('data-test="no-categories"')
      end

      it "lists the commerce categories" do
        user = create(:user)
        sign_in user
        category = create(:product_category, commerce: user.commerce, name: "Drinks")

        get "/app/products/categories"

        expect(response).to have_http_status(:ok)
        expect(response.body).to include(%(data-category-id="#{category.id}"))
        expect(response.body).to include("Drinks")
      end
    end

    context "when the user is an admin" do
      it "renders successfully" do
        user = create(:user, :admin)
        sign_in user

        get "/app/products/categories"

        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "POST /app/products/categories" do
    context "when the user is an owner" do
      it "creates a category scoped to the commerce" do
        user = create(:user)
        sign_in user

        expect do
          post "/app/products/categories", params: { product_category: { name: "Drinks", icon: "mug-hot" } }
        end.to change { user.commerce.product_categories.count }.by(1)

        expect(response).to redirect_to(app_products_categories_path)
        category = user.commerce.product_categories.last
        expect(category.name).to eq("Drinks")
        expect(category.icon).to eq("mug-hot")
      end

      it "redirects with an error when invalid" do
        user = create(:user)
        sign_in user

        post "/app/products/categories", params: { product_category: { name: "", icon: "mug-hot" } }

        expect(response).to redirect_to(app_products_categories_path)
        expect(flash[:error]).to be_present
      end
    end
  end

  describe "PATCH /app/products/categories/:id" do
    context "when the user is an owner" do
      it "updates the category" do
        user = create(:user)
        sign_in user
        category = create(:product_category, commerce: user.commerce, name: "Drinks", icon: "mug-hot")

        patch "/app/products/categories/#{category.id}", params: { product_category: { name: "Beverages", icon: "wine-glass" } }

        expect(response).to redirect_to(app_products_categories_path)
        category.reload
        expect(category.name).to eq("Beverages")
        expect(category.icon).to eq("wine-glass")
      end
    end

    context "tenant isolation" do
      it "returns 404 when the category belongs to another commerce" do
        user = create(:user)
        sign_in user
        foreign = create(:product_category, commerce: create(:commerce))

        patch "/app/products/categories/#{foreign.id}", params: { product_category: { name: "Hacked" } }

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "DELETE /app/products/categories/:id" do
    context "when the user is an owner" do
      it "destroys the category" do
        user = create(:user)
        sign_in user
        category = create(:product_category, commerce: user.commerce)

        expect do
          delete "/app/products/categories/#{category.id}"
        end.to change { ProductCategory.count }.by(-1)

        expect(response).to redirect_to(app_products_categories_path)
      end
    end

    context "tenant isolation" do
      it "returns 404 when the category belongs to another commerce" do
        user = create(:user)
        sign_in user
        foreign = create(:product_category, commerce: create(:commerce))

        delete "/app/products/categories/#{foreign.id}"

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
