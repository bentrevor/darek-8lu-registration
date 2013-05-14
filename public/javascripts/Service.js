function Service() {}

Service.prototype.updateScores = function() {
  $.get('/update_scores');
}
