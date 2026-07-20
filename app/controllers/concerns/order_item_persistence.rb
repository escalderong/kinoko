# Shared by App::Tables::OrdersController (new order) and
# App::Tables::OrderItemsController (add items to an already-open order):
# parses the cart JSON payload and persists it as OrderItem records plus
# their variant/modifier snapshots.
#
# Mongoid does not autosave referenced has_many associations, so persistence
# walks top-down (item, then its variant/modifier snapshots) one record at a
# time. On any failure, #persist_order_items rolls back only the records
# *this call* created — it never touches the order itself or any items that
# already existed on it. That makes it safe to call against a brand-new,
# not-yet-persisted-content order (nothing to preserve, so the caller may
# destroy the whole order on failure) or an existing order that already has
# other items (which must be preserved, so the caller should NOT destroy the
# order on failure — see App::Tables::OrdersController#persist_order vs.
# App::Tables::OrderItemsController#create).
module OrderItemPersistence
  extend ActiveSupport::Concern

  private

  def parsed_cart
    JSON.parse(params[:cart].presence || "[]").map(&:deep_symbolize_keys)
  rescue JSON::ParserError
    raise OrderCartBuilder::InvalidCartError, t("app.tables.orders.invalid_cart")
  end

  # Builds line items from the submitted cart, or redirects with a flash
  # error and returns nil — the caller should `return` as soon as this
  # returns nil, before doing anything else with the (would-be) order.
  def build_line_items_or_redirect
    line_items = OrderCartBuilder.new(commerce: current_commerce, cart_params: parsed_cart).build
    return redirect_with_error(t("app.tables.orders.empty_cart")) if line_items.blank?

    line_items
  rescue OrderCartBuilder::InvalidCartError => e
    redirect_with_error(e.message)
  end

  def redirect_with_error(message)
    redirect_to app_tables_path, flash: { error: message }
    nil
  end

  def persist_order_items(order, line_items)
    created_items = []

    line_items.each do |line|
      order_item = order.order_items.create(
        product_name: line[:product_name],
        base_price: line[:base_price],
        quantity: line[:quantity]
      )

      return rollback_created_items(created_items) unless order_item.persisted?

      created_items << order_item

      line[:variants].each do |attrs|
        return rollback_created_items(created_items) unless order_item.order_item_variants.create(attrs).persisted?
      end

      line[:modifiers].each do |attrs|
        return rollback_created_items(created_items) unless order_item.order_item_modifiers.create(attrs).persisted?
      end
    end

    true
  end

  def rollback_created_items(created_items)
    created_items.each(&:destroy)
    false
  end
end
