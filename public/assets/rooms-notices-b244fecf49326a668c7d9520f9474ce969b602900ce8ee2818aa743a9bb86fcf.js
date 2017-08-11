(function() {
  var notice_auto_update, notices_length;

  notices_length = 0;

  notice_auto_update = false;

  this.notice_auto_update = (function(_this) {
    return function() {
      var room_id;
      room_id = $("#data").data("room_id");
      if (!notice_auto_update) {
        _this.update_notice = setInterval(function() {
          return this.notices_update(room_id);
        }, 1500);
        $('#notice-update-button').text("自動更新中");
        notice_auto_update = true;
      } else {
        clearInterval(_this.update_notice);
        $('#notice-update-button').text("自動更新する");
        notice_auto_update = false;
      }
    };
  })(this);

  this.notices_update = function(room_id) {
    $.getJSON('/API/get_notices', {
      room_id: room_id,
      length: notices_length
    }, function(json) {
      var i, j, len;
      if (json !== null) {
        json.reverse();
        notices_length += json.length;
        for (j = 0, len = json.length; j < len; j++) {
          i = json[j];
          $('#notices').prepend("<div><span class=\"user_name\">" + i.user_name + "さん: </span><span><font color=\"" + i.color + "\">" + i.notice + "</font></span>");
        }
      }
    });
  };

}).call(this);
