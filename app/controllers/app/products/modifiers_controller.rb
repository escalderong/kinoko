module App
  module Products
    class ModifiersController < App::BaseController
      def create
        authorize product, :update?
        modifier = modifier_group.modifiers.new(modifier_params)
        modifier.price_delta = parsed_price_delta
        persist(modifier)
      end

      def update
        authorize product, :update?
        modifier = modifier_group.modifiers.find(params[:id])
        modifier.assign_attributes(modifier_params)
        modifier.price_delta = parsed_price_delta
        persist(modifier)
      end

      def destroy
        authorize product, :update?
        modifier_group.modifiers.find(params[:id]).destroy
        redirect_to edit_app_products_item_path(product)
      end

      private

      def product
        @product ||= current_commerce.products.find(params[:item_id])
      end

      def modifier_group
        @modifier_group ||= product.modifier_groups.find(params[:modifier_group_id])
      end

      def modifier_params
        params.require(:modifier).permit(:name)
      end

      def parsed_price_delta
        amount = params.dig(:modifier, :price_delta).presence || "0"
        Money.from_amount(BigDecimal(amount, exception: false) || 0, Product::CURRENCY)
      end

      def persist(modifier)
        if modifier.save
          redirect_to edit_app_products_item_path(product)
        else
          redirect_to edit_app_products_item_path(product), flash: { error: modifier.errors.full_messages.to_sentence }
        end
      end
    end
  end
end
