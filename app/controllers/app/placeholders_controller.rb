module App
  class PlaceholdersController < App::BaseController
    def show
      @section = params[:section]
      render "app/shared/coming_soon"
    end
  end
end
