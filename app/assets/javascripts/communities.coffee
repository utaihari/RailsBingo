# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

@show_detail = ->
	$('#community_detail').toggle('fast')
	return

@show_members = ->
	$('#community_members').toggle('slow')
	return

