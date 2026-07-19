module App
  module Settings
    class AppearanceController < App::BaseController
      def show
        @commerce = current_commerce
        authorize @commerce, :settings?
      end

      def update
        @commerce = current_commerce
        authorize @commerce, :settings?

        if @commerce.update(appearance_params)
          redirect_to app_settings_appearance_path, success: t("app.appearance.saved")
        else
          flash.now[:error] = t("app.appearance.invalid")
          render :show, status: :unprocessable_entity
        end
      end

      private

      def appearance_params
        params.require(:commerce).permit(:theme)
      end
    end
  end
end
