$(->
	@show_room_detail()
	@show_profit_item_detail()
	return
)
@show_room_detail = ->
	if $("#canUseItem").prop('checked')
		$('#item-setting').show()
	else
		$('#item-setting').hide()
	return
@show_profit_item_detail = ->
	if $("#can_bring_item").prop('checked')
		$('#profit-item').show()
	else
		$('#profit-item').hide()
	return