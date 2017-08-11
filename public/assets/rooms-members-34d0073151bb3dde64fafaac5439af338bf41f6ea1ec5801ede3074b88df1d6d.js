(function() {
  this.joined_user_update = function(room_id) {
    $.get("/API/member_list/" + room_id);
  };

  this.show_ip_address = function() {
    $('.ip-address').toggle();
  };

}).call(this);
