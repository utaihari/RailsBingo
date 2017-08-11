(function() {
  var calc_number_of_bingos, calc_number_of_riichi, card_numbers, change_item_detail, check_bingo, check_number_local, check_rank, checks, condition, display_notice, game_end_check, game_start_check, get_card_numbers, get_server_notices, get_settings, hide_added_number, items, notice, notice_list, number_arrive_time, number_length, number_of_bingo, number_of_hole, number_of_one_left_line, numbers, reload_check_numbers, set_number_of_bingos, update_list, update_notice_list,
    indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  numbers = [];

  checks = [];

  notice = [];

  notice_list = [];

  card_numbers = [];

  number_length = 0;

  condition = 0;

  number_arrive_time = new Date();

  $(function() {
    var i, j;
    $('#tab-container').easytabs();
    this.room_id = $("#data").data("room_id");
    this.card_id = $("#data").data("card_id");
    this.community_id = $("#data").data("community_id");
    this.get_item = $("#data").data("get_item");
    this.is_auto = $('#data').data("is_auto");
    this.done_bingo = $('#data').data("done_bingo");
    if (is_auto) {
      $('#auto_check').prop("checked", true);
    }
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
    this.notices_check = setInterval(function() {
      return get_server_notices(room_id);
    }, 20000);
    if (!this.done_bingo && check_bingo()) {
      $('#bingo-button').show();
    } else {
      $('#bingo-button').hide();
    }
    if (this.get_item) {
      $('[data-remodal-id=getitem]').remodal().open();
    } else if (this.is_auto) {
      $('[data-remodal-id=is_auto]').remodal().open();
    }
  });

  this.onPageLoad = function() {
    var room_id;
    room_id = $("#data").data("room_id");
    this.numbers_update();
    number_length = numbers.length;
    this.checks_update();
    update_list();
    get_card_numbers();
    reload_check_numbers();
    this.update_items();
  };

  game_start_check = function() {
    this.check_condition();
    if (condition === 1) {
      notice.push("ゲームが始まりました");
      change_item_detail();
      this.update_numbers = setInterval(function() {
        this.numbers_update();
        update_list();
        return reload_check_numbers();
      }, 5000);
      this.end_check = setInterval(function() {
        return game_end_check();
      }, 8000);
      clearInterval(this.start_check);
      if (this.is_auto) {
        check_number_local(-1);
      }
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
      clearInterval(this.notices_check);
      check_rank();
      set_number_of_bingos();
      this.update_result();
      $('#result').show('slow');
      $('[data-remodal-id=result]').remodal().open();
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
      console.log(json);
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

  get_server_notices = function() {
    $.ajaxSetup({
      async: false
    });
    $.getJSON('/API/get_user_notices', {
      room_id: this.room_id
    }, function(json) {
      var j, len, n;
      for (j = 0, len = json.length; j < len; j++) {
        n = json[j];
        notice.push(n);
      }
    });
  };

  update_list = function() {
    var i, index, j, k, len, number, ref, ref1;
    if (number_length !== numbers.length) {
      if (numbers[numbers.length - 1] !== -1) {
        notice.push("新しいナンバーは " + numbers[numbers.length - 1] + "です");
        hide_added_number();
        for (i = j = ref = number_length, ref1 = numbers.length; ref <= ref1 ? j <= ref1 : j >= ref1; i = ref <= ref1 ? ++j : --j) {
          $("#added-" + numbers[i - 1]).addClass("icon-cross");
          if (document.getElementById("select-number-" + numbers[i - 1]) !== null) {
            $("#select-number-" + numbers[i - 1]).hide();
          }
          if (this.is_auto) {
            check_number_local(numbers[i - 1]);
          }
        }
      }
      number_length = numbers.length;
      $('ul#number-list').empty();
      for (index = k = 0, len = numbers.length; k < len; index = ++k) {
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
      riichi_lines: calc_number_of_riichi(),
      is_auto: false
    }, function(json) {
      return checks[index] = json[index] === 't';
    });
  };

  check_number_local = function(number) {
    var card_nums, index, j, len, n, results;
    card_nums = $('.bingo-number');
    results = [];
    for (index = j = 0, len = card_nums.length; j < len; index = ++j) {
      n = card_nums[index];
      if (number === parseInt($(n).data("number"))) {
        results.push($(n).addClass("checked"));
      } else {
        results.push(void 0);
      }
    }
    return results;
  };

  this.uncheck_number = function(index) {
    checks[index] = false;
    $.ajaxSetup({
      async: false
    });
    $.getJSON('/API/uncheck_number', {
      room_id: this.room_id,
      card_id: this.card_id,
      index: index,
      riichi_lines: calc_number_of_riichi()
    }, function(json) {
      return checks[index] = json[index] === 't';
    });
  };

  this.number_click = function(obj, index) {
    if (checks[index]) {
      return;
    }
    if (jQuery.inArray(Number($(obj).data('number')), numbers) >= 0) {
      this.check_number(index);
      $(obj).toggleClass("checked", checks[index]);
      if (check_bingo() && !done_bingo) {
        $('#bingo-button').show();
      } else {
        $('#bingo-button').hide();
      }
      return;
    }
  };

  this.display_past_number = function() {
    $('#number-list-wrapper').toggle('slow');
  };

  this.bingo = function() {
    var current_time;
    current_time = new Date();
    if (!check_bingo || this.done_bingo) {
      $('#bingo-button').hide();
      return;
    }
    $.post('/API/done_bingo', {
      card_id: this.card_id,
      room_id: this.room_id,
      times: numbers.length,
      seconds: current_time - number_arrive_time
    }, function(data) {
      var done_bingo;
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
      item_id: item_id,
      card_id: this.card_id,
      from_room_master: false
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
    get_card_numbers();
    this.checks_update();
    if (check_bingo() && !done_bingo) {
      $('#bingo-button').show();
    } else {
      $('#bingo-button').hide();
    }
  };

  this.use_item_all = function(item_id, update_card) {
    var community_id, room_id;
    room_id = this.room_id;
    community_id = this.community_id;
    $.ajaxSetup({
      async: false
    });
    $.getJSON('/API/use_item_all', {
      community_id: this.community_id,
      room_id: this.room_id,
      item_id: item_id,
      card_id: this.card_id
    }, function(json) {
      notice.push(json);
      if (update_card) {
        $.get("/API/" + community_id + "/" + room_id + "/bingo_card");
      }
    });
    $('.item-rows-' + item_id).hide();
    get_card_numbers();
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

  hide_added_number = function() {
    var j, len, number, results;
    results = [];
    for (j = 0, len = numbers.length; j < len; j++) {
      number = numbers[j];
      results.push($(".select-number-" + number).hide());
    }
    return results;
  };

  this.show_select_window = function(item_id) {
    var modalInstance;
    hide_added_number();
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

  change_item_detail = function() {
    $('.items-no-use-playing').text("このアイテムはゲーム中に使用できません");
  };

  this.joined_user_update = function() {
    $.get("/API/member_list_from_card/" + this.room_id);
  };

  get_card_numbers = function() {
    $.ajaxSetup({
      async: false
    });
    $.getJSON('/API/get_card_numbers', {
      card_id: this.card_id
    }, function(json) {
      card_numbers = json;
    });
  };

  reload_check_numbers = function() {
    var check, index, j, len, number_unchecked, ref;
    number_unchecked = false;
    for (index = j = 0, len = checks.length; j < len; index = ++j) {
      check = checks[index];
      if (check) {
        if (!(ref = parseInt(card_numbers[index]), indexOf.call(numbers, ref) >= 0) && (parseInt(card_numbers[index]) !== -1)) {
          $("#card-" + card_numbers[index]).removeClass("checked");
          $("#added-" + card_numbers[index]).removeClass("icon-cross");
          uncheck_number(index);
          number_unchecked = true;
        }
      }
    }
    if (number_unchecked) {
      if (check_bingo() && !done_bingo) {
        $('#bingo-button').show();
      } else {
        $('#bingo-button').hide();
      }
    }
  };

  get_settings = function() {
    $.getJSON('/API/get_settings', {}, function(json) {
      this.is_auto = json['auto_check'];
    });
  };

  this.auto_check = function() {
    this.is_auto = $('#auto_check').prop("checked");
    $.post('/API/auto_check', {
      is_auto_check: this.is_auto,
      card_id: this.card_id
    }, function(data) {});
  };

}).call(this);
