Rails.application.routes.draw do

  get 'rooms/result'

	root 'pages#index'
	get 'pages/index'
	get 'pages/user_index'

    # get 'API/:community_id/:room_id/add_number', to: 'rooms#add_number',as:'add_number'
    get 'communities/:community_id/rooms/:room_id/card_create', to: 'bingo_cards#create', as:'community_room_bingo_cards'

	#API


	resources :communities do
		resources :rooms do
			resources :bingo_cards, :only => [:show]
		end
	end


	devise_for :users, controllers:{
		registrations: 'users/registrations'
	}

	get 'communities/:id/join', to: 'communities#join', as:'join_community'
	get 'communities/:id/leave', to: 'communities#leave', as:'leave_community'
	get 'communities/:community_id/rooms/:room_id/join', to: 'rooms#join', as:'join_room'


    #API

    get 'API/get_number', to: 'rooms#get_number',as:'get_number'
    get 'API/get_number_rate', to: 'rooms#get_number_rate',as:'get_number_rate'
    post 'API/add_number', to: 'rooms#add_number',as:'add_number'
    get 'API/check_condition', to: 'rooms#check_condition',as:'check_condition'
    post 'API/start_game', to: 'rooms#start_game',as:'start_game'
    post 'API/game_close', to: 'rooms#game_close',as:'game_close'
    get 'API/check_number', to: 'bingo_cards#check_number',as:'check_number'
    get 'API/get_checked_number', to: 'bingo_cards#get_checked_number',as:'get_checked_number'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end