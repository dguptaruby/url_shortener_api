Rails.application.routes.draw do
  resources :urls do
    collection do
      get :top
    end
  end
  get '/:short_url', to: 'urls#show'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
