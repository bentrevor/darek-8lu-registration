describe( "Service", function() {
  var service;

  beforeEach( function() {
    jasmine.Ajax.useMock();
    service = new Service();
  });

  afterEach( function() {
    clearAjaxRequests();
  });


  it( "sends a GET request to '/update_scores'", function() {
    service.updateScores();
    var request = mostRecentAjaxRequest();

    expect( request.method ).toBe( 'GET' );
    expect( request.url ).toBe( '/update_scores' );
  });

  it( "doesn't change leaderboard when request fails", function() {
    var fake_leaderboard = $( "<div id='leaderboard'>" );
    var fake_leaders = $( "<ol><li>first place</li><li>second place</li></ol>" );
    fake_leaderboard.append( fake_leaders );

    var leaderboard_before_request = fake_leaderboard[0].innerHTML;
    service.updateScores();
    var request = mostRecentAjaxRequest();
    request.response( TestResponses.updateScores.error );

    expect( fake_leaderboard[0].innerHTML ).toEqual( leaderboard_before_request );
  });
});
