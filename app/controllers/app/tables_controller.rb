module App
  class TablesController < App::BaseController
    def index
      authorize current_commerce, :view_tables?
      @zones = policy_scope(FloorZone).order(:position).to_a
      tables = policy_scope(Table).to_a
      @tables_by_zone = tables.group_by(&:floor_zone_id)
      @active_zone = @zones.find { |zone| zone.id.to_s == params[:zone].to_s } || @zones.first
      @open_table_ids = Order.open.where(table_id: tables.map(&:id)).distinct.pluck(:table_id).to_set
    end

    def show
      authorize current_commerce, :view_tables?
      @table = policy_scope(Table).find(params[:id])
      @order = Order.open_for(@table).includes(order_items: %i[order_item_variants order_item_modifiers]).first
      @catalog_entries = CatalogQuery.new(current_commerce).visible_entries
      render layout: false if turbo_frame_request?
    end
  end
end
