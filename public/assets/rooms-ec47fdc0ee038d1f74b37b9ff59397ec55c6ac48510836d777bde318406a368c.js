(function() {
  var bingo_users, bingo_users_length, notice_auto_update, notices_length, rate;

  rate = [];

  bingo_users = [];

  notices_length = 0;

  $(function() {
    this.community_id = $("#data").data("community_id");
    this.room_id = $("#data").data("room_id");
    this.condition = $("#data").data("condition");
    return this.notices_update(this.room_id);
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
        $('#bingo-user-list').prepend("<div> " + user.name + ", " + user.times + "回目, " + user.seconds + "ms, " + user.note + " </div>");
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
    $('.view-mail-addess').toggle();
  };

  this.open_bingo_users_window = function(obj) {
    this.bingo_users_window = window.open(obj.href, "ビンゴリスト", 'height=300, width=400');
  };

  this.joined_user_update = function(room_id) {
    $.get("/API/member_list/" + room_id);
  };

  this.item_use_update = function() {
    $.get("/API/use_item_tool/" + this.room_id);
  };

  this.update_easy_to_apper_numbers = function() {
    var index, j, k, len, numbers, r;
    this.rate_update(this.room_id);
    numbers = [];
    for (index = j = 0, len = rate.length; j < len; index = ++j) {
      r = rate[index];
      numbers.push({
        number: index + 1,
        rate: r
      });
    }
    numbers.sort(function(a, b) {
      if (a.rate > b.rate) {
        return -1;
      }
      if (a.rate < b.rate) {
        return 1;
      }
      return 0;
    });
    $('#easy-to-apper-numbers').empty();
    for (index = k = 9; k >= 0; index = --k) {
      $('#easy-to-apper-numbers').prepend("<span style=\"font-size: " + (1 + (numbers[index].rate / 30)) + "em\">" + numbers[index].number + " </span>");
    }
  };

  this.hide_bingo_users = function() {
    $('#bingo-users-wrapper').hide();
    $('#show-bingo-users').show();
  };

  this.show_bingo_users = function() {
    $('#bingo-users-wrapper').show();
    $('#show-bingo-users').hide();
  };

  this.hide_easy_to_apper_numbers = function() {
    $('#easy-to-apper-numbers-wrapper').hide();
    $('#show-easy-to-apper-numbers').show();
  };

  this.show_easy_to_apper_numbers = function() {
    $('#easy-to-apper-numbers-wrapper').show();
    $('#show-easy-to-apper-numbers').hide();
  };

  this.hide_notices = function() {
    $('#notices-wrapper').hide();
    $('#show-notices').show();
  };

  this.show_notices = function() {
    $('#notices-wrapper').show();
    $('#show-notices').hide();
  };

  this.item_use = function() {
    var card_id, item_id;
    item_id = $('#select-item').val();
    card_id = $('#select-user').val();
    if (parseInt(item_id) === -1 || parseInt(card_id) === -1) {
      return;
    }
    $.post('/API/use_item', {
      community_id: this.community_id,
      room_id: this.room_id,
      item_id: item_id,
      card_id: card_id,
      from_room_master: true
    }, function(json) {});
  };

  notice_auto_update = false;

  this.notice_auto_update = (function(_this) {
    return function() {
      if (!notice_auto_update) {
        _this.update_notice = setInterval(function() {
          return this.notices_update(this.room_id);
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

  this.show_ip_address = function() {
    $('.ip-address').toggle();
  };

  this.show_room_detail = function() {
    $('#room-detail').toggle();
  };

}).call(this);
