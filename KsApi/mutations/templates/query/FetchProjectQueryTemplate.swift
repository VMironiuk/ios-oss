import Apollo
import Foundation
import GraphAPI
@testable import KsApi

public enum FetchProjectQueryTemplate {
  case valid

  /// `FetchProjectBySlug` returns identical data.
  var data: GraphAPI.FetchProjectByIdQuery.Data {
    switch self {
    case .valid:
      return try! testGraphObject(data: self.validResultMap)
    }
  }

  // MARK: Private Properties

  private var validResultMap: [String: Any] {
    let json = """
    {
       "me":{
          "__typename": "User",
          "chosenCurrency":"CAD"
       },
       "project":{
          "backing": {
            "__typename": "Backing",
            "id": "QmFja2luZy0xNDgwMTQwMzQ="
          },
          "__typename":"Project",
          "availableCardTypes":[
             "VISA",
             "MASTERCARD",
             "AMEX"
          ],
          "backersCount":148,
          "category":{
             "__typename":"Category",
             "id":"Q2F0ZWdvcnktMjgw",
             "name":"Photobooks",
             "analyticsName": "Photobooks",
             "parentCategory":{
                "__typename":"Category",
                "id":"Q2F0ZWdvcnktMTU=",
                "name":"Photography",
                "analyticsName":"Photography"
             }
          },
          "canComment": true,
          "commentsCount":0,
          "country":{
             "__typename":"Country",
             "code":"CA",
             "name":"Canada"
          },
          "creator":{
             "__typename":"User",
             "backings": null,
             "backingsCount": 3,
             "chosenCurrency":null,
             "email":"a@example.com",
             "hasPassword":null,
             "id":"VXNlci0xNTMyMzU3OTk3",
             "imageUrl":"image-a",
             "isAppleConnected":null,
             "isBlocked":false,
             "isCreator":true,
             "isDeliverable":null,
             "isEmailVerified":true,
             "isFacebookConnected": false,
             "isFollowing": true,
             "isKsrAdmin": true,
             "name":"A Anchor",
             "needsFreshFacebookToken": true,
             "showPublicProfile": true,
             "uid":"101",
             "location": {
               "__typename": "Location",
               "country": "US",
               "countryName": "United States",
               "displayableName": "Las Vegas, NV",
               "id": "TG9jYXRpb24tMjQzNjcwNA==",
               "name": "Las Vegas"
             },
             "newsletterSubscriptions": null,
             "isSocializing": true,
             "notifications": [],
             "createdProjects": {
               "__typename": "UserCreatedProjectsConnection",
               "totalCount": 16
             },
             "membershipProjects": {
               "__typename": "UserMembershipProjectsConnection",
               "totalCount": 10
             },
             "savedProjects": {
               "__typename": "UserSavedProjectsConnection",
               "totalCount": 11
             },
             "storedCards":{
                "__typename":"UserCreditCardTypeConnection",
                "nodes":[],
                "totalCount":0
             },
              "surveyResponses": {
                "__typename": "SurveyResponsesConnection",
                "totalCount": 2
              },
              "hasUnreadMessages": false,
              "hasUnseenActivity": true
          },
          "currency":"EUR",
          "deadlineAt":1628622000,
          "description":"A photographic book about the daily life and work on board of a Russian research vessel during the MOSAiC expedition in the Arctic.",
          "finalCollectionDate":null,
          "fxRate":1.49547966,
          "friends":{
             "__typename":"ProjectBackerFriendsConnection",
             "nodes":[]
          },
          "goal":{
             "__typename":"Money",
             "amount":"2000.0",
             "currency":"EUR",
             "symbol":"€"
          },
          "image":{
             "__typename":"Photo",
             "id":"UGhvdG8tMzM4NDYwNDQ=",
             "url":"https://i.kickstarter.com/assets/033/846/044/7134a6f4504bd636327de703a1d2dd1c_original.jpg?anim=false&fit=crop&gravity=auto&height=576&origin=ugc-qa&q=92&width=1024&sig=8iRaaTqqHeMUUXIcSvaNxHjjeHO5pbqMMizjXnBn82c%3D"
          },
          "isProjectWeLove":true,
          "isProjectOfTheDay":false,
          "isWatched":false,
          "isLaunched":true,
          "launchedAt":1625118948,
          "lastWave": {
             "__typename":"CheckoutWave",
             "id": "Q2hlY2tvdXRXYXZlLTI1OQ==",
             "active": true
          },
          "location":{
             "__typename":"Location",
             "country":"DE",
             "countryName":"Germany",
             "displayableName":"München, Germany",
             "id":"TG9jYXRpb24tNjc2NzU2",
             "name":"München"
          },
          "maxPledge": 8500,
          "minPledge": 1,
          "name":"The Quiet",
          "pledgeManager": {
             "__typename":"PledgeManager",
             "id": "UGxlZGdlTWFuYWdlci05MQ==",
             "acceptsNewBackers": true
          },
          "pid":904702116,
          "pledged":{
             "__typename":"Money",
             "amount":"7827.6",
             "currency":"EUR",
             "symbol":"€"
          },
          "isInPostCampaignPledgingPhase": false,
          "postCampaignPledgingEnabled": false,
          "posts":{
             "__typename":"PostConnection",
             "totalCount":5
          },
          "prelaunchActivated":true,
          "redemptionPageUrl": "https://www.kickstarter.com/projects/creator/a-fun-project/backing/redeem",
          "projectNotice": null,
          "slug":"theaschneider/thequiet",
          "state":"LIVE",
          "stateChangedAt":1625118950,
          "sendMetaCapiEvents" : true,
          "tags":[],
          "url":"https://staging.kickstarter.com/projects/theaschneider/thequiet",
          "usdExchangeRate":1.18302594,
          "video": {
            "__typename": "Video",
            "id": "VmlkZW8tMTExNjQ0OA==",
            "videoSources": {
              "__typename": "VideoSources",
              "high": {
                "__typename": "VideoSourceInfo",
                "src": "https://v.kickstarter.com/1631480664_a23b86f39dcfa7b0009309fa0f668ceb5e13b8a8/projects/4196183/video-1116448-h264_high.mp4"
              },
              "hls": {
                "__typename": "VideoSourceInfo",
                "src": "https://v.kickstarter.com/1631480664_a23b86f39dcfa7b0009309fa0f668ceb5e13b8a8/projects/4196183/video-1116448-hls_playlist.m3u8"
              }
            }
          },
          "watchesCount": 180,
          "isPledgeOverTimeAllowed": true,
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
          "risks": "Risks"
       }
    }
    """

    let data = Data(json.utf8)
    var resultMap = (try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]) ?? [:]

