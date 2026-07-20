module TableBroadcaster
  extend ActiveSupport::Concern

  private

  def broadcast_table_update(table)
    Turbo::StreamsChannel.broadcast_replace_to(
      "commerce_#{table.commerce_id}_tables",
      target: ActionView::RecordIdentifier.dom_id(table),
      partial: "app/tables/table",
      locals: { table: table, open: Order.open_for(table).exists? }
    )
  rescue StandardError => e
    # A broadcast is a best-effort live update, not the source of truth (the
    # order/item write above this callback already succeeded) — a transient
    # broadcast failure (e.g. Redis unavailable in production) shouldn't fail
    # the request that triggered it. Logged so a wave of these is visible
    # rather than silently leaving every connected table view stale.
    Rails.logger.error("[TableBroadcaster] failed to broadcast table #{table.id}: #{e.class}: #{e.message}")
  end
end
