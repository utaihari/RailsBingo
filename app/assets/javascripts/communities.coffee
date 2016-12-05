# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

@show_detail = ->
	$('#community-detail').toggle('fast')
	return

@show_members = ->
	$('#community-members').toggle('slow')
	return

@toggle_administrator = (community_id, user_id) ->
	$.getJSON('/API/toggle_administrator', {community_id: community_id, user_id: user_id}, (json) ->
		if json
			$(".organize-#{user_id}").text("有")
		else
			$(".organize-#{user_id}").text("無")
		return
		)