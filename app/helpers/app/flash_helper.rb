module App::FlashHelper
  INFO_ICON = "M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
  SUCCESS_ICON = "M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"
  WARNING_ICON = "M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"
  ERROR_ICON = "M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z"

  FLASH_STYLES = {
    "notice" => { class: "alert-info", icon: INFO_ICON },
    "info" => { class: "alert-info", icon: INFO_ICON },
    "success" => { class: "alert-success", icon: SUCCESS_ICON },
    "warning" => { class: "alert-warning", icon: WARNING_ICON },
    "alert" => { class: "alert-error", icon: ERROR_ICON },
    "error" => { class: "alert-error", icon: ERROR_ICON }
  }.freeze

  def app_flash_messages
    flash.filter_map do |type, message|
      style = FLASH_STYLES[type.to_s]
      [ message, style ] if style
    end
  end
end
