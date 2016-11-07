# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

rate = []
@rate_update =(room_id,community_id) ->
	$.ajaxSetup({async: false});
	$.getJSON('/API/get_number_rate', {room_id: room_id,community_id: community_id}, (json) ->
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
		$('#number_display').text("全ての数字が出力されました")
		return
	return numbers[Math.floor(Math.random() * numbers.length)]

@add_number =(room_id, community_id, number) ->
	$.post('/API/add_number', {room_id: room_id,community_id: community_id, number: number}, (data) ->
		return
		)
	return

@random_number_add =(room_id,community_id) ->
	@rate_update(room_id,community_id)
	number = @get_random_number()
	@add_number(room_id,community_id,number)
	$('#number_display').text(number)
	return

@start_game = (room_id) ->
	$.post('/API/start_game', {room_id: room_id}, (data) ->
		return
		)
	location.reload();
	return