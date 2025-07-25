import GraphAPI
@testable import KsApi
import Prelude
import XCTest

final class Project_ProjectFragmentTests: XCTestCase {
  func test() {
    do {
      let variables = [
        "withStoredCards": true
      ]
      let fragment: GraphAPI.ProjectFragment = try testGraphObject(
        jsonObject: self.projectDictionary(),
        variables: variables
      )
      XCTAssertNotNil(fragment)

      let project = Project.project(
        from: fragment,
        flagging: false,
        currentUserChosenCurrency: nil
      )

      guard let project = project else {
        XCTFail("project should not be nil")

        return
      }

      XCTAssertEqual(project.country.countryCode, Project.Country.us.countryCode)
      XCTAssertEqual(project.country.currencySymbol, Project.Country.us.currencySymbol)
      XCTAssertEqual(project.country.currencyCode, Project.Country.us.currencyCode)
      XCTAssertEqual(project.country.maxPledge, 8_500)
      XCTAssertEqual(project.country.minPledge, 23)
      XCTAssertEqual(project.country.trailingCode, true)
      XCTAssertEqual(project.availableCardTypes?.count, 7)
      XCTAssertEqual(
        project.blurb,
        "In this unforgiving Hell, people are forced to fight to the death in an elite gamble for their souls."
      )
      XCTAssertEqual(project.category.name, "Comic Books")
      XCTAssertEqual(project.creator.id, decompose(id: "VXNlci0xMDA3NTM5MDAy"))
      XCTAssertEqual(project.memberData.permissions.last, .comment)
      XCTAssertEqual(project.dates.deadline, 1_630_591_053)
      XCTAssertEqual(project.id, 1_841_936_784)

      XCTAssertNotNil(project.lastWave)
      XCTAssertEqual(project.lastWave!.id, 259)
      XCTAssertTrue(project.lastWave!.active)

      XCTAssertEqual(project.location.country, "US")
      XCTAssertEqual(project.name, "FINAL GAMBLE Issue #1")

      XCTAssertNotNil(project.pledgeManager)
      XCTAssertEqual(project.pledgeManager!.id, 91)
      XCTAssertTrue(project.pledgeManager!.acceptsNewBackers)

      XCTAssertEqual(project.slug, "final-gamble-issue-1")
      XCTAssertEqual(
        project.photo.full,
        "https://i.kickstarter.com/assets/034/416/156/330099be1dd12ed741db4e29d9986840_original.png?anim=false&fit=crop&gravity=auto&height=576&origin=ugc-qa&q=92&width=1024&sig=%2BfXp6C0bOuArZrlbbzH6wEiTgIv6mY1NXCrDVnC9ZfI%3D"
      )
      XCTAssertEqual(project.state, .live)
      XCTAssertEqual(project.stats.convertedPledgedAmount!, 4_509.09467367)
      XCTAssertEqual(project.tags!.first!, "LGBTQIA+")
      XCTAssertEqual(
        project.urls.web.updates!,
        "https://staging.kickstarter.com/projects/bandofbards/final-gamble-issue-1/posts"
      )
      XCTAssertEqual(
        project.video?.high,
        "https://v.kickstarter.com/1631473358_b73a85bd690a6353b9e29af6ef78496e2d20858c/projects/4196183/video-1116448-h264_high.mp4"
      )
      XCTAssertTrue(project.rewardData.rewards.isEmpty)
      XCTAssertTrue(project.staffPick)
      XCTAssertTrue(project.prelaunchActivated!)

      XCTAssertEqual(
        project.redemptionPageUrl,
        "https://www.kickstarter.com/projects/creator/a-fun-project/backing/redeem"
      )

      XCTAssertFalse(project.displayPrelaunch!)
      XCTAssertEqual(project.flagging, false)
      XCTAssertNil(project.personalization.backing)
      XCTAssertNil(project.rewardData.addOns)
      XCTAssertEqual(project.sendMetaCapiEvents, false)
      XCTAssertEqual(project.watchesCount, 18)
      XCTAssertEqual(project.pledgeOverTimeMinimumExplanation, "Available for pledges over $125")
      XCTAssertFalse(project.isPledgeOverTimeAllowed!)

      guard let extendedProjectProperties = project.extendedProjectProperties,
            extendedProjectProperties.story.htmlViewElements.count > 3,
            let textElement = extendedProjectProperties.story.htmlViewElements[2] as? TextViewElement,
            let imageViewElement = extendedProjectProperties.story.htmlViewElements[8] as? ImageViewElement,
            let audioVideoViewElement = extendedProjectProperties.story
            .htmlViewElements[11] as? AudioVideoViewElement,
            let externalSourceViewElement = extendedProjectProperties.story
            .htmlViewElements[17] as? ExternalSourceViewElement,
            textElement.components.count > 5 else {
        XCTFail("extended project properties should exist.")

        return
      }

      let textComponent = textElement.components[4]

      XCTAssertEqual(extendedProjectProperties.story.htmlViewElements.count, 20)
      XCTAssertEqual(textElement.components.count, 31)
      XCTAssertEqual(textComponent.text, "AFC")
      XCTAssertEqual(
        textComponent.link,
        "https://www.goal.com/en/news/afc-richmond-real-team-ted-lasso-club-inspiration-stadium/dsktplas5tln1usbhdmqjarih#afc-richmond-real-team"
      )
      XCTAssertEqual(textComponent.styles, [.emphasis, .link])

      XCTAssertEqual(
        imageViewElement.src,
        "https://i.kickstarter.com/assets/035/659/917/05e192776dee3dc2a94e45f3ed8501d3_original.jpg?fit=contain&origin=ugc-qa&q=92&width=700&sig=8Un2%2BgHZIPWQXlblIpZEPB4SxZhlJksAbulYYBNOo5Y%3D"
      )
      XCTAssertEqual(imageViewElement.caption, "Ice baths are great")
      XCTAssertNil(imageViewElement.href)

      XCTAssertEqual(
        audioVideoViewElement.sourceURLString,
        "https://v.kickstarter.com/1646345127_8366452d275cb8330ca0cee82a6c5259a1df288e/assets/035/786/501/b99cdfe87fc9b942dce0fe9a59a3767a_h264_high.mp4"
      )
      XCTAssertEqual(
        audioVideoViewElement.thumbnailURLString,
        "https://dr0rfahizzuzj.cloudfront.net/assets/035/786/501/b99cdfe87fc9b942dce0fe9a59a3767a_h264_base.jpg?2021"
      )
      XCTAssertEqual(audioVideoViewElement.seekPosition, .zero)

      XCTAssertEqual(
        externalSourceViewElement.embeddedURLString,
        "https://open.spotify.com/embed/track/0dpyzcT3RMNNSd2xKBf35I?si=8c3a869d82464083&utm_source=oembed"
      )
      XCTAssertEqual(externalSourceViewElement.embeddedURLContentHeight, 80)

      guard let aiDisclosureRawData = extendedProjectProperties.aiDisclosure else {
        XCTFail("AI disclosure should contain data.")

        return
      }

      XCTAssertEqual(aiDisclosureRawData.id, decompose(id: "QWlEaXNjbG9zdXJlLTE="))
      XCTAssertTrue(aiDisclosureRawData.funding.fundingForAiAttribution)
      XCTAssertFalse(aiDisclosureRawData.funding.fundingForAiConsent)
      XCTAssertFalse(aiDisclosureRawData.funding.fundingForAiOption)
      XCTAssertFalse(aiDisclosureRawData.generationDisclosure!.consent!.isEmpty)
      XCTAssertFalse(aiDisclosureRawData.generationDisclosure!.details!.isEmpty)
      XCTAssertTrue(aiDisclosureRawData.involvesAi)
      XCTAssertTrue(aiDisclosureRawData.involvesFunding)
      XCTAssertTrue(aiDisclosureRawData.involvesGeneration)
      XCTAssertFalse(aiDisclosureRawData.involvesOther)
      XCTAssertNil(aiDisclosureRawData.otherAiDetails)

      XCTAssertNotNil(extendedProjectProperties.risks)
      XCTAssertEqual(extendedProjectProperties.environmentalCommitments.count, 1)
      XCTAssertEqual(
        extendedProjectProperties.environmentalCommitments.last?.category,
        .longLastingDesign
      )
      XCTAssertEqual(
        extendedProjectProperties.environmentalCommitments.last?.description,
        "High quality materials and cards - there is nothing design or tech-wise that would render Dustbiters obsolete besides losing the cards."
      )
      XCTAssertEqual(
        extendedProjectProperties.environmentalCommitments.last?.id,
        decompose(id: "RW52aXJvbm1lbnRhbENvbW1pdG1lbnQtMTI2NTA2")
      )
      XCTAssertEqual(extendedProjectProperties.faqs.count, 1)
      XCTAssertEqual(
        extendedProjectProperties.faqs.last!.question,
        "Are you planning any expansions for Dustbiters?"
      )
      XCTAssertEqual(
        extendedProjectProperties.faqs.last!.answer,
        "This may sound weird in the world of big game boxes with hundreds of tokens, cards and thick manuals, but through years of playtesting and refinement we found our ideal experience is these 21 unique cards we have now. Dustbiters is balanced for quick and furious games with different strategies every time you jump back in, and we currently have no plans to mess with that."
      )
      XCTAssertEqual(
        extendedProjectProperties.faqs.last!.id,
        decompose(id: "UHJvamVjdEZhcS0zNzA4MDM=")
      )
      XCTAssertEqual(extendedProjectProperties.faqs.last!.createdAt!, TimeInterval(1_628_103_400))
      XCTAssertEqual(extendedProjectProperties.minimumPledgeAmount, 23)
    } catch {
      XCTFail(error.localizedDescription)
    }
  }

