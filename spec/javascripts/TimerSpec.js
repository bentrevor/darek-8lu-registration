describe( "Timer", function() {
  it( "requests new scores every second", function() {
    jasmine.Clock.useMock();
    var fake_service = jasmine.createSpyObj( 'fake_service', ['requestNewScores'] );

    var timer = new Timer( fake_service );
    timer.activateLeaderboard();

    expect( timer.service.requestNewScores ).not.toHaveBeenCalled();
    jasmine.Clock.tick( 1001 );
    expect( timer.service.requestNewScores ).toHaveBeenCalled();
    expect( timer.service.requestNewScores.callCount ).toBe( 1 );
    jasmine.Clock.tick( 1001 );
    expect( timer.service.requestNewScores.callCount ).toBe( 2 );
  });
});

