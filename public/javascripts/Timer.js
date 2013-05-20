function Timer( service ) {
  this.service = service
}

Timer.prototype.activateLeaderboard = function() {
  var timer = this;

  setInterval( function() {
    timer.service.requestNewScores();
  }, 1000);
}
