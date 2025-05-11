Rails.application.routes.draw do
  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"

  # Web routes
  resource :session
  resources :users
  resources :passwords, param: :token

  # API routes
  namespace :api do
    namespace :v1 do
      # Mount ActionCable server at /api/v1/cable
      mount ActionCable.server => "/cable"

      # Authentication routes
      resources :users, only: [ :show, :create, :update ]
      resources :sessions, only: [ :create, :destroy ]
      resources :repairer_sessions, only: [ :create, :destroy ]

      # Token refresh endpoint
      post "token/refresh", to: "token#refresh"

      resource :profile, only: [ :show, :update ], controller: :profiles
      resources :bookings
      resources :appliances do
        member do
          get :bookings
        end
        collection do
          get :my_appliances
        end
      end
      resources :messages, only: [ :create ]
      resources :bookings, only: [] do
        resources :messages, only: [ :index ]
      end

      # Customer information routes
      resources :customers, only: [ :index, :show ] do
        member do
          get :bookings
        end
      end

      resources :repairers, only: [] do
        member do
          get "calendar/:year/:month", to: "repairers#calendar"
          post "upload_profile_picture"
          post "upload_work_image"
          delete "delete_work_image"
        end
        collection do
          get "nearby"
        end
        resources :reviews, only: [ :index, :create ]
      end

      # Repairer bookings routes
      namespace :repairer do
        resources :bookings, only: [ :index, :show, :update ] do
          member do
            post :notes
          end
        end
      end
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "users#new"
end