  private func projectDictionary() -> [String: Any] {
    let json = """
    {
       "__typename":"Project",
       "availableCardTypes":[
          "VISA",
          "MASTERCARD",
          "AMEX",
          "DISCOVER",
          "JCB",
          "DINERS",
          "UNION_PAY"
       ],
       "backersCount":78,
       "category":{
          "__typename":"Category",
          "id":"Q2F0ZWdvcnktMjUw",
          "name":"Comic Books",
          "analyticsName":"Comic Books",
          "parentCategory":{
             "__typename":"Category",
             "id":"Q2F0ZWdvcnktMw==",
             "name":"Comics",
             "analyticsName":"Comics",
          }
       },
       "canComment":true,
       "commentsCount":0,
       "country":{
          "__typename":"Country",
          "code":"US",
          "name":"the United States"
       },
       "creator":{
          "__typename":"User",
          "chosenCurrency":null,
          "backings":{
             "__typename":"UserBackingsConnection",
             "nodes":[
                {
                   "__typename":"Backing",
                   "errorReason":null
                },
                {
                   "__typename":"Backing",
                   "errorReason":"Something went wrong"
                },
                {
                   "__typename":"Backing",
                   "errorReason":null
                }
             ]
          },
          "newsletterSubscriptions":{
             "__typename":"NewsletterSubscriptions",
             "artsCultureNewsletter":true,
             "filmNewsletter":false,
             "musicNewsletter":false,
             "inventNewsletter":false,
             "publishingNewsletter":false,
             "promoNewsletter":false,
             "weeklyNewsletter":false,
             "happeningNewsletter":false,
             "gamesNewsletter":false,
             "alumniNewsletter":true
          },
          "optedOutOfRecommendations":true,
          "ppoHasAction": false,
          "notifications":[
             {
                "__typename":"Notification",
                "topic":"messages",
                "email":true,
                "mobile":true
             },
             {
                "__typename":"Notification",
                "topic":"backings",
                "email":false,
                "mobile":true
             },
             {
                "__typename":"Notification",
                "topic":"creator_digest",
                "email":true,
                "mobile":false
             },
             {
                "__typename":"Notification",
                "topic":"updates",
                "email":true,
                "mobile":true
             },
             {
                "__typename":"Notification",
                "topic":"follower",
                "email":true,
                "mobile":true
             },
             {
                "__typename":"Notification",
                "topic":"friend_activity",
                "email":true,
                "mobile":false
             },
             {
                "__typename":"Notification",
                "topic":"friend_signup",
                "email":true,
                "mobile":true
             },
             {
                "__typename":"Notification",
                "topic":"comments",
                "email":true,
                "mobile":true
             },
             {
                "__typename":"Notification",
                "topic":"comment_replies",
                "email":true,
                "mobile":true
             },
             {
                "__typename":"Notification",
                "topic":"creator_edu",
                "email":true,
                "mobile":true
             },
             {
                "__typename":"Notification",
                "topic":"marketing_update",
                "email":true,
                "mobile":false
             },
             {
                "__typename":"Notification",
                "topic":"project_launch",
                "email":true,
                "mobile":true
             }
          ],
          "createdProjects":{
             "__typename":"UserCreatedProjectsConnection",
             "totalCount":16
          },
          "membershipProjects":{
             "__typename":"MembershipProjectsConnection",
             "totalCount":10
          },
          "savedProjects":{
             "__typename":"UserSavedProjectsConnection",
             "totalCount":11
          },
          "backingsCount":3,
          "hasUnreadMessages":false,
          "isSocializing":true,
          "hasUnseenActivity":true,
          "email":"t@example.com",
          "hasPassword":null,
          "id":"VXNlci0xMDA3NTM5MDAy",
          "imageUrl":"fake-image-url",
          "isAppleConnected":null,
          "isBlocked":false,
          "isCreator":true,
          "isDeliverable":null,
          "isEmailVerified":true,
          "isFacebookConnected":true,
          "isKsrAdmin":false,
          "isFollowing":true,
          "name":"Creator Tiger",
          "needsFreshFacebookToken":false,
          "showPublicProfile":true,
          "uid":"11",
          "location":{
             "__typename":"Location",
             "country":"US",
             "countryName":"United States",
             "displayableName":"Las Vegas, NV",
             "id":"TG9jYXRpb24tMjQzNjcwNA==",
             "name":"Las Vegas"
          },
          "surveyResponses": {
             "__typename":"SurveyResponsesConnection",
             "totalCount": 2
          },
          "storedCards":{
             "__typename":"UserCreditCardTypeConnection",
             "nodes":[

             ],
             "totalCount":0
          }
       },
       "currency":"USD",
       "deadlineAt":1630591053,
       "description":"In this unforgiving Hell, people are forced to fight to the death in an elite gamble for their souls.",
       "finalCollectionDate":null,
       "fxRate":1.26411401,
       "friends":{
          "__typename":"ProjectBackerFriendsConnection",
          "nodes":[

          ]
       },
       "goal":{
          "__typename":"Money",
          "amount":"6000.0",
          "currency":"USD",
          "symbol":"$"
       },
       "image":{
          "__typename":"Photo",
          "id":"UGhvdG8tMzQ0MTYxNTY=",
          "url":"https://i.kickstarter.com/assets/034/416/156/330099be1dd12ed741db4e29d9986840_original.png?anim=false&fit=crop&gravity=auto&height=576&origin=ugc-qa&q=92&width=1024&sig=%2BfXp6C0bOuArZrlbbzH6wEiTgIv6mY1NXCrDVnC9ZfI%3D"
       },
       "isProjectWeLove":true,
       "isProjectOfTheDay":false,
       "isWatched":false,
       "isLaunched":true,
       "launchedAt":1627999053,
       "lastWave": {
          "__typename":"CheckoutWave",
          "id": "Q2hlY2tvdXRXYXZlLTI1OQ==",
          "active": true
       },
       "location":{
          "__typename":"Location",
          "country":"US",
          "countryName":"United States",
          "displayableName":"Buffalo, NY",
          "id":"TG9jYXRpb24tMjM3MTQ2NA==",
          "name":"Buffalo"
       },
       "maxPledge": 8500,
       "minPledge": 23,
       "name":"FINAL GAMBLE Issue #1",
       "pledgeManager": {
          "__typename":"PledgeManager",
          "id": "UGxlZGdlTWFuYWdlci05MQ==",
          "acceptsNewBackers": true
       },
       "pid":1841936784,
      "pledgeOverTimeCollectionPlanChargeExplanation": "The first charge will occur when the project ends successfully, then every 2 weeks until fully paid. When this option is selected no further edits can be made to your pledge.",
      "pledgeOverTimeCollectionPlanChargedAsNPayments": "charged as four payments",
      "pledgeOverTimeCollectionPlanShortPitch": "You will be charged for your pledge over four payments, at no extra cost.",
      "pledgeOverTimeMinimumExplanation": "Available for pledges over $125",
       "pledged":{
          "__typename":"Money",
          "amount":"3567.0",
          "currency":"USD",
          "symbol":"$"
       },
       "isInPostCampaignPledgingPhase": false,
       "postCampaignPledgingEnabled": false,
       "posts":{
          "__typename":"PostConnection",
          "totalCount":3
       },
       "prelaunchActivated": true,
       "redemptionPageUrl": "https://www.kickstarter.com/projects/creator/a-fun-project/backing/redeem",
       "projectNotice": null,
       "sendMetaCapiEvents": false,
       "slug":"bandofbards/final-gamble-issue-1",
       "state":"LIVE",
       "stateChangedAt":1627999055,
       "tags":[
          {
             "__typename":"Tag",
             "name":"LGBTQIA+"
          }
       ],
       "story": "API returns this as HTML wrapped in a string. But here HTML breaks testing because the serializer does not recognize escape characters within a string.",
       "environmentalCommitments": [
         {
           "__typename": "EnvironmentalCommitment",
           "commitmentCategory": "longLastingDesign",
           "description": "High quality materials and cards - there is nothing design or tech-wise that would render Dustbiters obsolete besides losing the cards.",
           "id": "RW52aXJvbm1lbnRhbENvbW1pdG1lbnQtMTI2NTA2"
         }
       ],
       "aiDisclosure": {
         "__typename": "AiDisclosure",
         "id": "QWlEaXNjbG9zdXJlLTE=",
         "fundingForAiAttribution": true,
         "fundingForAiConsent": false,
         "fundingForAiOption": false,
         "generatedByAiConsent": "Yes! You can see more information about how I went about capturing consent of the artists and photographers whose works I used on my website.",
         "generatedByAiDetails": "For my project, the cover art for the cover of the DVD will use existing images of Paragon Park, and will leverage AI technology to simulate what the park would have looked like with attendees and visitors moving around.",
         "involvesAi": true,
         "involvesFunding": true,
         "involvesGeneration": true,
         "involvesOther": false,
         "otherAiDetails": null
       },
       "faqs": {
         "__typename": "ProjectFaqConnection",
         "nodes": [
           {
             "__typename": "ProjectFaq",
             "question": "Are you planning any expansions for Dustbiters?",
             "answer": "This may sound weird in the world of big game boxes with hundreds of tokens, cards and thick manuals, but through years of playtesting and refinement we found our ideal experience is these 21 unique cards we have now. Dustbiters is balanced for quick and furious games with different strategies every time you jump back in, and we currently have no plans to mess with that.",
             "id": "UHJvamVjdEZhcS0zNzA4MDM=",
             "createdAt": 1628103400
           }
         ]
       },
       "risks": "As with any project of this nature, there are always some risks involved with manufacturing and shipping. That's why we're collaborating with the iam8bit team, they have many years of experience producing and delivering all manner of items to destinations all around the world. We do not expect any delays or hiccups with reward fulfillment. But if anything comes up, we will be clear and communicative about what is happening and how it might affect you.",
       "url":"https://staging.kickstarter.com/projects/bandofbards/final-gamble-issue-1",
       "usdExchangeRate":1,
       "video":{
          "__typename":"Video",
          "id":"VmlkZW8tMTExNjQ0OA==",
          "videoSources":{
             "__typename":"VideoSources",
             "high":{
                "__typename":"VideoSourceInfo",
                "src":"https://v.kickstarter.com/1631473358_b73a85bd690a6353b9e29af6ef78496e2d20858c/projects/4196183/video-1116448-h264_high.mp4"
             },
             "hls":{
                "__typename":"VideoSourceInfo",
                "src":"https://v.kickstarter.com/1631473358_b73a85bd690a6353b9e29af6ef78496e2d20858c/projects/4196183/video-1116448-hls_playlist.m3u8"
             }
          }
       },
      "watchesCount": 18,
      "isPledgeOverTimeAllowed": false
    }
    """

    let data = Data(json.utf8)
    var resultMap = (try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]) ?? [:]

