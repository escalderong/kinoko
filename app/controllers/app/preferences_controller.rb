module App
  class PreferencesController < App::BaseController
    layout false

    def edit
      render layout: "layouts/app/modal"
    end

    def update
      current_user.update(locale: locale_param) if locale_param.present?

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to request.referer || app_orders_path }
      end
    end

    private

    def locale_param
      requested = params.dig(:user, :locale)
      requested if I18n.available_locales.map(&:to_s).include?(requested)
    end
  end
end
