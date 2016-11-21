rate = []

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
