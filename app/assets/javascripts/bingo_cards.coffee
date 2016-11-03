# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

numbers = []
number_length = 0
$(->
	$('.bingo_number').on('click', ->
		if jQuery.inArray(Number($(this).data('number')), numbers) >= 0 then $(this).toggleClass('checked')
		)

	)
@number_update =(room_id) ->
	$.getJSON('/API/get_number', {room_id: room_id}, (json) ->
		numbers = json
		return
	)
	update_list()
	return

update_list = ->
	if number_length isnt numbers.length
		number_length = numbers.length
		$('ul#number_list').empty()
		for number, index in numbers when number isnt -1 and index isnt number_length-1
			$('ul#number_list').prepend("<li> #{number} </li>")
		$('ul#number_list').prepend("<li class=\"previous_number\" style=\"font-size:40px\"> #{numbers[number_length-1]} </li>")
	return