    /** NOTE: A lot of these mappings had to be customized to `GraphAPI` types from their raw data because the `ApolloClient` `fetch` and `perform` functions return `Query.Data` not raw json into their result handlers. This means that Apollo creates the models itself from the raw json returned before we can access them after the network request.
     */

    guard var projectResultMap = resultMap["project"] as? [String: Any],
          let countryResultMap = projectResultMap["country"] as? [String: Any],
          let creatorResultMap = projectResultMap["creator"] as? [String: Any] else {
      return resultMap
    }

    var updatedCountryResultMap = countryResultMap
    var updatedCreatorResultMap = creatorResultMap
    updatedCountryResultMap["code"] = "CA"
    projectResultMap["country"] = updatedCountryResultMap
    projectResultMap["deadlineAt"] = "1628622000"
    projectResultMap["launchedAt"] = "1625118948"
    projectResultMap["stateChangedAt"] = "1625118950"
    projectResultMap["availableCardTypes"] = [
      "VISA",
      "AMEX",
      "MASTERCARD"
    ]
    projectResultMap["state"] = "LIVE"
    projectResultMap["currency"] = "EUR"

    let updatedEnvironmentalCommitments =
      [[
        "__typename": "EnvironmentalCommitment",
        "commitmentCategory": "long_lasting_design",
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

    projectResultMap["faqs"] = updatedFaqs
    projectResultMap["environmentalCommitments"] = updatedEnvironmentalCommitments
    projectResultMap["creator"] = updatedCreatorResultMap
    projectResultMap["story"] = """
    <p><a href="http://record.pt/" target="_blank" rel="noopener"><strong>What about a bold link to that same newspaper website?</strong></a></p>\n<p><a href="http://recordblabla.pt/" target="_blank" rel="noopener"><em>Maybe an italic one?</em></a></p><a href="https://producthype.co/most-powerful-crowdfunding-newsletter/?utm_source=ProductHype&utm_medium=Banner&utm_campaign=Homi" target="_blank" rel="noopener"> <div class="template asset" contenteditable="false" data-alt-text="" data-caption="Viktor Pushkarev using lino-cutting to create the cover art." data-id="34488736">\n <figure>\n <img alt="" class="fit js-lazy-image" data-src="https://i.kickstarter.com/assets/034/488/736/c35446a93f1f9faedd76e9db814247bf_original.gif?fit=contain&origin=ugc-qa&q=92&width=700&sig=d1W1LoX9kZ07lXxteoCWiWFBPiGqf%2F6MfmGOppqCVzU%3D" src="https://i.kickstarter.com/assets/034/488/736/c35446a93f1f9faedd76e9db814247bf_original.gif?anim=false&fit=contain&origin=ugc-qa&q=92&width=700&sig=vYaj3kkPZlSNSFpX8qNze0bvbDszIbEqztAQ4J%2Fmo2I%3D">\n </figure>\n\n </div>\n </a>\n\n <div class="template asset" contenteditable="false" data-id="35786501"> \n <figure class="page-anchor" id="asset-35786501"> \n <div class="video-player" data-video-url="https://v.kickstarter.com/1646345127_8366452d275cb8330ca0cee82a6c5259a1df288e/assets/035/786/501/b99cdfe87fc9b942dce0fe9a59a3767a_h264_high.mp4" data-image="https://dr0rfahizzuzj.cloudfront.net/assets/035/786/501/b99cdfe87fc9b942dce0fe9a59a3767a_h264_base.jpg?2021" data-dimensions='{"width":640,"height":360}' data-context="Story Description"> \n <video class="landscape" preload="none"> \n <source src="https://v.kickstarter.com/1646345127_8366452d275cb8330ca0cee82a6c5259a1df288e/assets/035/786/501/b99cdfe87fc9b942dce0fe9a59a3767a_h264_high.mp4" type='video/mp4; codecs="avc1.64001E, mp4a.40.2"'></source> \n <source src="https://v.kickstarter.com/1646345127_8366452d275cb8330ca0cee82a6c5259a1df288e/assets/035/786/501/b99cdfe87fc9b942dce0fe9a59a3767a_h264_base.mp4" type='video/mp4; codecs="avc1.42E01E, mp4a.40.2"'></source> \nYou'll need an HTML5 capable browser to see this content.\n </video> \n<img class="has_played_hide full-width poster landscape" alt=" project video thumbnail" src="https://dr0rfahizzuzj.cloudfront.net/assets/035/786/501/b99cdfe87fc9b942dce0fe9a59a3767a_h264_base.jpg?2021">\n <div class="play_button_container absolute-center has_played_hide">\n<button aria-label="Play video" class="play_button_big play_button_dark radius2px" type="button">\n<span class="ksr-icon__play" aria-hidden="true"></span>\nPlay\n</button>\n</div>\n <div class="reset-video js-reset-video-once"> \n <div class="reset-video__icon"> \n <div class="audio-indicator js-autoplay-svg"> \n<svg version="1.1" viewbox="0 0 18 17.2" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/2000/svg">\n <g> \n\n\n<polygon class="audio-indicator-bar" points="0,0 2,0 2,11.5 2,17.2 0,17.2">\n<animate attributename="points" begin="0s" calcmode="spline" dur="1.2s" keysplines="0.18 0.01 0.37 0.99;0.18 0.01 0.37 0.99;0.18 0.01 0.37 0.99" keytimes="0; 0.3; 0.9; 1" repeatcount="indefinite" values="0,0 2,0 2,11.5 2,17.2 0,17.2;0,2.6 2,2.6 2,8.2 2,17.2 0,17.2;0,12.1 2,12.1 2,14 2,17.2 0,17.2;0,0 2,0 2,11.5 2,17.2 0,17.2"></animate>\n</polygon>\n\n<polygon class="audio-indicator-bar" points="4,3.9 6,3.9 6,8.6 6,17.2 4,17.2">\n<animate attributename="points" begin="0s" calcmode="spline" dur="1.2s" keysplines="0.18 0.01 0.37 0.99;0.18 0.01 0.37 0.99;0.18 0.01 0.37 0.99" keytimes="0; 0.2; 0.6; 1" repeatcount="indefinite" values="4,3.9 6,3.9 6,8.6 6,17.2 4,17.2;4,10.6 6,10.6 6,12.9 6,17.2 4,17.2;4,6.4 6,6.4 6,10.2 6,17.2 4,17.2;4,3.9 6,3.9 6,8.6 6,17.2 4,17.2"></animate>\n</polygon>\n\n<polygon class="audio-indicator-bar" points="8,7 10,7 10,8.3 10,17.2 8,17.2">\n<animate attributename="points" begin="0s" calcmode="spline" dur="1.2s" keysplines="0.18 0.01 0.37 0.99;0.18 0.01 0.37 0.99;0.18 0.01 0.37 0.99" keytimes="0; 0.3; 0.5; 1" repeatcount="indefinite" values="8,7 10,7 10,8.3 10,17.2 8,17.2;8,13.9 10,13.9 10,14.3 10,17.2 8,17.2;8,0 10,0 10,2.3 10,17.2 8,17.2;8,7 10,7 10,8.3 10,17.2 8,17.2"></animate>\n</polygon>\n\n<polygon class="audio-indicator-bar" points="12,0 14,0 14,4.3 14,17.2 12,17.2">\n<animate attributename="points" begin="0s" calcmode="spline" dur="1.2s" keysplines="0.18 0.01 0.37 0.99;0.18 0.01 0.37 0.99;0.18 0.01 0.37 0.99" keytimes="0; 0.3; 0.9; 1" repeatcount="indefinite" values="12,0 14,0 14,4.3 14,17.2 12,17.2;12,6.1 14,6.1 14,8.9 14,17.2 12,17.2;12,10.6 14,10.6 14,12.2 14,17.2 12,17.2;12,0 14,0 14,4.3 14,17.2 12,17.2"></animate>\n</polygon>\n\n<polygon class="audio-indicator-bar" points="16,1.9 18,1.9 18,3.9 18,17.2 16,17.2">\n<animate attributename="points" begin="0s" calcmode="spline" dur="1.2s" keysplines="0.18 0.01 0.37 0.99;0.18 0.01 0.37 0.99;0.18 0.01 0.37 0.99" keytimes="0; 0.4; 0.6; 1" repeatcount="indefinite" values="16,1.9 18,1.9 18,3.9 18,17.2 16,17.2;16,8.6 18,8.6 18,9.7 18,17.2 16,17.2;16,16.6 18,16.6 18,9.7 18,17.2 16,17.2;16,1.9 18,1.9 18,3.9 18,17.2 16,17.2"></animate>\n</polygon>\n </g> \n</svg>\n </div>\n\n </div>\n <div class="reset-video__label">\nReplay with sound\n</div>\n </div>\n <div class="rewind-video js-reset-video-once"> \n <div class="rewind-video__wrapper absolute-center"> \n <div class="rewind-video__inner"> \n <div class="rewind-video__button"> \n <div class="rewind-video__button_inner"> \n <div class="rewind-video__icon"></div>\n <div class="rewind-video__label">\nPlay with <br>sound\n</div>\n </div>\n </div>\n </div>\n </div>\n </div>\n <div class="player_controls absolute-bottom mb3 radius2px white bg-green-dark forces-video-controls_hide"> \n <div class="left full-height"> \n <button class="flex btn btn--with-svg btn--dark-green left playpause play mr2 ml0 full-height keyboard-focusable"> \n <svg class="svg-icon__play" aria-hidden="true"> <use xlink:href="#play"></use> </svg> \n <svg class="svg-icon__pause" aria-hidden="true"> <use xlink:href="#pause"></use> </svg> \n </button> \n<time class="time current_time left video-time--current">00:00</time>\n </div>\n <div class="right full-height"> \n<time class="time total_time left mr2 video-time--total">00:00</time>\n<button class="m0 left button button_icon button_icon_white volume full-height keyboard-focusable">\n<span class="ss-icon ss-volume icon_volume_nudge"></span>\n<span class="ss-icon ss-highvolume"></span>\n</button>\n <div class="volume_container left"> \n <div class="progress_bar progress_bar_dark progress_bg"> \n <div class="progress_bar_bg"></div>\n <div class="progress progress_bar_progress"></div>\n <div aria-label="Volume" class="progress_handle progress_bar_handle keyboard-focusable" role="slider" tabindex="0"></div>\n </div>\n </div>\n<button aria-label="Fullscreen" class="m0 left button button_icon button_icon_white fullscreen full-height keyboard-focusable">\n<span class="ss-icon ss-expand"></span>\n<span class="ss-icon ss-delete"></span>\n</button>\n </div>\n <div class="clip"> \n <div class="progress_container pr2 pl2"> \n <div class="progress_bar progress_bar_dark progress_bg"> \n <div class="progress_bar_bg"></div>\n <div class="buffer progress_bar_buffer"></div>\n <div class="progress progress_bar_progress"></div>\n <div aria-label="Played" class="progress_handle progress_bar_handle keyboard-focusable" role="slider" tabindex="0"></div>\n </div>\n </div>\n </div>\n <div class="clear"></div>\n </div>\n </div>\n </figure> \n\n </div>
    """

    resultMap["project"] = projectResultMap

    return resultMap
  }

  private var erroredResultMap: [String: Any?] {
    return [:]
  }
}
