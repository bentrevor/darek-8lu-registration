describe( "Service", function() {
  var service;

  beforeEach( function() {
    jasmine.Ajax.useMock();
    fakeGUI = jasmine.createSpyObj('fakeGUI', ['updateLeaderboard',
                                               'failSilently'] );
    service = new Service( fakeGUI );
  });

  afterEach( function() {
    clearAjaxRequests();
  });

  it( "sends a GET request to '/leaderboard.json'", function() {
    service.requestNewScores();
    var request = mostRecentAjaxRequest();

    expect( request.method ).toBe( 'GET' );
    expect( request.url ).toMatch( /leaderboard.json/ );
  });

  it( "adds a timestamp to the url to prevent caching", function() {
    service.requestNewScores();
    var firstURL = mostRecentAjaxRequest().url;
    var firstTimestamp = getTimestampFrom( firstURL );

    service.requestNewScores();
    var secondURL = mostRecentAjaxRequest().url;
    var secondTimestamp = getTimestampFrom( secondURL );

    expect( firstTimestamp ).toBeLessThan( secondTimestamp );
  });

  describe( "callbacks", function() {
    it( "sends a reloadLeaderboard message for successful requests", function() {
      service.requestNewScores();
      var request = mostRecentAjaxRequest();
      request.response( TestResponses.requestNewScores.success );
      expect( fakeGUI.updateLeaderboard ).toHaveBeenCalled();
    });

    it( "sends response json to reload the leaderboard", function() {
      service.requestNewScores();
      var request = mostRecentAjaxRequest();
      request.response( TestResponses.requestNewScores.success_with_full_json );
      expect( fakeGUI.updateLeaderboard ).toHaveBeenCalledWith( JSON.parse( request.responseText ));
    });

    it( "sends a failSilently message for failed requests", function() {
      service.requestNewScores();
      var request = mostRecentAjaxRequest();
      request.response( TestResponses.requestNewScores.error );
      expect( fakeGUI.failSilently ).toHaveBeenCalled();
    });
  });

  function getTimestampFrom( url ) {
    return parseInt( url.slice( url.indexOf( '=' ) + 1 ));
  }
});
