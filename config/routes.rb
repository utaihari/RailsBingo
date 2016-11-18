Rails.application.routes.draw do

	get 'rooms/result'

	root 'pages#index'
	get 'pages/index'
	get 'pages/user_index'

	get 'communities/:community_id/rooms/:room_id/card_create', to: 'bingo_cards#create', as:'community_room_bingo_cards'
	get 'communities/:community_id/rooms/:room_id/result', to: 'rooms#result', as:'community_room_result'
	get 'communities/:community_id/rooms/:room_id/bingo_cards/:bingo_card_id/result', to: 'bingo_cards#result', as:'community_room_bingo_card_result'

	resources :communities do
		resources :rooms do
			resources :bingo_cards, :only => [:show]
		end
	end


	devise_for :users, controllers:{
		registrations: 'users/registrations'
	}
	devise_scope :user do
		post '/users/direct/:community_id/:room_id', to: 'devise/registrations#create', as:'user_registrations_direct_game'
		get '/users/direct/sign_up/:community_id/:room_id/:isGuest', to: 'users/registrations#new', as:'new_user_registrations_direct_game'
		post '/users/direct/sign_in/:community_id/:room_id', to: 'devise/sessions#create', as:'user_session_direct_game'
		get '/users/direct/sign_in/:community_id/:room_id/', to: 'users/sessions#new', as:'new_user_session_direct_game'
	end

	get 'communities/:id/join', to: 'communities#join', as:'join_community'
	get 'communities/:id/leave', to: 'communities#leave', as:'leave_community'
	get 'communities/:community_id/rooms/:room_id/pre-join', to: 'rooms#pre_join', as:'pre_join_room'
	get 'communities/:community_id/rooms/:room_id/join', to: 'rooms#join', as:'join_room'

	#TOOLS
	get 'TOOLS/number-generator/:room_id', to: 'rooms#tool_number-generator', as:'tool_number-generator'
	get 'TOOLS/qr-code/:room_id', to: 'rooms#tool_qr-code', as:'tool_qr-code'
	get 'TOOLS/bingo-users/:room_id', to: 'rooms#tool_bingo-users', as:'tool_bingo-users'
	get 'TOOLS/bingo-card/:card_id', to: 'bingo_cards#tool_bingo-card', as:'tool_bingo-card'

	#API

	get 'API/get_number', to: 'rooms#get_number',as:'get_number'
	get 'API/get_number_rate', to: 'rooms#get_number_rate',as:'get_number_rate'
	post 'API/add_number', to: 'rooms#add_number',as:'add_number'
	get 'API/check_condition', to: 'rooms#check_condition',as:'check_condition'
	post 'API/start_game', to: 'rooms#start_game',as:'start_game'
	post 'API/game_close', to: 'rooms#game_close',as:'game_close'
	get 'API/check_number', to: 'bingo_cards#check_number',as:'check_number'
	get 'API/get_checked_number', to: 'bingo_cards#get_checked_number',as:'get_checked_number'
	post '/API/done_bingo', to: 'bingo_cards#done_bingo', as: 'done_bingo'
	get '/API/check_rank', to: 'rooms#check_rank'
	get '/API/check_bingo_users', to: 'rooms#check_bingo_users'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end