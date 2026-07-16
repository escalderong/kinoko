module App
  class PreferencesController < App::BaseController
    def update
      current_user.update(locale: params[:locale])
      cookies[:locale] = { value: current_user.locale, expires: 1.year, same_site: :lax }
      redirect_back fallback_location: app_orders_path
    end
  end
end
