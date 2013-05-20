function Service( gui ) {
  this.gui = gui;
}

Service.prototype.requestNewScores = function() {
  var service = this;
  $.ajax({
    type: 'GET',
    dataType: 'json',
    cache: false,
    url: '/leaderboard.json',
    success: function( data ) { service.gui.updateLeaderboard( data ); },
    error: service.gui.failSilently
  });
}