    let updatedEnvironmentalCommitments =
      [[
        "__typename": "EnvironmentalCommitment",
        "commitmentCategory": GraphAPI.EnvironmentalCommitmentCategory.longLastingDesign.rawValue,
        "description": "High quality materials and cards - there is nothing design or tech-wise that would render Dustbiters obsolete besides losing the cards.",
        "id": "RW52aXJvbm1lbnRhbENvbW1pdG1lbnQtMTI2NTA2"
      ]]

    let updatedFaqs =
      [
        "__typename": "ProjectFaqConnection",
        "nodes": [[
          "__typename": "ProjectFaq",
          "question": "Are you planning any expansions for Dustbiters?",
          "answer": "This may sound weird in the world of big game boxes with hundreds of tokens, cards and thick manuals, but through years of playtesting and refinement we found our ideal experience is these 21 unique cards we have now. Dustbiters is balanced for quick and furious games with different strategies every time you jump back in, and we currently have no plans to mess with that.",
          "id": "UHJvamVjdEZhcS0zNzA4MDM=",
          "createdAt": "1628103400"
        ]]
      ] as [String: Any]

    resultMap["faqs"] = updatedFaqs
    resultMap["environmentalCommitments"] = updatedEnvironmentalCommitments
    resultMap["story"] =
      """
                <h1 id="h:whoop-whoop" class="page-anchor">Whoop whoop</h1>\n<p>Coach Lasso must navigate the team through encounters with the best teams in English football, despite having no prior experience in the sport.</p>\n<ol> \n <li> <a href="https://www.goal.com/en/news/afc-richmond-real-team-ted-lasso-club-inspiration-stadium/dsktplas5tln1usbhdmqjarih#afc-richmond-real-team" target="_blank" rel="noopener">Is <em>AFC</em></a> <a href="https://www.goal.com/en/news/afc-richmond-real-team-ted-lasso-club-inspiration-stadium/dsktplas5tln1usbhdmqjarih#afc-richmond-real-team" target="_blank" rel="noopener"><em><strong>Richmond</strong></em></a> <a href="https://www.goal.com/en/news/afc-richmond-real-team-ted-lasso-club-inspiration-stadium/dsktplas5tln1usbhdmqjarih#afc-richmond-real-team" target="_blank" rel="noopener">a real<strong> team</strong>?</a> </li>\n <li><a href="https://www.goal.com/en/news/afc-richmond-real-team-ted-lasso-club-inspiration-stadium/dsktplas5tln1usbhdmqjarih#real-footballers" target="_blank" rel="noopener">Are there real footballers in Ted Lasso?</a></li>\n <li><a href="https://www.goal.com/en/news/afc-richmond-real-team-ted-lasso-club-inspiration-stadium/dsktplas5tln1usbhdmqjarih#stadium" target="_blank" rel="noopener"><em>Which stadium do AFC Richmond play in?</em></a></li>\n <li> <strong>Ted </strong>Lasso<em>filming</em><em><strong>locations</strong></em> </li>\n</ol>\n<p><strong>AFC Richmond</strong> is a fictional team, despite being portrayed as a competitor in the <em>Premier League</em> in the <strong>Ted Lasso</strong> TV series.</p>\n<p>However, while Coach Lasso's team is not real, the club understandably takes some inspiration from actual football teams in England and plays up to the idea that it is real.</p>\n<p><a href="https://www.goal.com/en/news/afc-richmond-real-team-ted-lasso-club-inspiration-stadium/dsktplas5tln1usbhdmqjarih" target="_blank" rel="noopener">Read it all here</a></p>\n<h1 id="h:show-me-the-deal" class="page-anchor">Show me the deal </h1>\n\n<div class="template asset" contenteditable="false" data-alt-text="" data-caption="" data-id="35659916"> \n <figure>\n<img alt="" class="fit" src="https://i.kickstarter.com/assets/035/659/916/0b0c6239321146d5aaa32468f3ef6d6e_original.jpg?fit=contain&amp;origin=ugc-qa&amp;q=92&amp;width=700&amp;sig=97M3OKJ1oaR5RHoKPN2WxPdG3VRe7D8eQYC6UjQ3GA8%3D">\n</figure> \n\n</div>\n\n\n<div class="template asset" contenteditable="false" data-alt-text="" data-caption="Ice baths are great" data-id="35659917">\n<figure> \n<img alt="" class="fit" src="https://i.kickstarter.com/assets/035/659/917/05e192776dee3dc2a94e45f3ed8501d3_original.jpg?fit=contain&amp;origin=ugc-qa&amp;q=92&amp;width=700&amp;sig=8Un2%2BgHZIPWQXlblIpZEPB4SxZhlJksAbulYYBNOo5Y%3D">\n <figcaption class="px2">Ice baths are great</figcaption> \n</figure>\n\n</div>\n\n\n<a href="https://www.youtube.com/watch?v=KuM8VGvBIVk" target="_blank" rel="noopener"> <div class="template asset" contenteditable="false" data-alt-text="" data-caption="Football is life" data-id="35659918">\n <figure> \n<img alt="" class="fit" src="https://i.kickstarter.com/assets/035/659/918/aac45095dc7d2071c12c22f734e0776a_original.jpg?fit=contain&amp;origin=ugc-qa&amp;q=92&amp;width=700&amp;sig=xXtPYyZOihDtieWJhKKwtFW%2F2TBS9e3A3LJqtCAQL2E%3D">\n <figcaption class="px2">Football is life</figcaption> \n </figure> \n\n</div>\n</a>\n\n<div class="template asset" contenteditable="false" data-alt-text="" data-caption="" data-id="35659921"> \n <figure>\n<img alt="" class="fit js-lazy-image" data-src="https://i.kickstarter.com/assets/035/659/921/b0109638f8c7857774acd3763b77ca71_original.gif?fit=contain&amp;origin=ugc-qa&amp;q=92&amp;width=700&amp;sig=AI%2FrHQXSOmISfUh4U1ISsvDVvA8f35DSzMsypPoDhiA%3D" src="https://i.kickstarter.com/assets/035/659/921/b0109638f8c7857774acd3763b77ca71_original.gif?anim=false&amp;fit=contain&amp;origin=ugc-qa&amp;q=92&amp;width=700&amp;sig=JrepoYkiHBme%2FoYwKayBkoCDmlRXuoWzNyTosLpj4jo%3D">\n</figure> \n\n</div>\n\n<div class="template asset" contenteditable="false" data-id="35786501"> \n <figure class="page-anchor" id="asset-35786501"> \n <div class="video-player" data-video-url="https://v.kickstarter.com/1646345127_8366452d275cb8330ca0cee82a6c5259a1df288e/assets/035/786/501/b99cdfe87fc9b942dce0fe9a59a3767a_h264_high.mp4" data-image="https://dr0rfahizzuzj.cloudfront.net/assets/035/786/501/b99cdfe87fc9b942dce0fe9a59a3767a_h264_base.jpg?2021" data-dimensions='{"width":640,"height":360}' data-context="Story Description"> \n <video class="landscape" preload="none"> \n <source src="https://v.kickstarter.com/1646345127_8366452d275cb8330ca0cee82a6c5259a1df288e/assets/035/786/501/b99cdfe87fc9b942dce0fe9a59a3767a_h264_high.mp4" type='video/mp4; codecs="avc1.64001E, mp4a.40.2"'></source> \n <source src="https://v.kickstarter.com/1646345127_8366452d275cb8330ca0cee82a6c5259a1df288e/assets/035/786/501/b99cdfe87fc9b942dce0fe9a59a3767a_h264_base.mp4" type='video/mp4; codecs="avc1.42E01E, mp4a.40.2"'></source> \nYou'll need an HTML5 capable browser to see this content.\n </video> \n<img class="has_played_hide full-width poster landscape" alt=" project video thumbnail" src="https://dr0rfahizzuzj.cloudfront.net/assets/035/786/501/b99cdfe87fc9b942dce0fe9a59a3767a_h264_base.jpg?2021">\n <div class="play_button_container absolute-center has_played_hide">\n<button aria-label="Play video" class="play_button_big play_button_dark radius2px" type="button">\n<span class="ksr-icon__play" aria-hidden="true"></span>\nPlay\n</button>\n</div>\n <div class="reset-video js-reset-video-once"> \n <div class="reset-video__icon"> \n <div class="audio-indicator js-autoplay-svg"> \n<svg version="1.1" viewbox="0 0 18 17.2" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/2000/svg">\n <g> \n\n\n<polygon class="audio-indicator-bar" points="0,0 2,0 2,11.5 2,17.2 0,17.2">\n<animate attributename="points" begin="0s" calcmode="spline" dur="1.2s" keysplines="0.18 0.01 0.37 0.99;0.18 0.01 0.37 0.99;0.18 0.01 0.37 0.99" keytimes="0; 0.3; 0.9; 1" repeatcount="indefinite" values="0,0 2,0 2,11.5 2,17.2 0,17.2;0,2.6 2,2.6 2,8.2 2,17.2 0,17.2;0,12.1 2,12.1 2,14 2,17.2 0,17.2;0,0 2,0 2,11.5 2,17.2 0,17.2"></animate>\n</polygon>\n\n<polygon class="audio-indicator-bar" points="4,3.9 6,3.9 6,8.6 6,17.2 4,17.2">\n<animate attributename="points" begin="0s" calcmode="spline" dur="1.2s" keysplines="0.18 0.01 0.37 0.99;0.18 0.01 0.37 0.99;0.18 0.01 0.37 0.99" keytimes="0; 0.2; 0.6; 1" repeatcount="indefinite" values="4,3.9 6,3.9 6,8.6 6,17.2 4,17.2;4,10.6 6,10.6 6,12.9 6,17.2 4,17.2;4,6.4 6,6.4 6,10.2 6,17.2 4,17.2;4,3.9 6,3.9 6,8.6 6,17.2 4,17.2"></animate>\n</polygon>\n\n<polygon class="audio-indicator-bar" points="8,7 10,7 10,8.3 10,17.2 8,17.2">\n<animate attributename="points" begin="0s" calcmode="spline" dur="1.2s" keysplines="0.18 0.01 0.37 0.99;0.18 0.01 0.37 0.99;0.18 0.01 0.37 0.99" keytimes="0; 0.3; 0.5; 1" repeatcount="indefinite" values="8,7 10,7 10,8.3 10,17.2 8,17.2;8,13.9 10,13.9 10,14.3 10,17.2 8,17.2;8,0 10,0 10,2.3 10,17.2 8,17.2;8,7 10,7 10,8.3 10,17.2 8,17.2"></animate>\n</polygon>\n\n<polygon class="audio-indicator-bar" points="12,0 14,0 14,4.3 14,17.2 12,17.2">\n<animate attributename="points" begin="0s" calcmode="spline" dur="1.2s" keysplines="0.18 0.01 0.37 0.99;0.18 0.01 0.37 0.99;0.18 0.01 0.37 0.99" keytimes="0; 0.3; 0.9; 1" repeatcount="indefinite" values="12,0 14,0 14,4.3 14,17.2 12,17.2;12,6.1 14,6.1 14,8.9 14,17.2 12,17.2;12,10.6 14,10.6 14,12.2 14,17.2 12,17.2;12,0 14,0 14,4.3 14,17.2 12,17.2"></animate>\n</polygon>\n\n<polygon class="audio-indicator-bar" points="16,1.9 18,1.9 18,3.9 18,17.2 16,17.2">\n<animate attributename="points" begin="0s" calcmode="spline" dur="1.2s" keysplines="0.18 0.01 0.37 0.99;0.18 0.01 0.37 0.99;0.18 0.01 0.37 0.99" keytimes="0; 0.4; 0.6; 1" repeatcount="indefinite" values="16,1.9 18,1.9 18,3.9 18,17.2 16,17.2;16,8.6 18,8.6 18,9.7 18,17.2 16,17.2;16,16.6 18,16.6 18,9.7 18,17.2 16,17.2;16,1.9 18,1.9 18,3.9 18,17.2 16,17.2"></animate>\n</polygon>\n </g> \n</svg>\n </div>\n\n </div>\n <div class="reset-video__label">\nReplay with sound\n</div>\n </div>\n <div class="rewind-video js-reset-video-once"> \n <div class="rewind-video__wrapper absolute-center"> \n <div class="rewind-video__inner"> \n <div class="rewind-video__button"> \n <div class="rewind-video__button_inner"> \n <div class="rewind-video__icon"></div>\n <div class="rewind-video__label">\nPlay with <br>sound\n</div>\n </div>\n </div>\n </div>\n </div>\n </div>\n <div class="player_controls absolute-bottom mb3 radius2px white bg-green-dark forces-video-controls_hide"> \n <div class="left full-height"> \n <button class="flex btn btn--with-svg btn--dark-green left playpause play mr2 ml0 full-height keyboard-focusable"> \n <svg class="svg-icon__play" aria-hidden="true"> <use xlink:href="#play"></use> </svg> \n <svg class="svg-icon__pause" aria-hidden="true"> <use xlink:href="#pause"></use> </svg> \n </button> \n<time class="time current_time left video-time--current">00:00</time>\n </div>\n <div class="right full-height"> \n<time class="time total_time left mr2 video-time--total">00:00</time>\n<button class="m0 left button button_icon button_icon_white volume full-height keyboard-focusable">\n<span class="ss-icon ss-volume icon_volume_nudge"></span>\n<span class="ss-icon ss-highvolume"></span>\n</button>\n <div class="volume_container left"> \n <div class="progress_bar progress_bar_dark progress_bg"> \n <div class="progress_bar_bg"></div>\n <div class="progress progress_bar_progress"></div>\n <div aria-label="Volume" class="progress_handle progress_bar_handle keyboard-focusable" role="slider" tabindex="0"></div>\n </div>\n </div>\n<button aria-label="Fullscreen" class="m0 left button button_icon button_icon_white fullscreen full-height keyboard-focusable">\n<span class="ss-icon ss-expand"></span>\n<span class="ss-icon ss-delete"></span>\n</button>\n </div>\n <div class="clip"> \n <div class="progress_container pr2 pl2"> \n <div class="progress_bar progress_bar_dark progress_bg"> \n <div class="progress_bar_bg"></div>\n <div class="buffer progress_bar_buffer"></div>\n <div class="progress progress_bar_progress"></div>\n <div aria-label="Played" class="progress_handle progress_bar_handle keyboard-focusable" role="slider" tabindex="0"></div>\n </div>\n </div>\n </div>\n <div class="clear"></div>\n </div>\n </div>\n </figure> \n\n</div>\n\n\n<div class="template asset" contenteditable="false" data-alt-text="" data-caption="Always remember to..." data-id="35659922">\n<figure> \n<img alt="" class="fit js-lazy-image" data-src="https://i.kickstarter.com/assets/035/659/922/eae68383730822ffe949f3825600a80a_original.gif?fit=contain&amp;origin=ugc-qa&amp;q=92&amp;width=700&amp;sig=UmFeDV5M0K3EeJXtbUe27l6zGDmBLZJGg26eIZDmWTg%3D" src="https://i.kickstarter.com/assets/035/659/922/eae68383730822ffe949f3825600a80a_original.gif?anim=false&amp;fit=contain&amp;origin=ugc-qa&amp;q=92&amp;width=700&amp;sig=2JE6RZFAMDIn9QbDLsUadFoasYY13Zh3Wg0FVDpY3d4%3D">\n <figcaption class="px2">Always remember to...</figcaption> \n</figure>\n\n</div>\n\n\n<a href="https://www.youtube.com/watch?v=0_qRyDCh2TE" target="_blank" rel="noopener"> <div class="template asset" contenteditable="false" data-alt-text="" data-caption="... and party hard!" data-id="35659923">\n <figure> \n<img alt="" class="fit js-lazy-image" data-src="https://i.kickstarter.com/assets/035/659/923/ae8758cdcb8d0c0e75cd4c1a155772b6_original.gif?fit=contain&amp;origin=ugc-qa&amp;q=92&amp;width=700&amp;sig=Z3PlOnq4NPqB3802BLjPpShbZ7MUptxutV%2FOzLxI3JM%3D" src="https://i.kickstarter.com/assets/035/659/923/ae8758cdcb8d0c0e75cd4c1a155772b6_original.gif?anim=false&amp;fit=contain&amp;origin=ugc-qa&amp;q=92&amp;width=700&amp;sig=Hz585QBa6kk6WqF%2BEqDQHsTwqAKaI7SkNAOuf8NFf74%3D">\n <figcaption class="px2">... and party hard!</figcaption> \n </figure> \n\n</div>\n</a>\n\n <div class="template oembed" contenteditable="false" data-href="https://www.youtube.com/watch?v=3u7EIiohs6U">\n<iframe width="356" height="200" src="https://www.youtube.com/embed/3u7EIiohs6U?feature=oembed&amp;wmode=transparent" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>\n\n</div>\n\n \n\n<h1 id="h:what-about-some-musi" class="page-anchor">What about some music?</h1>\n<p>We got you!</p>\n\n <div class="template oembed" contenteditable="false" data-href="https://open.spotify.com/track/0dpyzcT3RMNNSd2xKBf35I?si=8c3a869d82464083">\n<iframe width="100%" height="80" title="Spotify Embed: Be Sweet" style="[object Object]" frameborder="0" allowfullscreen allow="autoplay; clipboard-write; encrypted-media; fullscreen; picture-in-picture" src="https://open.spotify.com/embed/track/0dpyzcT3RMNNSd2xKBf35I?si=8c3a869d82464083&amp;utm_source=oembed"></iframe>\n\n</div>\n\n \n\n <div class="template oembed" contenteditable="false" data-href="https://soundcloud.com/japanesebreakfast/savage-good-boy?utm_source=clipboard&amp;utm_medium=text&amp;utm_campaign=social_sharing">\n<iframe width="560" height="400" scrolling="no" frameborder="no" src="https://w.soundcloud.com/player/?visual=true&amp;url=https%3A%2F%2Fapi.soundcloud.com%2Ftracks%2F994103107&amp;show_artwork=true&amp;maxwidth=560"></iframe>\n\n</div>\n\n \n\n <div class="template oembed" contenteditable="false" data-href="https://michellezauner.bandcamp.com/track/paprika">\n<iframe class="embedly-embed" src="https://cdn.embedly.com/widgets/media.html?src=https%3A%2F%2Fbandcamp.com%2FEmbeddedPlayer%2Fv%3D2%2Ftrack%3D512671900%2Fsize%3Dlarge%2Flinkcol%3D0084B4%2Fnotracklist%3Dtrue%2Ftwittercard%3Dtrue%2F&amp;display_name=BandCamp&amp;url=https%3A%2F%2Fmichellezauner.bandcamp.com%2Ftrack%2Fpaprika&amp;image=https%3A%2F%2Ff4.bcbits.com%2Fimg%2Fa1594462619_5.jpg&amp;key=bb604e7974304bcc890165e12e2e0a7b&amp;type=text%2Fhtml&amp;schema=bandcamp" width="350" height="467" scrolling="no" title="BandCamp embed" frameborder="0" allow="autoplay; fullscreen" allowfullscreen="true"></iframe>\n\n</div>\n
      """

    return resultMap
  }
}
