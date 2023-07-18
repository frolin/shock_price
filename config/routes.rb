Rails.application.routes.draw do
  require 'sidekiq/web'
  require 'sidekiq/cron/web'

  telegram_webhook TelegramController
  mount Sidekiq::Web => '/sidekiq'

  resources :discounts
  # Defines the root path route ("/")
  # root "articles#index"
end
