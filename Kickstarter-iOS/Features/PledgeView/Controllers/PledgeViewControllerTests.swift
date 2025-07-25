import GraphAPI
@testable import Kickstarter_Framework
@testable import KsApi
@testable import Library
import Prelude
import SnapshotTesting
import UIKit

final class PledgeViewControllerTests: TestCase {
  private let userWithCards = GraphUser.template |> \.storedCards .~ UserCreditCards(
    storedCards: [
      UserCreditCards.visa,
      UserCreditCards.masterCard
    ]
  )

  override func setUp() {
    super.setUp()
    UIView.setAnimationsEnabled(false)
  }

  override func tearDown() {
    UIView.setAnimationsEnabled(true)

    super.tearDown()
  }

  func testView_PledgeContext_UnavailableStoredCards() {
    let response = UserEnvelope<GraphUser>(me: self.userWithCards)
    let mockService = MockService(fetchGraphUserResult: .success(response))
    let project = Project.template
      |> \.availableCardTypes .~ [CreditCardType.discover.rawValue]

    orthogonalCombos(Language.allLanguages, Device.allCases).forEach { language, device in
      withEnvironment(
        apiService: mockService,
        currentUser: User.template,
        language: language
      ) {
        let controller = PledgeViewController.instantiate()

        let reward = Reward.template
        let data = PledgeViewData(
          project: project,
          rewards: [reward],
          bonusSupport: nil,
          selectedShippingRule: .template,
          selectedQuantities: [reward.id: 1],
          selectedLocationId: nil,
          refTag: nil,
          context: .pledge
        )
        controller.configure(with: data)

        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 1_200

        self.scheduler.advance(by: .seconds(1))

        self.allowLayoutPass()

        assertSnapshot(
          matching: parent.view,
          as: .image(perceptualPrecision: 0.98),
          named: "lang_\(language)_device_\(device)"
        )
      }
    }
  }

  func testView_PledgeContext_FixPaymentMethod_ErroredCard() {
    let response = UserEnvelope<GraphUser>(me: self.userWithCards)
    let mockService = MockService(fetchGraphUserResult: .success(response))
    let project = Project.template
      |> Project.lens.state .~ .successful
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ (
        .template
          |> Backing.lens.paymentSource .~ Backing.PaymentSource.visa
          |> Backing.lens.status .~ .errored
          |> Backing.lens.reward .~ Reward.noReward
          |> Backing.lens.rewardId .~ Reward.noReward.id
          |> Backing.lens.amount .~ 695.0
          |> Backing.lens.bonusAmount .~ 695.0
          |> Backing.lens.shippingAmount .~ 0
      )

    orthogonalCombos([Language.en], [Device.phone4_7inch]).forEach { language, device in
      withEnvironment(
        apiService: mockService,
        currentUser: User.template,
        language: language
      ) {
        let controller = PledgeViewController.instantiate()
        let reward = Reward.noReward
        let data = PledgeViewData(
          project: project,
          rewards: [reward],
          bonusSupport: nil,
          selectedShippingRule: nil,
          selectedQuantities: [reward.id: 1],
          selectedLocationId: nil,
          refTag: nil,
          context: .pledge
        )
        controller.configure(with: data)
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
        parent.view.frame.size.height = 800

        self.scheduler.advance(by: .seconds(1))

        self.allowLayoutPass()

        assertSnapshot(
          matching: parent.view,
          as: .image(perceptualPrecision: 0.98),
          named: "lang_\(language)_device_\(device)"
        )
      }
    }
  }

  func testView_ShowsShippingSummaryViewSection() {
    let reward = Reward.template
      |> (Reward.lens.shipping .. Reward.Shipping.lens.enabled) .~ true

    orthogonalCombos(Language.allLanguages, [Device.phone4_7inch, Device.pad])
      .forEach { language, device in
        withEnvironment(language: language) {
          let controller = PledgeViewController.instantiate()
          let data = PledgeViewData(
            project: .template,
            rewards: [reward, .noReward],
            bonusSupport: nil,
            selectedShippingRule: .template,
            selectedQuantities: [reward.id: 1, Reward.noReward.id: 1],
            selectedLocationId: nil,
            refTag: nil,
            context: .pledge
          )
          controller.configure(with: data)
          let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

          self.scheduler.advance(by: .seconds(1))

          self.allowLayoutPass()

          assertSnapshot(
            matching: parent.view,
            as: .image(perceptualPrecision: 0.98),
            named: "lang_\(language)_device_\(device)"
          )
        }
      }
  }

