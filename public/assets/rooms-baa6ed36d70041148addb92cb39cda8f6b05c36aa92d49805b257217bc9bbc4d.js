(function() {
  var bingo_users, bingo_users_length, rate;

  rate = [];

  bingo_users = [];

  $(function() {
    this.community_id = $("#data").data("community_id");
    this.room_id = $("#data").data("room_id");
    return this.condition = $("#data").data("condition");
  });

  this.rate_update = function(room_id) {
    $.ajaxSetup({
      async: false
    });
    $.getJSON('/API/get_number_rate', {
      room_id: room_id
    }, function(json) {
      rate = json;
    });
  };

  this.notices_update = function(room_id) {
    $.getJSON('/API/get_notices', {
      room_id: room_id
    }, function(json) {
      var i, j, len;
      $('#notices').text("");
      for (j = 0, len = json.length; j < len; j++) {
        i = json[j];
        $('#notices').prepend("<div><span class=\"user_name\">" + i.user_name + "さん: </span><span>" + i.notice + "</span>");
      }
    });
  };

  this.get_random_number = function() {
    var i, index, j, k, len, numbers, r, ref;
    numbers = [];
    for (index = j = 0, len = rate.length; j < len; index = ++j) {
      r = rate[index];
      for (i = k = 0, ref = r; 0 <= ref ? k < ref : k > ref; i = 0 <= ref ? ++k : --k) {
        numbers.push(index + 1);
      }
    }
    if (numbers.length === 0) {
      $('#number-display').text("全ての数字が出力されました");
      return;
    }
    return numbers[Math.floor(Math.random() * numbers.length)];
  };

  this.add_number = function(room_id, number) {
    $.post('/API/add_number', {
      room_id: room_id,
      number: number
    }, function(data) {});
  };

  this.random_number_add = function(room_id) {
    var number;
    this.rate_update(room_id);
    number = this.get_random_number();
    this.add_number(room_id, number);
    $('#number-display').text(number);
  };

  this.start_game = function(room_id) {
    var condition;
    $.get("/API/game_main/" + this.community_id + "/" + room_id);
    condition = 1;
  };

  bingo_users_length = 0;

  this.bingo_users_window;

  this.check_bingo_users = function() {
    var index, j, k, len, len1, list, user;
    $.ajaxSetup({
      async: false
    });
    $.getJSON('/API/check_bingo_users', {
      room_id: this.room_id
    }, function(json) {
      return bingo_users = json;
    });
    if (bingo_users_length !== bingo_users.length) {
      bingo_users_length = bingo_users.length;
      $('#bingo-user-list').empty();
      for (index = j = 0, len = bingo_users.length; j < len; index = ++j) {
        user = bingo_users[index];
        $('#bingo-user-list').prepend("<div> " + user.name + ", " + user.times + "回目, " + user.seconds + "ms </div>");
      }
    }
    if ((this.bingo_users_window != null) && !this.bingo_users_window.closed) {
      list = this.bingo_users_window.document.getElementById('bingo-user-list');
      $(list).empty();
      for (index = k = 0, len1 = bingo_users.length; k < len1; index = ++k) {
        user = bingo_users[index];
        $(list).prepend("<div> " + user.name + ", " + user.times + "回目, " + user.seconds + "ms </div>");
      }
    }
  };

  this.view_mail_address = function(obj) {
    $(obj).children('.view-mail-addess').toggle();
  };

  this.open_bingo_users_window = function(obj) {
    this.bingo_users_window = window.open(obj.href, "ビンゴリスト", 'height=300, width=400');
  };

  this.joined_user_update = function(room_id) {
    $.get("/API/member_list/" + room_id);
  };

}).call(this);
