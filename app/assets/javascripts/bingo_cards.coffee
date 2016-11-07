# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

numbers = []
checks = []
notice = []
number_length = 0
condition = 0

$(->
	room_id = $("#data").data("room_id")
	for i in [0..24]
		checks.push(false)
	@onPageLoad()
	@update_notice = setInterval(display_notice,1000)
	@update_numbers = setInterval(->
		@numbers_update(room_id)
		update_list()
	,5000)
)

game_start_check = (room_id) ->
	@check_condition()
	if condition == 1
		notice.push("ゲームが始まりました")

display_notice = ->
	if notice.length != 0
		n = notice.shift()
		$('#notice').empty()
		$('#notice').text(n)
		$('#notice').show('slow')
		setTimeout(->
			if $('#notice').text() == n
				$('#notice').hide('slow')
				$('#notice').empty()
		,5000)

@numbers_update = (room_id) ->
	$.ajaxSetup({async: false});
	$.getJSON('/API/get_number', {room_id: room_id}, (json) ->
		numbers = json
		return
	)
	return
@checks_update = (room_id) ->
	$.ajaxSetup({async: false});
	$.getJSON('/API/get_checked_number',{room_id: room_id},(json)->
		checks = []
		for check, index in json
			checks.push(check == 't')
		return
	)
	return

@check_condition = (room_id) ->
	$.ajaxSetup({async: false});
	$.getJSON('/API/check_condition',{room_id: room_id},(json)->
		condition = json
		return
	)
	return

update_list = ->
	if number_length isnt numbers.length
		if numbers[number_length-1] isnt -1
			notice.push("新しいナンバーは "+ numbers[numbers.length-1] + "です")

		number_length = numbers.length
		$('ul#number_list').empty()
		for number, index in numbers when number isnt -1 and index isnt number_length-1
			$('ul#number_list').prepend("<li> #{number} </li>")
		$('#last_number').empty()
		if numbers[number_length-1] isnt -1
			$('#last_number').text(numbers[number_length-1])

@check_number = (room_id,index) ->
	$.ajaxSetup({async: false});
	$.getJSON('/API/check_number',{room_id: room_id, index: index},(json)->
		checks[index] = (json[index] == 't')
	)
	return
@number_click = (obj, room_id, index) ->
	if jQuery.inArray(Number($(obj).data('number')), numbers) >= 0
		@check_number(room_id, index)
		$(obj).toggleClass("checked", checks[index])
		if check_bingo()
			$('#bingo_button').show()
		else
			$('#bingo_button').hide()
	return

@onPageLoad = ->
	room_id = $("#data").data("room_id")
	@numbers_update(room_id)
	@checks_update(room_id)
	$('.bingo_number').each( (i,e)->
		if jQuery.inArray(Number($(e).data('number')), numbers) >= 0
			$(e).toggleClass("checked", checks[i])
	)
	update_list()
	return
@display_past_number = ->
	$('#number_list_wrapper').toggle('slow')

check_bingo = ->
	console.log(checks)
	# Alignment bingocard sequence
	# 0  1  2  3  4
	# 5  6  7  8  9
	# 10 11 12 13 14
	# 15 16 17 18 19
	# 20 21 22 23 24

#check horizontal line
	for i in[0..4]
		if checks[i*5+0] && checks[i*5+1] && checks[i*5+2] && checks[i*5+3] && checks[i*5+4]
			return true
#check vertical line
	for i in[0..4]
		if checks[i+0] && checks[i+5] && checks[i+10] && checks[i+15] && checks[i+20]
			return true
#check diagonal line
	if checks[0] && checks[6] && checks[12] && checks[18] && checks[24]
		return true
	if checks[4] && checks[8] && checks[12] && checks[16] && checks[20]
		return true
	return false

