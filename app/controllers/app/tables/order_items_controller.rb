module App
  module Tables
    class OrderItemsController < App::BaseController
      include OrderItemPersistence

      def create
        authorize Order, :create?
        table = policy_scope(Table).find(params[:table_id])
        order = Order.open_for(table).first

        if order.nil?
          return redirect_to app_tables_path, flash: { error: t("app.tables.orders.no_open_order") }
        end

        line_items = build_line_items_or_redirect
        return unless line_items

        if persist_order_items(order, line_items)
          redirect_to app_tables_path, flash: { success: t("app.tables.orders.items_added") }
        else
          redirect_to app_tables_path, flash: { error: t("app.tables.orders.create_failed") }
        end
      end
    end
  end
end
