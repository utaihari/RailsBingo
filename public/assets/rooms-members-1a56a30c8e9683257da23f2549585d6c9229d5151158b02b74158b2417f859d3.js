(function() {
  this.joined_user_update = function(room_id) {
    $.get("/API/member_list/" + room_id);
  };

}).call(this);
