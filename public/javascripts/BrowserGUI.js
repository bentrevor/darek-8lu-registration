function BrowserGUI() {}

BrowserGUI.prototype.failSilently = function() {
  console.log( "the request was unsuccessful" );
}

BrowserGUI.prototype.updateLeaderboard = function( responseJson ) {
  response = this.sortResponse( responseJson );
  var newLeaderboardString = "";

  for( var i = 0; i < response.length; i++ ) {
    var personJson = response[i];
    newLeaderboardString += this.jsonToListItem( personJson );
  }

  $( "#leaderboard" ).html( newLeaderboardString );
}

BrowserGUI.prototype.jsonToListItem = function( jsonObject ) {
  var nameSpan = this.makeNameSpan( jsonObject );
  var GravatarSpan = this.makeGravatarSpan( jsonObject );
  var pointsSpan = this.makePointsSpan( jsonObject );
  var objectsCollectedSpan = this.makeObjectsCollectedSpan( jsonObject );
  return "<li>" + GravatarSpan + nameSpan + pointsSpan + objectsCollectedSpan + "</li>";
}

BrowserGUI.prototype.makeNameSpan = function( jsonObject ) {
  return "<span class='name'>" + jsonObject.name + "</span>";
}

BrowserGUI.prototype.makeGravatarSpan = function( jsonObject ) {
  var gravatarString = "<span class='gravatar'>";
  gravatarString += "<img src='http://gravatar.com/avatar/" + jsonObject.email + "?d=retro' /></span>" ;
  return gravatarString;
}

BrowserGUI.prototype.makePointsSpan = function( jsonObject ) {
  return "<span class='points'>" + jsonObject.points + "</span>";
}

BrowserGUI.prototype.makeObjectsCollectedSpan = function( jsonObject ) {
  return "<span class='objectsCollected'>" + jsonObject.objectsCollected + "</span>";
}

BrowserGUI.prototype.sortResponse = function( jsonObject ) {
  return jsonObject.sort( pointsDesc );

  function pointsDesc( firstPerson, secondPerson ) {
    return firstPerson.points < secondPerson.points;
  }
}
