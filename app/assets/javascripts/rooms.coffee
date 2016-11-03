# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

rate = []
@rate_update =(room_id,community_id) ->
	$.getJSON('/API/get_number', {room_id: room_id,community_id: community_id}, (json) ->
		numbers = json
		return
	)
	update_list()
	return