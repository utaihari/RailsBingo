# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

numbers = []
checks = []
notice = []
notice_list = []
card_numbers = []
number_length = 0
condition = 0
number_arrive_time = new Date()

$(->
	$('#tab-container').easytabs()

	@room_id = $("#data").data("room_id")
	@card_id = $("#data").data("card_id")
	@community_id = $("#data").data("community_id")
	@get_item = $("#data").data("get_item")
	@is_auto = $('#data').data("is_auto")
	@done_bingo = $('#data').data("done_bingo")

	if is_auto
		$('#auto_check').prop("checked",true)

	for i in [0..24]
		checks.push(false)
	@onPageLoad()
	@update_notice = setInterval(->
		display_notice()
	,1000)
	@start_check = setInterval(->
		game_start_check(room_id)
	,5000)
	@notices_check = setInterval(->
		get_server_notices(room_id)
	,5000)
	if !@done_bingo && check_bingo()
		$('#bingo-button').show()
	else
		$('#bingo-button').hide()

	if @get_item
		$('[data-remodal-id=getitem]').remodal().open()
	else if @is_auto
		$('[data-remodal-id=is_auto]').remodal().open()
	return
)
@onPageLoad = ->
	room_id = $("#data").data("room_id")
	@numbers_update()
	number_length = numbers.length
	@checks_update()
	update_list()
	get_card_numbers()
	reload_check_numbers()
	@update_items()
	return
game_start_check =  ->
	@check_condition()
	if condition == 1
		notice.push("ゲームが始まりました")
		change_item_detail()
		@update_numbers = setInterval(->
			@numbers_update()
			update_list()
			reload_check_numbers()
		,5000)
		@end_check = setInterval(->
			game_end_check()
		,8000)
		clearInterval(@start_check)
		if @is_auto
			check_number_local(-1)
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
		clearInterval(@notices_check)
		check_rank()
		set_number_of_bingos()
		@update_result()
		$('#result').show('slow')
		$('[data-remodal-id=result]').remodal().open()
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

get_server_notices = ->
	$.ajaxSetup({async: false});
	$.getJSON('/API/get_user_notices',{room_id: @room_id},(json)->
		for n in json
			notice.push(n)
		return
	)
	return

update_list = ->
	if number_length isnt numbers.length
		if numbers[numbers.length-1] isnt -1
			notice.push("新しいナンバーは "+ numbers[numbers.length-1] + "です")
			hide_added_number()

			#action for new numbers
			for i in [number_length..numbers.length]
				$("#added-#{numbers[i-1]}").addClass("icon-cross")
				if document.getElementById("select-number-#{numbers[i-1]}") != null
					$("#select-number-#{numbers[i-1]}").hide()
				if @is_auto
					check_number_local(numbers[i-1])

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
	$.getJSON('/API/check_number',{room_id:@room_id, card_id: @card_id, index: index, riichi_lines: calc_number_of_riichi() , is_auto: false},(json)->
		checks[index] = (json[index] == 't')
	)
	return

check_number_local = (number) ->
	card_nums = $('.bingo-number')
	for n, index in card_nums
		if number == parseInt($(n).data("number"))
			# checks[index] = true
			# $.getJSON('/API/check_number',{room_id:@room_id, card_id: @card_id, index: index, riichi_lines: calc_number_of_riichi(), is_auto: true},(json)->
			# 	checks[index] = (json[index] == 't')
			# )
			# if checks[index]
			$(n).addClass("checked")

@uncheck_number = (index) ->
	checks[index] = false
	$.ajaxSetup({async: false});
	$.getJSON('/API/uncheck_number',{room_id:@room_id, card_id: @card_id, index: index, riichi_lines: calc_number_of_riichi()},(json)->
		checks[index] = (json[index] == 't')
	)
	return
@number_click = (obj, index) ->
	if checks[index]
		return
	if jQuery.inArray(Number($(obj).data('number')), numbers) >= 0
		@check_number(index)
		$(obj).toggleClass("checked", checks[index])
		if check_bingo() && !done_bingo
			$('#bingo-button').show()
		else
			$('#bingo-button').hide()
		return

	return


@display_past_number = ->
	$('#number-list-wrapper').toggle('slow')
	return

@bingo = ->
	current_time = new Date()
	if !check_bingo || @done_bingo
		$('#bingo-button').hide()
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
	$.getJSON('/API/use_item',{community_id: @community_id, room_id: @room_id, item_id: item_id, card_id: @card_id, from_room_master: false},(json)->
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

	get_card_numbers()
	@checks_update()

	if check_bingo() && !done_bingo
		$('#bingo-button').show()
	else
		$('#bingo-button').hide()
	return

@use_item_all = (item_id, update_card) ->

	room_id = @room_id
	community_id = @community_id

	$.ajaxSetup({async: false});
	$.getJSON('/API/use_item_all',{community_id: @community_id, room_id: @room_id, item_id: item_id, card_id: @card_id},(json)->
		notice.push(json)
		if update_card
			$.get("/API/#{community_id}/#{room_id}/bingo_card")
		return
		)

	$('.item-rows-'+item_id).hide()
	get_card_numbers()

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

hide_added_number = ->
	for number in numbers
		$(".select-number-#{number}").hide()

@show_select_window = (item_id) ->
	hide_added_number()
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
@joined_user_update = ->
	$.get("/API/member_list_from_card/#{@room_id}")
	return
get_card_numbers = ->
	$.ajaxSetup({async: false});
	$.getJSON('/API/get_card_numbers',{@card_id},(json)->
		card_numbers = json
		return
		)
	return

reload_check_numbers = ->
	number_unchecked = false
	for check, index in checks
		if check
			if !(parseInt(card_numbers[index]) in numbers) && (parseInt(card_numbers[index]) != -1)
				$("#card-#{card_numbers[index]}").removeClass("checked")
				$("#added-#{card_numbers[index]}").removeClass("icon-cross")
				uncheck_number(index)
				number_unchecked = true
	if number_unchecked
		if check_bingo() && !done_bingo
				$('#bingo-button').show()
		else
				$('#bingo-button').hide()
	return

get_settings = ->
	$.getJSON('/API/get_settings',{},(json)->
		@is_auto = json['auto_check']
		return
		)
	return

@auto_check = ->
	@is_auto = $('#auto_check').prop("checked")
	$.post('/API/auto_check', {is_auto_check: @is_auto, card_id: @card_id}, (data) ->
		return
		)
	return
