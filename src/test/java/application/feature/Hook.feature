Feature: Delete Articles

  Background: Define URL
    Given url apiUrl

  Scenario: Deleted a new article
    Given path 'articles',slugID
    When method Delete
    Then status 204