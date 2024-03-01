Rails.application.routes.draw do
mount SolidusPaypalCommercePlatform::Engine, at: '/solidus_paypal_commerce_platform'
  mount Spree::Core::Engine, at: '/spree'

  root to: 'home#index'
  resources :products, only: :show
  resources :categories, only: :show
  resources :cart, only: :index, controller: 'cart'
end
