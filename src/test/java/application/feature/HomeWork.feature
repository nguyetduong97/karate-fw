@debug
Feature: Validate favorite and comment function

  Background: Preconditions
    * url apiUrl
    * configure ssl = true

  Scenario: Favorite articles
#         Step 1: Add new article (optimize here - Create a AddArticle.feature)
    Given path 'articles'
    And request {"article": {"tagList": [],"title": "Articles-012361","description": "des","body": "body"}}
    When method Post
    Then status 200
    And match response.article.title == 'Articles-012361'
        # Step 2: Get the favorites count and slug ID for the the article, save it to variables
    * def slugID = get response.article.slug
    * def favCount = get response.article.favoritesCount
    And print slugID
    And print favCount
#    <---------Optimize--------->
#    * def new = call read ('AddArticles.feature')
#    * def slugID = new.slugs
#    * def favCount = new.favCounts
#    And print slugID
#    And print favCount

        # Step 3: Make POST request to increase favorites count for the article
    Given path 'articles',slugID,'favorite'
    When method Post
    Then status 200
        # Step 4: Verify response schema
    * def schema1 =
          """
          {
            "article": {
                        "id": '#number',
                        "slug": '#string',
                        "title": '#string',
                        "description": '#string',
                        "createdAt": '#string',
                        "updatedAt": '#string',
                        "authorId": '#number',
                        "director": '#string',
                        "tagList": '#array',
                        "author":{
                                "username": '#string',
                                "bio": '#string',
                                "image": '#string',
                                "following": '#boolean',
                            },
                        "favoritedBy":{
                                "id": '#number',
                                "email: '#string',
                                "username": '#string',
                                "password": '#string',
                                "image": '#string',
                                "bio": '#string',
                                "demo": '#boolean',
                            }
                        "favorited": '#boolean',
                        "favoritesCount": '#number'
                    }
          }
          """
    And match response == schema1
        # Step 5: Verify that favorites article incremented by 1
    * def initialCount = 0
    * match response.article.favoritesCount == initialCount + 1
        # Step 6: Get all favorite articles
    * def favoritedName = response.article.favoritedBy.username
    Given path 'articles'
    And params favoritedName
    When method Get
    Then status 200
        # Step 7: Verify response schema
    * def schema2 = 
          """
          {
                "article": {
                    "slug": '#string',
                    "title": '#string',
                    "description": '#string',
					"body": '#string',
                    "createdAt": '#string',
                    "updatedAt": '#string',
                    "authorId": '#number',
                    "director": '#string',
                    "tagList": '#array',
                    "author":{
                        "username": '#string',
                        "bio": '#string',
                        "image": '#string',
                        "following": '#boolean',
                    },
                    "favoritesCount": '#number',
					"favorited": '#boolean'
                }
				"articlesCount": '#number'
           }
          """
    And match response == schema2
        # Step 8: Verify that slug ID from Step 2 exist in one of the favorite articles
    And match response.article.slug == slugID
        # Step 9: Delete the article (optimize here with afterScenario - create a Hook.feature)
    Given path 'articles', slugID
    When method Delete
    Then status 204

  Scenario: Comment articles
        # Step 1: Add new article (optimize here - Create a AddArticle.feature)
    * def newArt = call read ('AddArticle.feature')
    * def res = newArt.response
        # Step 2: Get the slug ID for the article, save it to variable
    * def slugID = res.articles.slug
        # Step 3: Make a GET call to 'comments' end-point to get all comments
    Given path 'articles', slugID, 'comments'
    When method Get
    Then status 200
        # Step 4: Verify response schema
    * def schema =
          """
            {
                "comments": '#array'
            }
          """
    And match response == schema
        # Step 5: Get the count of the comments array length and save to variable
    * def responseWithComments = [{"article": "first"}, {article: "second"}]
    * def articlesCount = responseWithComments.length
        # Step 6: Make a POST request to publish a new comment
    Given path 'articles', slugID, 'comments'
    And request { "comment": { "body": "My comments"}}
    When method Post
    Then status 200
        # Step 7: Verify response schema that should contain posted comment text
    * def resSchema =
          """
            {
              "comment":{
                  "id": '#number',
                  "createdAt": '#string',
                  "updatedAt": '#string',
                  "body": '#string',
                  "author": {
                      "username": '#string',
                      "bio": '#string',
                      "image": '#string',
                      "following": '#boolean'
                  }
              }
            }
          """
    And match response == resSchema
        # Step 8: Get the list of all comments for this article one more time
    Given path 'articles', slugID, 'comments'
    When method Get
    Then status 200
        # Step 9: Verify number of comments increased by 1 (similar like we did with favorite counts)
    * def initialComment = []
    * def commentsCount = initialComment + 1
    And match response.comments.length = commentsCount
        # Step 10: Make a DELETE request to delete comment
    * def commentsId = response.comments[0].id
    Given path 'articles', slugID, 'comments', commentsId
    When method Delete
    Then status 204
        # Step 11: Get all comments again and verify number of comments decreased by 1
    Given path 'articles', slugID, 'comments'
    When method Get
    Then status 200
    And match response.comments.length = commentsCount - 1
        # Step 12: Delete the article (optimize here with afterScenario - create a Hook.feature)
    Given path 'articles', slugID
    When method Delete
    Then status 204