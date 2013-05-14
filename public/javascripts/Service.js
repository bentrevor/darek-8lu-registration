function Service() {}

Service.prototype.updateScores = function() {
  $.post('/get_scores');
}
