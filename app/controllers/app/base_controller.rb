module App
  class BaseController < ApplicationController
    include Pundit::Authorization

    before_action :authenticate_user!
    before_action :set_locale

    layout "app"

    rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

    private

    def set_locale
      I18n.locale = current_user&.locale.presence || I18n.default_locale
    end

    def user_not_authorized
      flash[:alert] = t("app.errors.not_authorized")
      redirect_back fallback_location: app_orders_path
    end
  end
end
