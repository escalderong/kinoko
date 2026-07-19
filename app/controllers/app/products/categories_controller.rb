module App
  module Products
    class CategoriesController < App::BaseController
      def index
        authorize ProductCategory
        @categories = policy_scope(ProductCategory).asc(:name).to_a
        @category = ProductCategory.new
      end

      def create
        @category = current_user.commerce.product_categories.new(category_params)
        authorize @category

        if @category.save
          redirect_to app_products_categories_path
        else
          redirect_to app_products_categories_path, flash: { error: @category.errors.full_messages.to_sentence }
        end
      end

      def update
        @category = current_user.commerce.product_categories.find(params[:id])
        authorize @category

        if @category.update(category_params)
          redirect_to app_products_categories_path
        else
          redirect_to app_products_categories_path, flash: { error: @category.errors.full_messages.to_sentence }
        end
      end

      def destroy
        @category = current_user.commerce.product_categories.find(params[:id])
        authorize @category
        @category.destroy
        redirect_to app_products_categories_path
      end

      private

      def category_params
        params.require(:product_category).permit(:name, :icon)
      end
    end
  end
end
