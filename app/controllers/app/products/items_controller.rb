module App
  module Products
    class ItemsController < App::BaseController
      def index
        authorize Product
        @categories = policy_scope(ProductCategory).asc(:name).to_a
        @products_by_category = policy_scope(Product).asc(:name).to_a.group_by(&:product_category_id)
        @product = Product.new
      end

      def edit
        @product = current_commerce.products.find(params[:id])
        authorize @product
        @variant_groups = @product.variant_groups.to_a
        @modifier_groups = @product.modifier_groups.to_a
      end

      def create
        @product = current_commerce.products.new(item_params)
        @product.product_category = scoped_category
        @product.base_price = parsed_price
        authorize @product

        if @product.save
          redirect_to app_products_items_path
        else
          redirect_to app_products_items_path, flash: { error: @product.errors.full_messages.to_sentence }
        end
      end

      def update
        @product = current_commerce.products.find(params[:id])
        authorize @product
        @product.assign_attributes(item_params)
        @product.product_category = scoped_category
        @product.base_price = parsed_price

        if @product.save
          redirect_to app_products_items_path
        else
          redirect_to app_products_items_path, flash: { error: @product.errors.full_messages.to_sentence }
        end
      end

      def destroy
        @product = current_commerce.products.find(params[:id])
        authorize @product
        @product.destroy
        redirect_to app_products_items_path
      end

      private

      def item_params
        params.require(:product).permit(:name, :is_active)
      end

      # Ensures the category belongs to the current commerce (404 otherwise).
      def scoped_category
        current_commerce.product_categories.find(params[:product][:product_category_id])
      end

      def parsed_price
        amount = params.dig(:product, :base_price).presence || "0"
        Money.from_amount(BigDecimal(amount, exception: false) || 0, Product::CURRENCY)
      end
    end
  end
end