  func testView_ShowsEstimatedShippingView() {
    let shippingRule = ShippingRule.template
      |> ShippingRule.lens.estimatedMin .~ Money(amount: 5.0)
      |> ShippingRule.lens.estimatedMax .~ Money(amount: 10.0)
    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shippingRulesExpanded .~ [shippingRule]
      |> Reward.lens.id .~ 99

    orthogonalCombos(Language.allLanguages, [Device.phone4_7inch, Device.pad])
      .forEach { language, device in
        withEnvironment(language: language) {
          let controller = PledgeViewController.instantiate()
          let data = PledgeViewData(
            project: .template,
            rewards: [reward],
            bonusSupport: nil,
            selectedShippingRule: shippingRule,
            selectedQuantities: [reward.id: 1],
            selectedLocationId: nil,
            refTag: nil,
            context: .pledge
          )
          controller.configure(with: data)
          let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)

          self.scheduler.advance(by: .seconds(1))

          self.allowLayoutPass()

          assertSnapshot(
            matching: parent.view,
            as: .image(perceptualPrecision: 0.98),
            named: "lang_\(language)_device_\(device)"
          )
        }
      }
  }

  func testView_HasAddOns() {
    let project = Project.template
    let shippingRule = ShippingRule.template
      |> ShippingRule.lens.estimatedMin .~ Money(amount: 5.0)
      |> ShippingRule.lens.estimatedMax .~ Money(amount: 10.0)
    let reward = Reward.template
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.shippingRules .~ [shippingRule]
      |> Reward.lens.id .~ 99
    let addOnReward1 = Reward.template
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.id .~ 1
    let addOnReward2 = Reward.template
      |> Reward.lens.shipping.enabled .~ true
      |> Reward.lens.id .~ 2

    let data = PledgeViewData(
      project: project,
      rewards: [reward, addOnReward1, addOnReward2],
      bonusSupport: nil,
      selectedShippingRule: shippingRule,
      selectedQuantities: [reward.id: 1, addOnReward1.id: 2, addOnReward2.id: 1],
      selectedLocationId: ShippingRule.template.id,
      refTag: .projectPage,
      context: .pledge
    )

    orthogonalCombos([Language.en], [Device.phone4_7inch, Device.pad])
      .forEach { language, device in
        withEnvironment(language: language) {
          let controller = PledgeViewController.instantiate()
          controller.configure(with: data)
          let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
          self.scheduler.advance(by: .seconds(1))

          self.allowLayoutPass()

          assertSnapshot(
            matching: parent.view,
            as: .image(perceptualPrecision: 0.98),
            named: "lang_\(language)_device_\(device)"
          )
        }
      }
  }

  func testView_PledgeWithNoReward() {
    let project = Project.template
    let shippingRule = ShippingRule.template
      |> ShippingRule.lens.estimatedMin .~ Money(amount: 5.0)
      |> ShippingRule.lens.estimatedMax .~ Money(amount: 10.0)
    let nonReward = Reward.noReward

    let data = PledgeViewData(
      project: project,
      rewards: [nonReward],
      bonusSupport: 1.0,
      selectedShippingRule: shippingRule,
      selectedQuantities: [nonReward.id: 1],
      selectedLocationId: ShippingRule.template.id,
      refTag: .projectPage,
      context: .pledge
    )

    let darkModeOn = MockRemoteConfigClient()
    darkModeOn.features = [
      RemoteConfigFeature.darkModeEnabled.rawValue: true,
      RemoteConfigFeature.newDesignSystem.rawValue: true
    ]

    orthogonalCombos(
      [Language.en],
      [Device.phone4_7inch, Device.pad],
      [UIUserInterfaceStyle.light, UIUserInterfaceStyle.dark]
    )
    .forEach { language, device, style in
      withEnvironment(
        colorResolver: AppColorResolver(),
        language: language,
        remoteConfigClient: darkModeOn
      ) {
        let controller = PledgeViewController.instantiate()
        controller.configure(with: data)
        controller.overrideUserInterfaceStyle = style
        let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
        self.scheduler.advance(by: .seconds(1))

        self.allowLayoutPass()

        let styleDescription = style == .light ? "light" : "dark"

        assertSnapshot(
          matching: parent.view,
          as: .image(perceptualPrecision: 0.98),
          named: "lang_\(language)_device_\(device)_\(styleDescription)"
        )
      }
    }
  }

  func testView_ShowCollectionPlans_PledgeInFull() {
    let userResponse = UserEnvelope<GraphUser>(me: self.userWithCards)
    let paymentPlanResponse: GraphAPI.BuildPaymentPlanQuery.Data =
      try! testGraphObject(jsonString: buildPaymentPlanQueryJson(eligible: true))
    let mockService = MockService(
      buildPaymentPlanResult: .success(paymentPlanResponse),
      fetchGraphUserResult: .success(userResponse)
    )

    let project = Project.template
      |> \.availableCardTypes .~ [CreditCardType.discover.rawValue]
      |> Project.lens.isPledgeOverTimeAllowed .~ true
    let reward = Reward.template

    let mockConfigClient = MockRemoteConfigClient()
    mockConfigClient.features = [
      RemoteConfigFeature.pledgeOverTime.rawValue: true
    ]

    orthogonalCombos([Language.en], [Device.phone4_7inch, Device.pad])
      .forEach { language, device in
        withEnvironment(
          apiService: mockService,
          currentUser: User.template,
          language: language,
          remoteConfigClient: mockConfigClient
        ) {
          let controller = PledgeViewController.instantiate()
          let data = PledgeViewData(
            project: project,
            rewards: [reward],
            bonusSupport: nil,
            selectedShippingRule: .template,
            selectedQuantities: [reward.id: 15], // To pass the threshold validation
            selectedLocationId: nil,
            refTag: nil,
            context: .pledge
          )
          controller.configure(with: data)
          let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
          parent.view.frame.size.height = 1_250

          self.scheduler.advance(by: .seconds(1))

          self.allowLayoutPass()

          assertSnapshot(
            matching: parent.view,
            as: .image(perceptualPrecision: 0.98),
            named: "lang_\(language)_device_\(device)"
          )
        }
      }
  }

  func testView_ShowCollectionPlans_Ineligible() {
    let userResponse = UserEnvelope<GraphUser>(me: self.userWithCards)
    let paymentPlanResponse: GraphAPI.BuildPaymentPlanQuery.Data =
      try! testGraphObject(jsonString: buildPaymentPlanQueryJson(eligible: false))
    let mockService = MockService(
      buildPaymentPlanResult: .success(paymentPlanResponse),
      fetchGraphUserResult: .success(userResponse)
    )

    let project = Project.template
      |> \.availableCardTypes .~ [CreditCardType.discover.rawValue]
      |> Project.lens.isPledgeOverTimeAllowed .~ true
    let reward = Reward.template

    let mockConfigClient = MockRemoteConfigClient()
    mockConfigClient.features = [
      RemoteConfigFeature.pledgeOverTime.rawValue: true
    ]

    orthogonalCombos([Language.en], [Device.phone4_7inch, Device.pad])
      .forEach { language, device in
        withEnvironment(
          apiService: mockService,
          currentUser: User.template,
          language: language,
          remoteConfigClient: mockConfigClient
        ) {
          let controller = PledgeViewController.instantiate()
          let data = PledgeViewData(
            project: project,
            rewards: [reward],
            bonusSupport: nil,
            selectedShippingRule: .template,
            selectedQuantities: [reward.id: 1],
            selectedLocationId: nil,
            refTag: nil,
            context: .pledge
          )
          controller.configure(with: data)
          let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
          parent.view.frame.size.height = 1_250

          self.scheduler.advance(by: .seconds(1))

          self.allowLayoutPass()

          assertSnapshot(
            matching: parent.view,
            as: .image(perceptualPrecision: 0.98),
            named: "lang_\(language)_device_\(device)"
          )
        }
      }
  }

  func testView_ShowCollectionPlans_PledgeOverTime() {
    let userResponse = UserEnvelope<GraphUser>(me: self.userWithCards)
    let paymentPlanResponse: GraphAPI.BuildPaymentPlanQuery.Data =
      try! testGraphObject(jsonString: buildPaymentPlanQueryJson(eligible: true))
    let mockService = MockService(
      buildPaymentPlanResult: .success(paymentPlanResponse),
      fetchGraphUserResult: .success(userResponse)
    )

    let project = Project.template
      |> \.availableCardTypes .~ [CreditCardType.discover.rawValue]
      |> Project.lens.isPledgeOverTimeAllowed .~ true
    let reward = Reward.template

    let mockConfigClient = MockRemoteConfigClient()
    mockConfigClient.features = [
      RemoteConfigFeature.pledgeOverTime.rawValue: true
    ]

    orthogonalCombos([Language.en], [Device.phone4_7inch, Device.pad])
      .forEach { language, device in
        withEnvironment(
          apiService: mockService,
          currentUser: User.template,
          language: language,
          remoteConfigClient: mockConfigClient
        ) {
          let controller = PledgeViewController.instantiate()
          let data = PledgeViewData(
            project: project,
            rewards: [reward],
            bonusSupport: nil,
            selectedShippingRule: .template,
            selectedQuantities: [reward.id: 15], // To pass the threshold validation
            selectedLocationId: nil,
            refTag: nil,
            context: .pledge
          )
          controller.configure(with: data)

          let (parent, _) = traitControllers(device: device, orientation: .portrait, child: controller)
          parent.view.frame.size.height = 1_550

          controller.pledgePaymentPlansViewController(
            PledgePaymentPlansViewController.instantiate(),
            didSelectPaymentPlan: .pledgeOverTime
          )

          self.scheduler.advance(by: .seconds(1))

          self.allowLayoutPass()

          assertSnapshot(
            matching: parent.view,
            as: .image(perceptualPrecision: 0.98),
            named: "lang_\(language)_device_\(device)"
          )
        }
      }
  }
}
