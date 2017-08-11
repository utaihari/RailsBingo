(function() {
  $(function() {
    this.show_room_detail();
    this.show_profit_item_detail();
  });

  this.show_room_detail = function() {
    if ($("#canUseItem").prop('checked')) {
      $('#item-setting').show();
    } else {
      $('#item-setting').hide();
    }
  };

  this.show_profit_item_detail = function() {
    if ($("#can_bring_item").prop('checked')) {
      $('#profit-item').show();
    } else {
      $('#profit-item').hide();
    }
  };

}).call(this);
