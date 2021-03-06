Rails.application.routes.draw do

  #API
  namespace "api" do
    namespace "v1" do
      get "market_searches/results" => "market_searches#results"
      resources :market_searches, only: [:new]
    end
  end

  # CUSTOM ROUTES *** MUST BE MENTIONED HERE BEFORE "resources"
  get "searches/all_orgs" => "searches#all_orgs"
  get "searches/competitors" => "searches#competitors"
  get "searches/clients" => "searches#clients"
  get "searches/suppliers" => "searches#suppliers"
  get "market_searches/results" => "market_searches#results"

  # USER ADMIN
  get "/signup" => "users#new"
  post "/users" => "users#create"
  get "/login" => "sessions#new"
  post "/login" => "sessions#create"
  get "/logout" => "sessions#destroy"

  resources :users, only: [:update]

  resources :settings, only: [:index, :edit]

  root "welcome#index"

  resources :priorities
  resources :categories

  resources :organizations do
    resources :products, only: [:create, :index, :update, :destroy]
  end

  # ANALYSES
  resources :comparisons
  resources :searches
  resources :market_searches

  # OTHER
  resources :location_levels, only: [:create, :index, :update, :destroy]
  get "location_levels/get_all" => "location_levels#get_all"
  # post "location_levels/save" => "location_levels#save"

  #index
  #create
  #new
  #edit
  #show
  #update
  #destroy
  
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
