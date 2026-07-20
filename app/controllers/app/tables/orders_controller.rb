module App
  module Tables
    class OrdersController < App::BaseController
      include OrderItemPersistence

      DUPLICATE_KEY_ERROR_CODE = 11_000
      private_constant :DUPLICATE_KEY_ERROR_CODE

      def create
        authorize Order
        table = policy_scope(Table).find(params[:table_id])

        if Order.open_for(table).exists?
          return redirect_to app_tables_path, flash: { error: t("app.tables.orders.already_open") }
        end

        line_items = build_line_items_or_redirect
        return unless line_items

        order = Order.new(table: table, opened_at: Time.current)

        if persist_order(order, line_items)
          redirect_to app_tables_path, flash: { success: t("app.tables.orders.created") }
        else
          redirect_to app_tables_path, flash: { error: order.errors.full_messages.to_sentence.presence || t("app.tables.orders.create_failed") }
        end
      end

      private

      # Persists the order itself, then its items via
      # OrderItemPersistence#persist_order_items. Unlike adding items to an
      # already-open order, this order is brand new and has no pre-existing
      # items to preserve, so a failure here rolls back the whole order (the
      # shared concern already cleaned up any items it created).
      def persist_order(order, line_items)
        return false unless order.save
        return true if persist_order_items(order, line_items)

        order.destroy
        false
      rescue Mongo::Error::OperationFailure => e
        raise unless e.code == DUPLICATE_KEY_ERROR_CODE

        # The exists? guard above is a TOCTOU race on its own — two requests
        # can both pass it before either saves. Order's partial unique index
        # is what actually closes the race; this is that race being hit.
        order.errors.add(:base, t("app.tables.orders.already_open"))
        false
      end
    end
  end
end
