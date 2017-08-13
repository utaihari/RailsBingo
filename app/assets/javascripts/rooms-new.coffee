$(->
	@show_room_detail()
	@show_profit_item_detail()
	$(".datetimepicker").datetimepicker({
    	format: "YYYY/MM/DD HH:mm",
    	showClear: true,
    	showClose: true,
    	locale: 'ja'
   	});
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