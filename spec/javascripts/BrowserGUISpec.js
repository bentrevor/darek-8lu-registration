describe( "BrowserGUI", function() {
  var gui, jsonBen, jsonDarek, jsonSandro, fakeLeaderboardContainer, fakeJsonResponse;

  beforeEach( function() {
    gui = new BrowserGUI();
    jsonBen = {
                "name": "ben",
                "email": "ben@example.com",
                "points": 1,
                "objectsCollected": 6
              };
    jsonSandro = {
                   "name": "sandro",
                   "email": "sandro@example.com",
                   "points": 2,
                   "objectsCollected": 5
                 };
    jsonDarek = {
                  "name": "darek",
                  "email": "darek@example.com",
                  "points": 3,
                  "objectsCollected": 4
                };
    fakeJsonResponse = [ jsonBen, jsonSandro, jsonDarek ];
  });

  afterEach( function() {
    $( "#leaderboard_container" ).remove();
  });

  it( "uses json to make a name span", function() {
    expect( gui.makeNameSpan( jsonBen )).toBe( "<span class='name'>ben</span>" );
    expect( gui.makeNameSpan( jsonDarek )).toBe( "<span class='name'>darek</span>" );
  });

  it( "uses json to make gravatar span", function() {
    expect( gui.makeGravatarSpan( jsonBen )).toBe( "<span class='gravatar'><img src='http://gravatar.com/avatar/ben@example.com?d=retro' /></span>" );
    expect( gui.makeGravatarSpan( jsonDarek )).toBe( "<span class='gravatar'><img src='http://gravatar.com/avatar/darek@example.com?d=retro' /></span>" );
  });

  it( "uses json to make points span", function() {
    expect( gui.makePointsSpan( jsonBen )).toBe( "<span class='points'>1</span>" );
    expect( gui.makePointsSpan( jsonDarek )).toBe( "<span class='points'>3</span>" );
  });

  it( "uses json to make objectsCollected span", function() {
    expect( gui.makeObjectsCollectedSpan( jsonBen )).toBe( "<span class='objectsCollected'>6</span>" );
    expect( gui.makeObjectsCollectedSpan( jsonDarek )).toBe( "<span class='objectsCollected'>4</span>" );
  });

  xit( "can convert a person's json to an html string", function() {
    // pretty sure there's a better way to test something like this...
    var leaderboardBen = gui.jsonToListItem( jsonBen );
    console.log( $( "<li><span class='name'>ben</span><span class='email'>ben@example.com</span><span class='points'>1</span><span class='objectsCollected'>6</span></li>" ).children().length );

    var leaderboardDarek = gui.jsonToListItem( jsonDarek );
    expect( leaderboardDarek ).toBe( "<li><span class='name'>darek</span><span class='email'>darek@example.com</span><span class='points'>3</span><span class='objectsCollected'>4</span></li>" );
  });

  it( "sorts json responses by points", function() {
    var sortedResponse = gui.sortResponse( fakeJsonResponse );
    expectResponseToBeSorted( sortedResponse );

    fakeJSONResponse = [ jsonSandro, jsonBen, jsonDarek ];
    sortedResponse = gui.sortResponse( fakeJsonResponse );
    expectResponseToBeSorted( sortedResponse );
  });

  describe( "updating leaderboard", function() {
    beforeEach( function() {
      setUpFakeLeaderboard();
      gui.updateLeaderboard( fakeJsonResponse );
    });

    it( "adds a list item for each person in the response", function() {
      expect( fakeLeaderboard.children().length ).toBe( 3 );
    });

    it( "adds information from the response to the list item", function() {
      var firstListItem = fakeLeaderboard.children()[0];
      var firstSpan = firstListItem.children[0];
      var secondSpan = firstListItem.children[1];
      var thirdSpan = firstListItem.children[2];
      var fourthSpan = firstListItem.children[3];

      expect( firstSpan.className ).toBe( "gravatar" );
      expect( secondSpan.className ).toBe( "name" );
      expect( thirdSpan.className ).toBe( "points" );
      expect( fourthSpan.className ).toBe( "objectsCollected" );
    });

    it( "sorts the response before adding it to the list", function() {
      var gravatarUrl = $( "#leaderboard img:first" )[0].src;
      expect( gravatarUrl ).toMatch( /darek@example.com/ );
    });

    it( "clears the leaderboard before each update", function() {
      gui.updateLeaderboard( fakeJsonResponse );
      expect( fakeLeaderboard.children().length ).toBe( 3 );
    });
  });

  function setUpFakeLeaderboard() {
    fakeLeaderboardContainer = $( "<div id='leaderboard_container'>" );
    fakeLeaderboard = $( "<ol id='leaderboard'>" );
    fakeLeaderboardContainer.append( fakeLeaderboard );
    $( 'body' ).append( fakeLeaderboardContainer );
  }

  function expectResponseToBeSorted( response ) {
    expect( response[0] ).toBe( jsonDarek );
    expect( response[1] ).toBe( jsonSandro );
    expect( response[2] ).toBe( jsonBen );
  }
});
