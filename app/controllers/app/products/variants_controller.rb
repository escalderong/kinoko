module App
  module Products
    class VariantsController < App::BaseController
      def create
        authorize product, :update?
        variant = variant_group.variants.new(variant_params)
        variant.price_delta = parsed_price_delta || Money.new(0, Product::CURRENCY)
        persist(variant)
      end

      def update
        authorize product, :update?
        variant = variant_group.variants.find(params[:id])
        variant.assign_attributes(variant_params)
        variant.price_delta = parsed_price_delta if parsed_price_delta
        persist(variant)
      end

      def destroy
        authorize product, :update?
        variant_group.variants.find(params[:id]).destroy
        redirect_to edit_app_products_item_path(product)
      end

      private

      def product
        @product ||= current_commerce.products.find(params[:item_id])
      end

      def variant_group
        @variant_group ||= product.variant_groups.find(params[:variant_group_id])
      end

      def variant_params
        params.require(:variant).permit(:name, :sku, :is_active)
      end

      def parsed_price_delta
        return unless params[:variant].key?(:price_delta)

        amount = params.dig(:variant, :price_delta).presence || "0"
        Money.from_amount(BigDecimal(amount, exception: false) || 0, Product::CURRENCY)
      end

      def persist(variant)
        if variant.save
          redirect_to edit_app_products_item_path(product)
        else
          redirect_to edit_app_products_item_path(product), flash: { error: variant.errors.full_messages.to_sentence }
        end
      end
    end
  end
end
