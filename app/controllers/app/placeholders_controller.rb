module App
  class PlaceholdersController < App::BaseController
    SECTION_AUTHORIZATIONS = {
      "settings" => :settings?,
      "users" => :manage_users?
    }.freeze

    def show
      @section = params[:section]
      authorize_section!
      render "app/shared/coming_soon"
    end

    private

    def authorize_section!
      policy_action = SECTION_AUTHORIZATIONS[@section]
      authorize current_user.commerce, policy_action if policy_action
    end
  end
end
