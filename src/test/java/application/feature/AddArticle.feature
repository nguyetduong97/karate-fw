Feature: Add Articles

  Background: Define URL
    Given url apiUrl

  Scenario: Create a new article
    Given path 'articles'
    And request {"article": {"tagList": [],"title": "Articles-12362","description": "des","body": "body"}}
    When method Post
    Then status 200
    And match response.article.title == 'Articles-12362'
    * def slugs = get response.article.slug
    * def favCounts = get response.article.favoritesCount
##    And print slugs
##    And print favCounts