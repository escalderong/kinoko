module App
  module Settings
    class FloorZonesController < App::BaseController
      def create
        @floor_zone = current_user.commerce.floor_zones.new(floor_zone_params)
        authorize @floor_zone
        @floor_zone.position = (current_user.commerce.floor_zones.max(:position) || -1) + 1

        if @floor_zone.save
          redirect_to app_settings_tables_path(zone: @floor_zone.id)
        else
          redirect_to app_settings_tables_path, flash: { error: @floor_zone.errors.full_messages.to_sentence }
        end
      end

      def update
        @floor_zone = current_user.commerce.floor_zones.find(params[:id])
        authorize @floor_zone
        @floor_zone.update(floor_zone_params)
        redirect_to app_settings_tables_path(zone: @floor_zone.id)
      end

      def destroy
        @floor_zone = current_user.commerce.floor_zones.find(params[:id])
        authorize @floor_zone
        @floor_zone.destroy
        redirect_to app_settings_tables_path
      end

      private

      def floor_zone_params
        params.require(:floor_zone).permit(:name)
      end
    end
  end
end
