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

    def destroy_with_flash(record, redirect_path)
      if record.destroy
        redirect_to redirect_path
      else
        redirect_to redirect_path, flash: { error: record.errors.full_messages.to_sentence }
      end
    end
  end
end
