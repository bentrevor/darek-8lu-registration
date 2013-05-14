describe("Service", function() {
  it("sends a POST request to '/get_scores'", function() {
    jasmine.Ajax.useMock();
    service = new Service();
    service.updateScores();
    request = mostRecentAjaxRequest();
    expect(request.method).toBe('POST');
    expect(request.url).toBe('/get_scores');
  });
});
