(function() {
  var rate;

  rate = [];

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

}).call(this);
