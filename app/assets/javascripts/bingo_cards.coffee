# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

numbers = []
checks = []
notice = []
notice_list = []
number_length = 0
condition = 0
number_arrive_time = new Date()
done_bingo = false

$(->
	$('#tab-container').easytabs()

	@room_id = $("#data").data("room_id")
	@card_id = $("#data").data("card_id")
	@community_id = $("#data").data("community_id")
	@get_item = $("#data").data("get_item")
	for i in [0..24]
		checks.push(false)
	@onPageLoad()
	@update_notice = setInterval(->
		display_notice()
	,1000)
	@start_check = setInterval(->
		game_start_check(room_id)
	,5000)
	if check_bingo()
		$('#bingo-button').show()
	else
		$('#bingo-button').hide()

	if @get_item
		$('[data-remodal-id=getitem]').remodal().open()
	return
)

game_start_check =  ->
	@check_condition()
	if condition == 1
		notice.push("ゲームが始まりました")
		change_item_detail()
		@update_numbers = setInterval(->
			@numbers_update()
			update_list()
		,5000)
		@end_check = setInterval(->
			game_end_check()
		,8000)
		clearInterval(@start_check)
	if condition == 2
		clearInterval(@start_check)
		game_end_check()
	return
game_end_check =  ->
	@check_condition()
	if condition == 2
		notice.push("ゲームが終了しました。")
		display_notice()
		clearInterval(@end_check)
		clearInterval(@update_numbers)
		clearInterval(@update_notice)
		check_rank()
		set_number_of_bingos()
		@update_result()
		$('#result').show('slow')
	return
display_notice = ->
	if notice.length != 0
		n = notice.shift()
		$('#notice').empty()
		$('#notice').text(n)
		# $('#notice').show('slow')
		# setTimeout(->
		# 	if $('#notice').text() == n
		# 		# $('#notice').hide('slow')
		# 		# $('#notice').empty()

		# ,5000)

		update_notice_list()
		notice_list.push(n)
	return

update_notice_list = ->
	$('#notice-list').empty()
	for n, index in notice_list
		$('#notice-list').prepend("<p> #{n} </p>")
	return

items = []
@update_items = ->
	$.get("/API/#{@community_id}/#{@room_id}/items")
	return
@update_result = ->
	$.get("/API/#{@community_id}/#{@room_id}/get_items/#{number_of_bingo}/#{number_of_one_left_line}/#{number_of_hole}")
	return
@update_bingo_card = ->
	$.get("/API/#{@community_id}/#{@room_id}/bingo_card")
	return
@show_notice_list = ->
	$('#notice-list').toggle('slow')
	return
@numbers_update =  ->
	$.ajaxSetup({async: false});
	$.getJSON('/API/get_number', {room_id: @room_id}, (json) ->
		numbers = json
		return
	)
	return
@checks_update = ->
	$.ajaxSetup({async: false});
	$.getJSON('/API/get_checked_number',{room_id: @room_id},(json)->
		checks = []
		for check, index in json
			checks.push(check == 't')
		return
	)
	return

@check_condition = ->
	$.ajaxSetup({async: false});
	$.getJSON('/API/check_condition',{room_id: @room_id},(json)->
		condition = json
		return
	)
	return

update_list = ->
	if number_length isnt numbers.length
		if numbers[numbers.length-1] isnt -1
			notice.push("新しいナンバーは "+ numbers[numbers.length-1] + "です")

		number_length = numbers.length
		$('ul#number-list').empty()
		for number, index in numbers when number isnt -1
			$('ul#number-list').prepend("<li> #{number} </li>")
		$('#last-number').empty()
		if numbers[number_length-1] isnt -1
			$('#last-number').text(numbers[number_length-1])
		number_arrive_time = new Date()
	return

@check_number = (index) ->
	checks[index] = true
	$.ajaxSetup({async: false});
	$.getJSON('/API/check_number',{room_id:@room_id, card_id: @card_id, index: index, riichi_lines: calc_number_of_riichi()},(json)->
		checks[index] = (json[index] == 't')
	)
	return
@number_click = (obj, index) ->
	if checks[index]
		return
	if jQuery.inArray(Number($(obj).data('number')), numbers) >= 0
		@check_number(index)
		$(obj).toggleClass("checked", checks[index])
		if check_bingo()
			$('#bingo-button').show()
		else
			$('#bingo-button').hide()
		return
	if choosing_number
		choosing_number = false
		use_item_select_number(using_item_id, $(obj).data('number'))

	return

@onPageLoad = ->
	room_id = $("#data").data("room_id")
	@numbers_update()
	@checks_update()
	# $('.bingo-number').each( (i,e)->
	# 	if jQuery.inArray(Number($(e).data('number')), numbers) >= 0
	# 		$(e).toggleClass("checked", checks[i])
	# 	return
	# )
	update_list()
	@update_items()
	return
@display_past_number = ->
	$('#number-list-wrapper').toggle('slow')
	return

@bingo = ->
	current_time = new Date()
	if !check_bingo || done_bingo
		return
	$.post('/API/done_bingo', {card_id: @card_id, room_id: @room_id, times: numbers.length, seconds: current_time-number_arrive_time}, (data) ->
		done_bingo = data
		if done_bingo
			$('#bingo-button').hide()
		return
		)
	return

