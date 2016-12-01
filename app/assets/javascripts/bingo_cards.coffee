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
	$('.tabs').tabtab({
		tabMenu: '.tabs__menu',
		tabContent: '.tabs__content',
		next: '.tabs-controls__next',
		prev: '.tabs-controls__prev',

		startSlide: 1,
		arrows: true,
		dynamicHeight: true,
		useAnimations: true,

		easing: 'ease',
		speed: 350,
		slideDelay: 0,
		perspective: 1200,
		transformOrigin: 'center top',
		perspectiveOrigin: '50% 50%',

		translateY: 0,
		translateX: 0,
		scale: 1,
		rotateX: 90,
		rotateY: 0,
		skewY: 0,
		skewX: 0
	});

	@room_id = $("#data").data("room_id")
	@card_id = $("#data").data("card_id")
	@community_id = $("#data").data("community_id")
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
		$('#bingo_button').show()
	else
		$('#bingo_button').hide()
	return
)

game_start_check =  ->
	@check_condition()
	console.log(condition)
	if condition == 1
		notice.push("ゲームが始まりました")
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
	$('#notice_list').empty()
	for n, index in notice_list
		$('#notice_list').prepend("<p> #{n} </p>")
	return

items = []
@update_items = ->
	$.get("/API/#{@community_id}/#{@room_id}/items")
	return
@show_notice_list = ->
	$('#notice_list').toggle('slow')
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
		$('ul#number_list').empty()
		for number, index in numbers when number isnt -1
			$('ul#number_list').prepend("<li> #{number} </li>")
		$('#last_number').empty()
		if numbers[number_length-1] isnt -1
			$('#last_number').text(numbers[number_length-1])
		number_arrive_time = new Date()
	return

@check_number = (index) ->
	$.ajaxSetup({async: false});
	$.getJSON('/API/check_number',{card_id: @card_id, index: index},(json)->
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
			$('#bingo_button').show()
		else
			$('#bingo_button').hide()
	return

@onPageLoad = ->
	room_id = $("#data").data("room_id")
	@numbers_update()
	@checks_update()
	$('.bingo_number').each( (i,e)->
		if jQuery.inArray(Number($(e).data('number')), numbers) >= 0
			$(e).toggleClass("checked", checks[i])
		return
	)
	update_list()
	return
@display_past_number = ->
	$('#number_list_wrapper').toggle('slow')
	return

@bingo = ->
	current_time = new Date()
	if !check_bingo || done_bingo
		return
	$.post('/API/done_bingo', {card_id: @card_id, room_id: @room_id, times: numbers.length, seconds: current_time-number_arrive_time}, (data) ->
		done_bingo = data
		return
		)
	return

check_rank = ->
	$.ajaxSetup({async: false});
	$.getJSON('/API/check_rank',{room_id: @room_id},(json)->
		rank = json
		if rank != 0
			$('#rank_number').text(rank)
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

set_number_of_bingos = ->
	calc_number_of_bingos()
	$('#number_of_bingo').text(number_of_bingo)
	$('#number_of_one_left_line').text(number_of_one_left_line)
	$('#number_of_hole').text(number_of_hole)
	return