Rails.application.routes.draw do
  # Root
  root to: redirect { |params, request|
    request.session[:user_id] ? "/dashboard" : "/login"
  }
  
  # Authentication
  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"
  
  # Company Registration
  get "signup", to: "companies#new"
  post "signup", to: "companies#create"
  
  # User Registration (via invite or company signup)
  get "register/:token", to: "registrations#new", as: :register
  post "register/:token", to: "registrations#create"
  
  # Email Verification
  get "verify/:token", to: "email_verifications#show", as: :verify_email
  
  # Dashboard
  get "dashboard", to: "dashboard#index"
  
  # Team Invites (authenticated)
  resources :invites, only: [:index, :create]
  
  # Feedback Requests (authenticated users)
  resources :feedback_requests, only: [:index, :create, :show]
  
  # Public Feedback Submission (no auth required)
  get "feedback/:token", to: "public_feedback#new", as: :public_feedback
  post "feedback/:token", to: "public_feedback#create"
  get "feedback/:token/thanks", to: "public_feedback#thanks", as: :feedback_thanks
  
  # View Received Feedback (authenticated)
  get "my-feedback", to: "feedback_summaries#show"
  
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end
