Rails.application.routes.draw do
  # Authentication
  resource :session, only: [ :new, :create, :destroy ]
  resource :registration, only: [ :new, :create ]
  resource :password, only: [ :new, :create, :edit, :update ]
  get "confirm/:token", to: "confirmations#show", as: :confirm_email
  resource :confirmation, only: [ :new, :create ]

  # Dashboard (authenticated users)
  get "dashboard", to: "dashboard#show", as: :dashboard

  # Settings
  get "settings", to: "settings#show"
  patch "settings", to: "settings#update"
  delete "settings", to: "settings#destroy"
  patch "settings/password", to: "settings#update_password", as: :settings_password

  # Newsletters
  resources :newsletters do
    member do
      get :preview
      get :confirm_send
      post :send_newsletter
      post :schedule
      patch :update_tags
    end
  end

  # Subscribers
  resources :subscribers do
    collection do
      get :import
      post :process_import
    end
  end

  # Tags
  resources :tags, only: [ :index, :create, :destroy ]

  # Public routes (no authentication required)
  get "unsubscribe/:token", to: "unsubscribes#show", as: :unsubscribe
  post "unsubscribe/:token", to: "unsubscribes#create"
  get "newsletters/:id/view/:token", to: "public_newsletters#show", as: :public_newsletter

  # Health check for load balancers and uptime monitors
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Root path
  root "sessions#new"
end
