Rails.application.routes.draw do

  get 'bingo_cards/create'

  get 'bingo_cards/show'

	root 'pages#index'
	get 'pages/index'
	get 'pages/user_index'

	resources :communities do
		resources :rooms do
			resources :bingo_cards, :only => [:show]
		end
	end

	get 'communities/:community_id/rooms/:room_id/bingo_cards/create', to: 'bingo_cards#create', as:'community_room_bingo_cards'
	devise_for :users, controllers:{
		registrations: 'users/registrations'
	}

	get 'communities/:id/join', to: 'communities#join', as:'join_community'
	get 'communities/:id/leave', to: 'communities#leave', as:'leave_community'
	get 'communities/:community_id/rooms/:room_id/join', to: 'rooms#join', as:'join_room'


#API
	get 'communities/:community_id/rooms/:room_id/add/:number', to: 'rooms#add_number',as:'add_number'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end