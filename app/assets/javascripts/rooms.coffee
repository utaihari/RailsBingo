# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

rate = []
bingo_users = []

$(->
	@community_id = $("#data").data("community_id")
	@room_id = $("#data").data("room_id")
	@condition = $("#data").data("condition")
	console.log(@condition)
	if @condition == true
        @check_bingo = setInterval(->
        	check_bingo_users(room_id)
        ,5000)
)

@rate_update =(room_id) ->
	$.ajaxSetup({async: false});
	$.getJSON('/API/get_number_rate', {room_id: room_id}, (json) ->
		rate = json
		return
		)
	return

@get_random_number = ->
	numbers = []
	for r, index in rate
		for i in [0...r]
			numbers.push(index + 1)
	if numbers.length == 0
		$('#number-display').text("全ての数字が出力されました")
		return
	return numbers[Math.floor(Math.random() * numbers.length)]

@add_number =(room_id, number) ->
	$.post('/API/add_number', {room_id: room_id, number: number}, (data) ->
		return
		)
	return

@random_number_add =(room_id) ->
	@rate_update(room_id)
	number = @get_random_number()
	@add_number(room_id, number)
	$('#number-display').text(number)
	return

@start_game = (room_id) ->
	$.get("/API/#{@community_id}/#{room_id}/game_main")
	condition = 1
	return

bingo_users_length = 0
@bingo_users_window
check_bingo_users  = (room_id) ->
	$.ajaxSetup({async: false});
	$.getJSON('/API/check_bingo_users',{room_id: room_id},(json)->
		bingo_users = json
	)

	if bingo_users_length isnt bingo_users.length
		bingo_users_length = bingo_users.length
		$('#bingo-user-list').empty()
		for user, index in bingo_users
			$('#bingo-user-list').prepend("<div> #{user.name}, #{user.times}回目, #{user.seconds}ms </div>")
	if @bingo_users_window? && !@bingo_users_window.closed
		list = @bingo_users_window.document.getElementById('bingo-user-list')
		$(list).empty()
		for user, index in bingo_users
			$(list).prepend("<div> #{user.name}, #{user.times}回目, #{user.seconds}ms </div>")
	return

@view_mail_address =(obj) ->
	$(obj).children('.view-mail-addess').toggle()
	return

@open_bingo_users_window = (obj)->
	@bingo_users_window = window.open(obj.href, "ビンゴリスト", 'height=300, width=400')
	return


