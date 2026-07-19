Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  namespace :app, module: "app" do
    root to: "home#show"

    # Each section is a placeholder served by a single generic controller.
    # Distinct named path helpers (app_orders_path, app_tables_path, ...) all
    # map to PlaceholdersController#show via `defaults: { section: ... }`.
    get "orders",              to: "placeholders#show", as: :orders,              defaults: { section: "orders" }
    resources :tables, only: :index
    namespace :settings do
      resources :tables,      only: %i[index create update destroy]
      resources :floor_zones, only: %i[create update destroy]
      resource  :appearance,  only: %i[show update], controller: "appearance"
    end
    namespace :products do
      resources :categories, only: %i[index create update destroy]
      resources :items, only: %i[index edit create update destroy] do
        resources :variant_groups, only: %i[create update destroy] do
          resources :variants, only: %i[create update destroy]
        end
        resources :modifier_groups, only: %i[create update destroy] do
          resources :modifiers, only: %i[create update destroy]
        end
      end
    end
    get "settings",            to: "placeholders#show", as: :settings,            defaults: { section: "settings" }
    get "users",               to: "placeholders#show", as: :users,              defaults: { section: "users" }

    # Locale switcher — singular resource scoped to current_user.
    resource :preferences, only: %i[update], controller: "preferences"
  end

  # Defines the root path route ("/")
  authenticated :user do
    root to: redirect("/app/orders"), as: :authenticated_root
  end

  unauthenticated do
    # Minimal placeholder: send guests to login. No marketing page in this change.
    root to: redirect { |_params, _req| Rails.application.routes.url_helpers.new_user_session_path }, as: :unauthenticated_root
  end
end
