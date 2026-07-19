module App
  class TablesController < App::BaseController
    def index
      authorize current_commerce, :view_tables?
      @zones = policy_scope(FloorZone).asc(:position).to_a
      tables = policy_scope(Table).to_a
      @tables_by_zone = tables.group_by(&:floor_zone_id)
      @active_zone = @zones.find { |zone| zone.id.to_s == params[:zone].to_s } || @zones.first
      @open_table_ids = Order.open.where(:table_id.in => tables.map(&:id)).distinct(:table_id).to_set
    end
  end
end
