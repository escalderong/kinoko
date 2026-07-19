module App
  module Products
    class VariantGroupsController < App::BaseController
      def create
        authorize product, :update?
        group = product.variant_groups.new(group_params)
        persist(group)
      end

      def update
        authorize product, :update?
        group = product.variant_groups.find(params[:id])
        persist(group, group_params)
      end

      def destroy
        authorize product, :update?
        product.variant_groups.find(params[:id]).destroy
        redirect_to edit_app_products_item_path(product)
      end

      private

      def product
        @product ||= current_user.commerce.products.find(params[:item_id])
      end

      def group_params
        params.require(:variant_group).permit(:name, :is_required)
      end

      def persist(group, attributes = nil)
        saved = attributes ? group.update(attributes) : group.save
        if saved
          redirect_to edit_app_products_item_path(product)
        else
          redirect_to edit_app_products_item_path(product), flash: { error: group.errors.full_messages.to_sentence }
        end
      end
    end
  end
end