@use_item = (item_id, update_card) ->

	room_id = @room_id
	community_id = @community_id

	$.ajaxSetup({async: false});
	$.getJSON('/API/use_item',{community_id: @community_id, room_id: @room_id, item_id: item_id},(json)->
		notice.push(json)
		if update_card
			$.get("/API/#{community_id}/#{room_id}/bingo_card")
		return
		)
	quantity = $('.quantity-'+item_id)
	q = parseInt(quantity.text())-1
	if q<=0
		$('.item-rows-'+item_id).hide()
	quantity.text(q)
	$('.q-'+item_id).text(q)
	return

@use_item_all = (item_id, update_card) ->

	room_id = @room_id
	community_id = @community_id

	$.ajaxSetup({async: false});
	$.getJSON('/API/use_item_all',{community_id: @community_id, room_id: @room_id, item_id: item_id},(json)->
		notice.push(json)
		if update_card
			$.get("/API/#{community_id}/#{room_id}/bingo_card")
		return
		)

	$('.item-rows-'+item_id).hide()

	return

@use_item_select_number = (item_id, number) ->
	$.ajaxSetup({async: false});
	s_notice = ""
	$.getJSON('/API/use_item',{community_id: @community_id, room_id: @room_id, item_id: item_id, number: number},(json)->
		notice.push(json)
		s_notice = json
		return
		)
	quantity = $('.quantity-'+item_id)
	q = parseInt(quantity.text())-1
	if q<=0
		$('.item-rows-'+item_id).hide()
	quantity.text(q)
	$('.q-'+item_id).text(q)
	return

choosing_number = false
using_item_id = 0

@select_number = (item_id) ->
	choosing_number = true
	using_item_id = item_id
	# .tabSwitch($('#card_area'), $('#items'))

	notice.push("アイテムを使う数字を選んでください")
	return

@show_select_window = (item_id) ->
	modalInstance = $.remodal.lookup[$('[data-remodal-id=modal-select'+item_id+']').data('remodal')]
	modalInstance.open()
	$('#select-notice').text("")
	$('#select-notice').text("アイテムを使う数字を選んでください")
	return

check_rank = ->
	$.ajaxSetup({async: false});
	$.getJSON('/API/check_rank',{room_id: @room_id},(json)->
		rank = json
		if rank != 0
			$('#rank-number').text(rank)
			$('#ranking').show()
		return
	)
	return
check_bingo = ->
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


number_of_bingo = 0
number_of_one_left_line = 0
number_of_hole = 0
calc_number_of_bingos = ->
	holes = []
	number_of_bingo = 0
	number_of_one_left_line = 0
	number_of_hole = 0
	for check in checks
		if check == true
			holes.push(1)
			number_of_hole++
		else
			holes.push(0)
#check_number_of_bingo
	for i in[0..4]
		if (holes[i*5+0]+holes[i*5+1]+holes[i*5+2]+holes[i*5+3]+holes[i*5+4]) == 5
			number_of_bingo++
#check vertical line
	for i in[0..4]
		if (holes[i+0]+holes[i+5]+holes[i+10]+holes[i+15]+holes[i+20]) == 5
			number_of_bingo++
#check diagonal line
	if (holes[0]+holes[6]+holes[12]+holes[18]+holes[24]) == 5
		number_of_bingo++
	if (holes[4]+holes[8]+holes[12]+holes[16]+holes[20]) == 5
		number_of_bingo++

#check_number_of_one_left_line
	for i in[0..4]
		if (holes[i*5+0]+holes[i*5+1]+holes[i*5+2]+holes[i*5+3]+holes[i*5+4]) == 4
			number_of_one_left_line++
#check vertical line
	for i in[0..4]
		if (holes[i+0]+holes[i+5]+holes[i+10]+holes[i+15]+holes[i+20]) == 4
			number_of_one_left_line++
#check diagonal line
	if (holes[0]+holes[6]+holes[12]+holes[18]+holes[24]) == 4
		number_of_one_left_line++
	if (holes[4]+holes[8]+holes[12]+holes[16]+holes[20]) == 4
		number_of_one_left_line++
	return

calc_number_of_riichi = ->
	holes = []
	number_of_one_left_line = 0
	for check in checks
		if check == true
			holes.push(1)
		else
			holes.push(0)

#check_number_of_one_left_line
	for i in[0..4]
		if (holes[i*5+0]+holes[i*5+1]+holes[i*5+2]+holes[i*5+3]+holes[i*5+4]) == 4
			number_of_one_left_line++
#check vertical line
	for i in[0..4]
		if (holes[i+0]+holes[i+5]+holes[i+10]+holes[i+15]+holes[i+20]) == 4
			number_of_one_left_line++
#check diagonal line
	if (holes[0]+holes[6]+holes[12]+holes[18]+holes[24]) == 4
		number_of_one_left_line++
	if (holes[4]+holes[8]+holes[12]+holes[16]+holes[20]) == 4
		number_of_one_left_line++
	return number_of_one_left_line


set_number_of_bingos = ->
	calc_number_of_bingos()
	$('#number-of-bingo').text(number_of_bingo)
	$('#number-of-one-left-line').text(number_of_one_left_line)
	$('#number-of-hole').text(number_of_hole)
	return

change_item_detail = ->
	$('.items-no-use-playing').text("このアイテムはゲーム中に使用できません")
	return