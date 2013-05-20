var TestResponses = {
  requestNewScores: {
    success: {
      status: 200,
      responseText: '{}'
    },

    success_with_full_json: {
      status: 200,
      responseText: '[ { "name": "Ben", "email": "ben_email@example.com", "points": 5, "objectsCollected": 3 }, { "name": "Darek", "email": "darek_email@example.com", "points": 3, "objectsCollected": 5 } ]'
    },

    error: {
      status: 500,
      responseText: '{}'
    }
  }
}
