Rails.application.routes.draw do
	resources :communities

	root 'pages#index'
	get 'pages/user_index'

	devise_for :users, controllers:{
		registrations: 'users/registrations'
	}
	get 'pages/index'
	get 'communities/join/:id', to: 'communities#join', as:'join_community'
	get 'communities/leave/:id', to: 'communities#leave', as:'leave_community'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end