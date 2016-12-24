(function() {
  this.show_detail = function() {
    $('#community-detail').toggle('fast');
  };

  this.show_members = function() {
    $('#community-members').toggle('slow');
  };

  this.toggle_administrator = function(community_id, user_id) {
    return $.getJSON('/API/toggle_administrator', {
      community_id: community_id,
      user_id: user_id
    }, function(json) {
      if (json) {
        $(".organize-" + user_id).text("有");
      } else {
        $(".organize-" + user_id).text("無");
      }
    });
  };

}).call(this);
