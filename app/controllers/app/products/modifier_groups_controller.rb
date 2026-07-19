module App
  module Products
    class ModifierGroupsController < App::BaseController
      def create
        authorize product, :update?
        group = product.modifier_groups.new(group_params)
        persist(group)
      end

      def update
        authorize product, :update?
        group = product.modifier_groups.find(params[:id])
        persist(group, group_params)
      end

      def destroy
        authorize product, :update?
        product.modifier_groups.find(params[:id]).destroy
        redirect_to edit_app_products_item_path(product)
      end

      private

      def product
        @product ||= current_user.commerce.products.find(params[:item_id])
      end

      def group_params
        params.require(:modifier_group).permit(:name, :is_required, :min_selected, :max_selected)
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
