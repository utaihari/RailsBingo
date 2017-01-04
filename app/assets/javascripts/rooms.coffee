# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

rate = []
bingo_users = []
notices_length = 0

$(->
	@community_id = $("#data").data("community_id")
	@room_id = $("#data").data("room_id")
	@condition = $("#data").data("condition")
	@notices_update(@room_id)
	# @update_notice = setInterval(->
	# 	@notices_update(@room_id)
	# ,1500)
)

@rate_update =(room_id) ->
	$.ajaxSetup({async: false});
	$.getJSON('/API/get_number_rate', {room_id: room_id}, (json) ->
		rate = json
		return
		)
	return

@notices_update = (room_id) ->
	$.getJSON('/API/get_notices', {room_id: room_id, length: notices_length}, (json) ->
		if json != null
			json.reverse()
			notices_length += json.length
			for i in json
				$('#notices').prepend("<div><span class=\"user_name\">#{i.user_name}さん: </span><span>#{i.notice}</span>")
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
	$.get("/API/game_main/#{@community_id}/#{room_id}")
	condition = 1
	return

bingo_users_length = 0
@bingo_users_window
@check_bingo_users  = ->
	$.ajaxSetup({async: false});
	$.getJSON('/API/check_bingo_users',{room_id: @room_id},(json)->
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

@joined_user_update = (room_id) ->
	$.get("/API/member_list/#{room_id}")
	return
@item_use_update = ->
	$.get("/API/use_item_tool/#{@room_id}")
	return
@update_easy_to_apper_numbers = ->
	@rate_update(@room_id)
	numbers = []
	for r, index in rate
		numbers.push({number:index+1, rate:r})
	numbers.sort((a,b)->
    	if(a.rate > b.rate)
    		return -1
    	if(a.rate < b.rate)
    		return 1
    	return 0
	)
	$('#easy-to-apper-numbers').empty()
	for index in [9..0]
		$('#easy-to-apper-numbers').prepend("<span><font size=#{1+(numbers[index].rate/10)}>#{numbers[index].number}</font> </span>")
	return

@hide_bingo_users = ->
	$('#bingo-users-wrapper').hide()
	$('#show-bingo-users').show()
	return
@show_bingo_users = ->
	$('#bingo-users-wrapper').show()
	$('#show-bingo-users').hide()
	return

@hide_easy_to_apper_numbers = ->
	$('#easy-to-apper-numbers-wrapper').hide()
	$('#show-easy-to-apper-numbers').show()
	return
@show_easy_to_apper_numbers = ->
	$('#easy-to-apper-numbers-wrapper').show()
	$('#show-easy-to-apper-numbers').hide()
	return

@hide_notices = ->
	$('#notices-wrapper').hide()
	$('#show-notices').show()
	return
@show_notices = ->
	$('#notices-wrapper').show()
	$('#show-notices').hide()
	return
@item_use = ->
	item_id = $('#select-item').val()
	card_id = $('#select-user').val()

	if parseInt(item_id) == -1 || parseInt(card_id) == -1
		return
	$.post('/API/use_item',{community_id: @community_id, room_id: @room_id, item_id: item_id, card_id: card_id, from_room_master: true},(json)->
		)
	return

notice_auto_update = false
@notice_auto_update = =>
	if !notice_auto_update
		@update_notice = setInterval(->
			@notices_update(@room_id)
		,1500)
		$('#notice-update-button').text("自動更新中")
		notice_auto_update = true
	else
		clearInterval(@update_notice)
		$('#notice-update-button').text("自動更新する")
		notice_auto_update = false
	return
@show_ip_address = ->
	$('.ip-address').toggle()
	return
@show_room_detail = ->
	$('#room-detail').toggle()
	return