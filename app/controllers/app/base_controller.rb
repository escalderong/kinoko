module App
  class BaseController < ApplicationController
    include Pundit::Authorization

    before_action :authenticate_user!
    around_action :switch_locale

    layout "app"

    rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

    private

    def switch_locale(&action)
      locale = current_user&.locale.presence || I18n.default_locale
      I18n.with_locale(locale, &action)
    end

    def user_not_authorized
      flash[:error] = t("app.errors.not_authorized")
      redirect_back fallback_location: app_orders_path
    end
  end
end
