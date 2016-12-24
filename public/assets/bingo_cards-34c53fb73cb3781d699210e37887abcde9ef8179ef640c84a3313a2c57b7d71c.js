(function() {
  var calc_number_of_bingos, calc_number_of_riichi, check_bingo, check_rank, checks, choosing_number, condition, display_notice, done_bingo, game_end_check, game_start_check, items, notice, notice_list, number_arrive_time, number_length, number_of_bingo, number_of_hole, number_of_one_left_line, numbers, set_number_of_bingos, update_list, update_notice_list, using_item_id;

  numbers = [];

  checks = [];

  notice = [];

  notice_list = [];

  number_length = 0;

  condition = 0;

  number_arrive_time = new Date();

  done_bingo = false;

  $(function() {
    var i, j;
    $('#tab-container').easytabs();
    this.room_id = $("#data").data("room_id");
    this.card_id = $("#data").data("card_id");
    this.community_id = $("#data").data("community_id");
    this.get_item = $("#data").data("get_item");
    for (i = j = 0; j <= 24; i = ++j) {
      checks.push(false);
    }
    this.onPageLoad();
    this.update_notice = setInterval(function() {
      return display_notice();
    }, 1000);
    this.start_check = setInterval(function() {
      return game_start_check(room_id);
    }, 5000);
    if (check_bingo()) {
      $('#bingo-button').show();
    } else {
      $('#bingo-button').hide();
    }
    if (this.get_item) {
      $('[data-remodal-id=getitem]').remodal().open();
    }
  });

  game_start_check = function() {
    this.check_condition();
    if (condition === 1) {
      notice.push("ゲームが始まりました");
      this.update_numbers = setInterval(function() {
        this.numbers_update();
        return update_list();
      }, 5000);
      this.end_check = setInterval(function() {
        return game_end_check();
      }, 8000);
      clearInterval(this.start_check);
    }
    if (condition === 2) {
      clearInterval(this.start_check);
      game_end_check();
    }
  };

  game_end_check = function() {
    this.check_condition();
    if (condition === 2) {
      notice.push("ゲームが終了しました。");
      display_notice();
      clearInterval(this.end_check);
      clearInterval(this.update_numbers);
      clearInterval(this.update_notice);
      check_rank();
      set_number_of_bingos();
      this.update_result();
      $('#result').show('slow');
    }
  };

  display_notice = function() {
    var n;
    if (notice.length !== 0) {
      n = notice.shift();
      $('#notice').empty();
      $('#notice').text(n);
      update_notice_list();
      notice_list.push(n);
    }
  };

  update_notice_list = function() {
    var index, j, len, n;
    $('#notice-list').empty();
    for (index = j = 0, len = notice_list.length; j < len; index = ++j) {
      n = notice_list[index];
      $('#notice-list').prepend("<p> " + n + " </p>");
    }
  };

  items = [];

  this.update_items = function() {
    $.get("/API/" + this.community_id + "/" + this.room_id + "/items");
  };

  this.update_result = function() {
    $.get("/API/" + this.community_id + "/" + this.room_id + "/get_items/" + number_of_bingo + "/" + number_of_one_left_line + "/" + number_of_hole);
  };

  this.update_bingo_card = function() {
    $.get("/API/" + this.community_id + "/" + this.room_id + "/bingo_card");
  };

  this.show_notice_list = function() {
    $('#notice-list').toggle('slow');
  };

  this.numbers_update = function() {
    $.ajaxSetup({
      async: false
    });
    $.getJSON('/API/get_number', {
      room_id: this.room_id
    }, function(json) {
      numbers = json;
    });
  };

  this.checks_update = function() {
    $.ajaxSetup({
      async: false
    });
    $.getJSON('/API/get_checked_number', {
      room_id: this.room_id
    }, function(json) {
      var check, index, j, len;
      checks = [];
      for (index = j = 0, len = json.length; j < len; index = ++j) {
        check = json[index];
        checks.push(check === 't');
      }
    });
  };

  this.check_condition = function() {
    $.ajaxSetup({
      async: false
    });
    $.getJSON('/API/check_condition', {
      room_id: this.room_id
    }, function(json) {
      condition = json;
    });
  };

  update_list = function() {
    var index, j, len, number;
    if (number_length !== numbers.length) {
      if (numbers[numbers.length - 1] !== -1) {
        notice.push("新しいナンバーは " + numbers[numbers.length - 1] + "です");
      }
      number_length = numbers.length;
      $('ul#number-list').empty();
      for (index = j = 0, len = numbers.length; j < len; index = ++j) {
        number = numbers[index];
        if (number !== -1) {
          $('ul#number-list').prepend("<li> " + number + " </li>");
        }
      }
      $('#last-number').empty();
      if (numbers[number_length - 1] !== -1) {
        $('#last-number').text(numbers[number_length - 1]);
      }
      number_arrive_time = new Date();
    }
  };

  this.check_number = function(index) {
    checks[index] = true;
    $.ajaxSetup({
      async: false
    });
    $.getJSON('/API/check_number', {
      room_id: this.room_id,
      card_id: this.card_id,
      index: index,
      riichi_lines: calc_number_of_riichi()
    }, function(json) {
      return checks[index] = json[index] === 't';
    });
  };

  this.number_click = function(obj, index) {
    var choosing_number;
    if (checks[index]) {
      return;
    }
    if (jQuery.inArray(Number($(obj).data('number')), numbers) >= 0) {
      this.check_number(index);
      $(obj).toggleClass("checked", checks[index]);
      if (check_bingo()) {
        $('#bingo-button').show();
      } else {
        $('#bingo-button').hide();
      }
      return;
    }
    if (choosing_number) {
      choosing_number = false;
      use_item_select_number(using_item_id, $(obj).data('number'));
    }
  };

  this.onPageLoad = function() {
    var room_id;
    room_id = $("#data").data("room_id");
    this.numbers_update();
    this.checks_update();
    update_list();
    this.update_items();
  };

  this.display_past_number = function() {
    $('#number-list-wrapper').toggle('slow');
  };

  this.bingo = function() {
    var current_time;
    current_time = new Date();
    if (!check_bingo || done_bingo) {
      return;
    }
    $.post('/API/done_bingo', {
      card_id: this.card_id,
      room_id: this.room_id,
      times: numbers.length,
      seconds: current_time - number_arrive_time
    }, function(data) {
      done_bingo = data;
      if (done_bingo) {
        $('#bingo-button').hide();
      }
    });
  };

  this.use_item = function(item_id, update_card) {
    var community_id, q, quantity, room_id;
    room_id = this.room_id;
    community_id = this.community_id;
    $.ajaxSetup({
      async: false
    });
    $.getJSON('/API/use_item', {
      community_id: this.community_id,
      room_id: this.room_id,
      item_id: item_id
    }, function(json) {
      notice.push(json);
      if (update_card) {
        $.get("/API/" + community_id + "/" + room_id + "/bingo_card");
      }
    });
    quantity = $('.quantity-' + item_id);
    q = parseInt(quantity.text()) - 1;
    if (q <= 0) {
      $('.item-rows-' + item_id).hide();
    }
    quantity.text(q);
    $('.q-' + item_id).text(q);
  };

  this.use_item_select_number = function(item_id, number) {
    var q, quantity, s_notice;
    $.ajaxSetup({
      async: false
    });
    s_notice = "";
    $.getJSON('/API/use_item', {
      community_id: this.community_id,
      room_id: this.room_id,
      item_id: item_id,
      number: number
    }, function(json) {
      notice.push(json);
      s_notice = json;
    });
    quantity = $('.quantity-' + item_id);
    q = parseInt(quantity.text()) - 1;
    if (q <= 0) {
      $('.item-rows-' + item_id).hide();
    }
    quantity.text(q);
    $('.q-' + item_id).text(q);
  };

  choosing_number = false;

  using_item_id = 0;

  this.select_number = function(item_id) {
    choosing_number = true;
    using_item_id = item_id;
    notice.push("アイテムを使う数字を選んでください");
  };

  this.show_select_window = function(item_id) {
    var modalInstance;
    modalInstance = $.remodal.lookup[$('[data-remodal-id=modal-select' + item_id + ']').data('remodal')];
    modalInstance.open();
    $('#select-notice').text("");
    $('#select-notice').text("アイテムを使う数字を選んでください");
  };

  check_rank = function() {
    $.ajaxSetup({
      async: false
    });
    $.getJSON('/API/check_rank', {
      room_id: this.room_id
    }, function(json) {
      var rank;
      rank = json;
      if (rank !== 0) {
        $('#rank-number').text(rank);
        $('#ranking').show();
      }
    });
  };

  check_bingo = function() {
    var i, j, k;
    for (i = j = 0; j <= 4; i = ++j) {
      if (checks[i * 5 + 0] && checks[i * 5 + 1] && checks[i * 5 + 2] && checks[i * 5 + 3] && checks[i * 5 + 4]) {
        return true;
      }
    }
    for (i = k = 0; k <= 4; i = ++k) {
      if (checks[i + 0] && checks[i + 5] && checks[i + 10] && checks[i + 15] && checks[i + 20]) {
        return true;
      }
    }
    if (checks[0] && checks[6] && checks[12] && checks[18] && checks[24]) {
      return true;
    }
    if (checks[4] && checks[8] && checks[12] && checks[16] && checks[20]) {
      return true;
    }
    return false;
  };

  number_of_bingo = 0;

  number_of_one_left_line = 0;

  number_of_hole = 0;

  calc_number_of_bingos = function() {
    var check, holes, i, j, k, l, len, m, o;
    holes = [];
    number_of_bingo = 0;
    number_of_one_left_line = 0;
    number_of_hole = 0;
    for (j = 0, len = checks.length; j < len; j++) {
      check = checks[j];
      if (check === true) {
        holes.push(1);
        number_of_hole++;
      } else {
        holes.push(0);
      }
    }
    for (i = k = 0; k <= 4; i = ++k) {
      if ((holes[i * 5 + 0] + holes[i * 5 + 1] + holes[i * 5 + 2] + holes[i * 5 + 3] + holes[i * 5 + 4]) === 5) {
        number_of_bingo++;
      }
    }
    for (i = l = 0; l <= 4; i = ++l) {
      if ((holes[i + 0] + holes[i + 5] + holes[i + 10] + holes[i + 15] + holes[i + 20]) === 5) {
        number_of_bingo++;
      }
    }
    if ((holes[0] + holes[6] + holes[12] + holes[18] + holes[24]) === 5) {
      number_of_bingo++;
    }
    if ((holes[4] + holes[8] + holes[12] + holes[16] + holes[20]) === 5) {
      number_of_bingo++;
    }
    for (i = m = 0; m <= 4; i = ++m) {
      if ((holes[i * 5 + 0] + holes[i * 5 + 1] + holes[i * 5 + 2] + holes[i * 5 + 3] + holes[i * 5 + 4]) === 4) {
        number_of_one_left_line++;
      }
    }
    for (i = o = 0; o <= 4; i = ++o) {
      if ((holes[i + 0] + holes[i + 5] + holes[i + 10] + holes[i + 15] + holes[i + 20]) === 4) {
        number_of_one_left_line++;
      }
    }
    if ((holes[0] + holes[6] + holes[12] + holes[18] + holes[24]) === 4) {
      number_of_one_left_line++;
    }
    if ((holes[4] + holes[8] + holes[12] + holes[16] + holes[20]) === 4) {
      number_of_one_left_line++;
    }
  };

  calc_number_of_riichi = function() {
    var check, holes, i, j, k, l, len;
    holes = [];
    number_of_one_left_line = 0;
    for (j = 0, len = checks.length; j < len; j++) {
      check = checks[j];
      if (check === true) {
        holes.push(1);
      } else {
        holes.push(0);
      }
    }
    for (i = k = 0; k <= 4; i = ++k) {
      if ((holes[i * 5 + 0] + holes[i * 5 + 1] + holes[i * 5 + 2] + holes[i * 5 + 3] + holes[i * 5 + 4]) === 4) {
        number_of_one_left_line++;
      }
    }
    for (i = l = 0; l <= 4; i = ++l) {
      if ((holes[i + 0] + holes[i + 5] + holes[i + 10] + holes[i + 15] + holes[i + 20]) === 4) {
        number_of_one_left_line++;
      }
    }
    if ((holes[0] + holes[6] + holes[12] + holes[18] + holes[24]) === 4) {
      number_of_one_left_line++;
    }
    if ((holes[4] + holes[8] + holes[12] + holes[16] + holes[20]) === 4) {
      number_of_one_left_line++;
    }
    return number_of_one_left_line;
  };

  set_number_of_bingos = function() {
    calc_number_of_bingos();
    $('#number-of-bingo').text(number_of_bingo);
    $('#number-of-one-left-line').text(number_of_one_left_line);
    $('#number-of-hole').text(number_of_hole);
  };

}).call(this);
