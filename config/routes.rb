Rails.application.routes.draw do
  # Authentication
  resource :session, only: [ :new, :create, :destroy ]
  resource :registration, only: [ :new, :create ]
  resource :password, only: [ :new, :create, :edit, :update ]
  get "confirm/:token", to: "confirmations#show", as: :confirm_email
  resource :confirmation, only: [ :new, :create ]

  # Dashboard (authenticated users)
  get "dashboard", to: "dashboard#show", as: :dashboard

  # Health check for load balancers and uptime monitors
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Root path
  root "sessions#new"
end
