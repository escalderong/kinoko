class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  add_flash_types :success, :info, :warning, :error

  around_action :switch_locale

  AVAILABLE_LOCALES = I18n.available_locales.map(&:to_s).freeze

  private

  # Signed-in users carry their locale on the User record; the cookie exists
  # to remember that choice while signed out (e.g. on the login page after
  # logout), since there's no current_user to read from at that point.
  def switch_locale(&action)
    I18n.with_locale(resolve_locale, &action)
  end

  def resolve_locale
    if current_user
      current_user.locale.presence || I18n.default_locale.to_s
    else
      cookies[:locale].presence_in(AVAILABLE_LOCALES) || I18n.default_locale.to_s
    end
  end
end
