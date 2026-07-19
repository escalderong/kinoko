module App
  module Settings
    class TablesController < App::BaseController
      def index
        authorize Table
        @zones = policy_scope(FloorZone).asc(:position).to_a
        @tables_by_zone = policy_scope(Table).to_a.group_by(&:floor_zone_id)
        @active_zone = @zones.find { |zone| zone.id.to_s == params[:zone].to_s } || @zones.first
      end

      def create
        zone = current_commerce.floor_zones.find(params[:table][:floor_zone_id])
        @table = zone.tables.new(table_params.merge(commerce: current_commerce, pos_x: zone.next_table_x, pos_y: 0))
        authorize @table

        if @table.save
          redirect_to app_settings_tables_path(zone: zone.id)
        else
          redirect_to app_settings_tables_path(zone: zone.id), flash: { error: @table.errors.full_messages.to_sentence }
        end
      end

      def update
        @table = current_commerce.tables.find(params[:id])
        authorize @table

        respond_to do |format|
          if @table.update(table_params)
            format.json { head :ok }
            format.html { redirect_to app_settings_tables_path(zone: @table.floor_zone_id) }
          else
            format.json { head :unprocessable_entity }
            format.html do
              redirect_to app_settings_tables_path(zone: @table.floor_zone_id), flash: { error: @table.errors.full_messages.to_sentence }
            end
          end
        end
      end

      def destroy
        @table = current_commerce.tables.find(params[:id])
        authorize @table
        @table.destroy
        redirect_to app_settings_tables_path(zone: @table.floor_zone_id)
      end

      private

      def table_params
        params.require(:table).permit(:number, :capacity, :pos_x, :pos_y, :width, :height, :status, :floor_zone_id)
      end
    end
  end
end
