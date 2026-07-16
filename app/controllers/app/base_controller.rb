module App
  class BaseController < ApplicationController
    include Pundit::Authorization

    before_action :authenticate_user!

    layout "app"

    rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

    private

    def user_not_authorized
      flash[:error] = t("app.errors.not_authorized")
      redirect_back fallback_location: app_orders_path
    end
  end
end
