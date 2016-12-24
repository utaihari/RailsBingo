(function() {
  this.notices_update = function(room_id) {
    $.getJSON('/API/get_notices', {
      room_id: room_id
    }, function(json) {
      var i, j, len;
      $('#notices').text("");
      for (j = 0, len = json.length; j < len; j++) {
        i = json[j];
        $('#notices').prepend("<div><span class=\"user_name\">" + i.user_name + "さん: </span> <span>" + i.notice + "</span>");
      }
    });
  };

}).call(this);
