import KsApi
import Prelude
import ReactiveSwift
import UIKit

public enum RewardsCollectionViewContext {
  case createPledge
  case managePledge
}

public protocol RewardsCollectionViewModelInputs {
  func configure(
    with project: Project,
    refTag: RefTag?,
    context: RewardsCollectionViewContext,
    secretRewardToken: String?
  )
  func confirmedEditReward()
  func pledgeShippingLocationViewControllerDidUpdate(_ shimmerLoadingViewIsHidden: Bool)
  func rewardCellShouldShowDividerLine(_ show: Bool)
  func rewardSelected(with rewardId: Int)
  func shippingLocationViewDidFailToLoad()
  func shippingRuleSelected(_ shippingRule: ShippingRule?)
  func traitCollectionDidChange(_ traitCollection: UITraitCollection)
  func viewDidAppear()
  func viewDidLayoutSubviews()
  func viewDidLoad()
  func viewWillAppear()
}

public protocol RewardsCollectionViewModelOutputs {
  var configureRewardsCollectionViewFooterWithCount: Signal<Int, Never> { get }
  var configureShippingLocationViewWithData: Signal<PledgeShippingLocationViewData, Never> { get }
  var flashScrollIndicators: Signal<Void, Never> { get }
  var goToAddOnSelection: Signal<PledgeViewData, Never> { get }
  var goToCustomizeYourReward: Signal<PledgeViewData, Never> { get }
  var navigationBarShadowImageHidden: Signal<Bool, Never> { get }
  var reloadDataWithValues: Signal<[RewardCardViewData], Never> { get }
  var rewardsCollectionViewIsHidden: Signal<Bool, Never> { get }
  var rewardsCollectionViewFooterIsHidden: Signal<Bool, Never> { get }
  var scrollToRewardIndexPath: Signal<IndexPath, Never> { get }
  var shippingLocationViewHidden: Signal<Bool, Never> { get }
  var showEditRewardConfirmationPrompt: Signal<(String, String), Never> { get }
  var title: Signal<String, Never> { get }

  func selectedReward() -> Reward?
}

public protocol RewardsCollectionViewModelType {
  var inputs: RewardsCollectionViewModelInputs { get }
  var outputs: RewardsCollectionViewModelOutputs { get }
}

public final class RewardsCollectionViewModel: RewardsCollectionViewModelType,
  RewardsCollectionViewModelInputs,
  RewardsCollectionViewModelOutputs {
  public init() {
    let configData = Signal.combineLatest(
      self.configDataProperty.signal.skipNil(),
      self.viewDidLoadProperty.signal
    )
    .map(first)

    let project = configData
      .map { $0.0 }

    let secretRewardToken = configData
      .map { _, _, _, secretRewardToken in
        secretRewardToken
      }

    let rewards = project
      .map(allowableSortedProjectRewards)

    let filteredByLocationRewards = Signal.combineLatest(rewards, self.shippingRuleSelectedSignal)
      .map(filteredRewardsByLocation)

    self.title = configData
      .map { project, _, context, _ in (context, project) }
      .combineLatest(with: self.viewDidLoadProperty.signal.ignoreValues())
      .map(first)
      .map(titleForContext)

    self.scrollToRewardIndexPath = Signal.combineLatest(
      project,
      rewards,
      filteredByLocationRewards,
      secretRewardToken
    )
    .takeWhen(self.viewDidLayoutSubviewsProperty.signal.ignoreValues())
    .map { project, rewards, filteredRewardsByLocation, secretRewardToken in
      rewardToScrollIndexPath(
        project,
        rewards: filteredRewardsByLocation.isEmpty ? rewards : filteredRewardsByLocation,
        secretRewardToken: secretRewardToken
      )
    }
    .skipNil()
    .take(first: 1)

    self.reloadDataWithValues = Signal.combineLatest(
      project,
      rewards,
      filteredByLocationRewards,
      self.shippingRuleSelectedSignal.signal
    )
    .map { project, rewards, filteredByLocationRewards, shippingRule in
      if !filteredByLocationRewards.isEmpty {
        filteredByLocationRewards
          .filter { reward in isStartDateBeforeToday(for: reward) }
          .map { reward in (project, reward, .pledge, shippingRule) }
      } else {
        rewards
          .filter { reward in isStartDateBeforeToday(for: reward) }
          .map { reward in (project, reward, .pledge, nil) }
      }
    }

    self.configureRewardsCollectionViewFooterWithCount = self.reloadDataWithValues
      .map { $0.count }

    self.flashScrollIndicators = self.viewDidAppearProperty.signal

    // MARK: Shipping Location

    let hasShippableRewards = project.map(projectHasShippableRewards)

    self.shippingLocationViewHidden = hasShippableRewards.map(negate)

    // Only shown for regular non-add-ons based rewards
    self.configureShippingLocationViewWithData = Signal.combineLatest(
      project,
      hasShippableRewards.filter(isTrue)
    )
    .map { project, _ in
      // TODO: Reward will be removed from  ShippingLocationViewData once we remove the selector from Add-Ons
      (project, project.rewards[0], false, nil)
    }

    let selectedRewardFromId = rewards
      .takePairWhen(self.rewardSelectedWithRewardIdProperty.signal.skipNil())
      .map { rewards, rewardId in
        rewards.first(where: { $0.id == rewardId })
      }
      .skipNil()

    self.selectedRewardProperty <~ selectedRewardFromId

    let refTag = configData
      .map { $0.1 }

    let goToPledge: Signal<(PledgeViewData, Bool), Never> = Signal.combineLatest(
      project,
      selectedRewardFromId,
      refTag,
      self.shippingRuleSelectedSignal.signal
    )
    .takeWhen(self.rewardSelectedWithRewardIdProperty.signal)
    .filter { project, reward, _, _ in
      rewardsCarouselCanNavigateToReward(reward, in: project)
    }
    .map { project, reward, refTag, selectedShippingRule -> (PledgeViewData, Bool) in
      let pledgeContext =
        featurePostCampaignPledgeEnabled() && project.isInPostCampaignPledgingPhase
          ? PledgeViewContext.latePledge
          : PledgeViewContext.pledge

      /// Differentiating between updating a reward for a regular pledge and updating a Pledge Over Time pledge.
      let isPledgeOverTime = project.isPledgeOverTimeAllowed == true
      let updatePledgeContext = isPledgeOverTime && featureEditPledgeOverTimeEnabled()
        ? PledgeViewContext.editPledgeOverTime
        : PledgeViewContext.updateReward

      let data = PledgeViewData(
        project: project,
        rewards: [reward],
        bonusSupport: nil,
        selectedShippingRule: selectedShippingRule,
        selectedQuantities: [reward.id: 1],
        selectedLocationId: nil, // Set during add-ons selection.
        refTag: refTag,
        context: project.personalization.backing == nil ? pledgeContext : updatePledgeContext
      )

      return (data, reward.hasAddOns)
    }

    // Reward has add-ons, project is not backed, navigates to add-on selection without prompt.
    let goToAddOnSelectionNotBackedWithAddOns = goToPledge
      .filter(second >>> isTrue)
      .map(first)
      .filter(shouldTriggerEditRewardPrompt >>> isFalse)

    // Reward has add-ons, project is backed with add-ons, triggers prompt before add-on selection.
    let goToAddOnSelectionBackedWithAddOns = goToPledge
      .filter(second >>> isTrue)
      .map(first)
      .filter(shouldTriggerEditRewardPrompt >>> isTrue)

    // Reward does not have add-ons, project is not backed, navigates to pledge without prompt.
    let goToPledgeNotBackedWithAddOns = goToPledge
      .filter(second >>> isFalse)
      .map(first)
      .filter(shouldTriggerEditRewardPrompt >>> isFalse)

    // Reward does not have add-ons, project is backed with add-ons, triggers prompt before pledge.
    let goToPledgeBackedWithAddOns = goToPledge
      .filter(second >>> isFalse)
      .map(first)
      .filter(shouldTriggerEditRewardPrompt >>> isTrue)

    self.showEditRewardConfirmationPrompt = Signal.merge(
      goToAddOnSelectionBackedWithAddOns,
      goToPledgeBackedWithAddOns
    )
    .map { _ in
      (Strings.Continue_with_this_reward(), Strings.It_may_not_offer_some_or_all_of_your_add_ons())
    }

    let goToAddOnSelectionBackedConfirmed = goToPledge
      .takeWhen(self.confirmedEditRewardProperty.signal)
      .filter(second >>> isTrue)
      .map(first)

    let goToPledgeBackedConfirmed = goToPledge
      .takeWhen(self.confirmedEditRewardProperty.signal)
      .filter(second >>> isFalse)
      .map(first)

    self.goToAddOnSelection = Signal.merge(
      goToAddOnSelectionNotBackedWithAddOns,
      goToAddOnSelectionBackedConfirmed
    )

    self.goToCustomizeYourReward = Signal.merge(
      goToPledgeNotBackedWithAddOns,
      goToPledgeBackedConfirmed
    )

    /// Temporary loading state solution. Proper designs will be explored in this ticket [mbl-1678](https://kickstarter.atlassian.net/browse/MBL-1678)
    let locationShimmerHidden = self.pledgeShippingLocationViewControllerDidUpdateProperty.signal
      .map { $0 }

    // Rewards collection view should only be hidden while the location shimmer is showing.
    // If the project doesn't have shippable rewards, show immediately.
    self.rewardsCollectionViewIsHidden = Signal.merge(
      locationShimmerHidden.negate(),
      hasShippableRewards.filter(isFalse).mapConst(false)
    )

    self.rewardsCollectionViewFooterIsHidden = self.traitCollectionChangedProperty.signal
      .skipNil()
      .map { isFalse($0.verticalSizeClass == .regular) }

    let hideDividerLine = self.rewardCellShouldShowDividerLineProperty.signal
      .negate()

    self.navigationBarShadowImageHidden = Signal.merge(
      hideDividerLine,
      hideDividerLine.takeWhen(self.viewWillAppearProperty.signal)
    )

    // Tracking
    Signal.combineLatest(
      project,
      refTag,
      self.viewDidLoadProperty.signal.ignoreValues()
    )
    .observeValues { project, refTag, _ in
      // This event is fired before a base reward is selected
      let reward = Reward.noReward
      let (backing, shippingTotal) = backingAndShippingTotal(for: project, and: reward)
      let checkoutPropertiesData = checkoutProperties(
        from: project,
        baseReward: reward,
        addOnRewards: backing?.addOns ?? [],
        selectedQuantities: [:],
        additionalPledgeAmount: backing?.bonusAmount ?? 0,
        pledgeTotal: backing?.amount ?? reward.minimum,
        shippingTotal: shippingTotal ?? 0,
        isApplePay: nil
      )

      AppEnvironment.current.ksrAnalytics.trackRewardsViewed(
        project: project,
        checkoutPropertiesData: checkoutPropertiesData,
        refTag: refTag
      )
    }

    Signal.combineLatest(project, selectedRewardFromId, refTag)
      .observeValues { project, reward, refTag in

        // The `Backing` is nil for a new pledge.
        let (backing, shippingTotal) = backingAndShippingTotal(for: project, and: reward)

        // Regardless of whether this is the beginning of a new pledge or we are editing our reward,
        // we only have the base reward selected at this point
        let checkoutPropertiesData = checkoutProperties(
          from: project,
          baseReward: reward,
          addOnRewards: backing?.addOns ?? [],
          selectedQuantities: [reward.id: 1],
          additionalPledgeAmount: backing?.bonusAmount ?? 0,
          pledgeTotal: backing?.amount ?? reward.minimum, // The total is the value of the reward
          shippingTotal: shippingTotal ?? 0,
          isApplePay: nil
        )

        AppEnvironment.current.ksrAnalytics.trackRewardClicked(
          project: project,
          reward: reward,
          checkoutPropertiesData: checkoutPropertiesData,
          refTag: refTag
        )
      }

    // Facebook CAPI + Google Analytics
    _ = Signal.combineLatest(project, self.viewDidAppearProperty.signal.ignoreValues())
      .observeValues { projectAndRefTag in
        let (project, _) = projectAndRefTag

        AppEnvironment.current.appTrackingTransparency.updateAdvertisingIdentifier()

        guard let externalId = AppEnvironment.current.appTrackingTransparency.advertisingIdentifier
        else { return }

        var userId = ""

        if let userValue = AppEnvironment.current.currentUser {
          userId = "\(userValue.id)"
        }

        let projectId = "\(project.id)"

        var extInfo = Array(repeating: "", count: 16)
        extInfo[0] = "i2"
        extInfo[4] = AppEnvironment.current.mainBundle.platformVersion

        _ = AppEnvironment
          .current
          .apiService
          .triggerThirdPartyEventInput(
            input: .init(
              deviceId: externalId,
              eventName: ThirdPartyEventInputName.RewardSelectionViewed.rawValue,
              projectId: projectId,
              pledgeAmount: nil,
              shipping: nil,
              transactionId: nil,
              userId: userId,
              appData: .init(
                advertiserTrackingEnabled: true,
                applicationTrackingEnabled: true,
                extinfo: extInfo
              ),
              clientMutationId: ""
            )
          )
      }
  }

  private let configDataProperty = MutableProperty<(
    Project,
    RefTag?,
    RewardsCollectionViewContext,
    String?
  )?>(nil)
  public func configure(
    with project: Project,
    refTag: RefTag?,
    context: RewardsCollectionViewContext,
    secretRewardToken: String?
  ) {
    self.configDataProperty.value = (project, refTag, context, secretRewardToken)
  }

  private let confirmedEditRewardProperty = MutableProperty(())
  public func confirmedEditReward() {
    self.confirmedEditRewardProperty.value = ()
  }

  private let pledgeShippingLocationViewControllerDidUpdateProperty = MutableProperty<Bool>(false)
  public func pledgeShippingLocationViewControllerDidUpdate(_ shimmerLoadingViewIsHidden: Bool) {
    self.pledgeShippingLocationViewControllerDidUpdateProperty.value = shimmerLoadingViewIsHidden
  }

  private let rewardCellShouldShowDividerLineProperty = MutableProperty<Bool>(false)
  public func rewardCellShouldShowDividerLine(_ show: Bool) {
    self.rewardCellShouldShowDividerLineProperty.value = show
  }

  private let rewardSelectedWithRewardIdProperty = MutableProperty<Int?>(nil)
  public func rewardSelected(with rewardId: Int) {
    self.rewardSelectedWithRewardIdProperty.value = rewardId
  }

  private let shippingLocationViewDidFailToLoadProperty = MutableProperty(())
  public func shippingLocationViewDidFailToLoad() {
    self.shippingLocationViewDidFailToLoadProperty.value = ()
  }

  private let (shippingRuleSelectedSignal, shippingRuleSelectedObserver) = Signal<ShippingRule?, Never>.pipe()
  public func shippingRuleSelected(_ shippingRule: ShippingRule?) {
    self.shippingRuleSelectedObserver.send(value: shippingRule)
  }

  private let traitCollectionChangedProperty = MutableProperty<UITraitCollection?>(nil)
  public func traitCollectionDidChange(_ traitCollection: UITraitCollection) {
    self.traitCollectionChangedProperty.value = traitCollection
  }

  private let viewDidAppearProperty = MutableProperty(())
  public func viewDidAppear() {
    self.viewDidAppearProperty.value = ()
  }

  private let viewDidLayoutSubviewsProperty = MutableProperty(())
  public func viewDidLayoutSubviews() {
    self.viewDidLayoutSubviewsProperty.value = ()
  }

  private let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  private let viewWillAppearProperty = MutableProperty(())
  public func viewWillAppear() {
    self.viewWillAppearProperty.value = ()
  }

  public let configureShippingLocationViewWithData: Signal<PledgeShippingLocationViewData, Never>
  public let configureRewardsCollectionViewFooterWithCount: Signal<Int, Never>
  public let flashScrollIndicators: Signal<Void, Never>
  public let goToAddOnSelection: Signal<PledgeViewData, Never>
  public let goToCustomizeYourReward: Signal<PledgeViewData, Never>
  public let navigationBarShadowImageHidden: Signal<Bool, Never>
  public let reloadDataWithValues: Signal<[RewardCardViewData], Never>
  public let rewardsCollectionViewIsHidden: Signal<Bool, Never>
  public let rewardsCollectionViewFooterIsHidden: Signal<Bool, Never>
  public let scrollToRewardIndexPath: Signal<IndexPath, Never>
  public var shippingLocationViewHidden: Signal<Bool, Never>
  public let showEditRewardConfirmationPrompt: Signal<(String, String), Never>
  public let title: Signal<String, Never>

  private let selectedRewardProperty = MutableProperty<Reward?>(nil)
  public func selectedReward() -> Reward? {
    return self.selectedRewardProperty.value
  }

  public var inputs: RewardsCollectionViewModelInputs { return self }
  public var outputs: RewardsCollectionViewModelOutputs { return self }
}

// MARK: - Functions

private func projectHasShippableRewards(_ project: Project) -> Bool {
  project.rewards
    .contains(where: { $0.isUnRestrictedShippingPreference || $0.isRestrictedShippingPreference })
}

private func titleForContext(_ context: RewardsCollectionViewContext, project: Project) -> String {
  if currentUserIsCreator(of: project) {
    return Strings.View_your_rewards()
  }

  guard project.state == .live else {
    return Strings.View_rewards()
  }

  return context == .createPledge ? Strings.Back_this_project() : Strings.Edit_reward()
}

private func shouldTriggerEditRewardPrompt(_ data: PledgeViewData) -> Bool {
  // If the user is not backing the project then there is no need to show the prompt.
  guard
    userIsBackingProject(data.project),
    let backing = data.project.personalization.backing
  else { return false }

  let rewardChanged = data.rewards.first?.id != backing.reward?.id

  // We show the prompt if they have previously backed with add-ons and they are selecting a new reward.
  return backing.addOns?.isEmpty == false && rewardChanged
}

/// Returns the `IndexPath` of the reward to auto-scroll to in the collection view.
/// If a `secretRewardToken` is provided, it returns the first secret reward's index.
/// Otherwise, it returns the index of the backed reward (if the project is backed).
private func rewardToScrollIndexPath(
  _ project: Project,
  rewards: [Reward],
  secretRewardToken: String?
) -> IndexPath? {
  if let secretRewardToken = secretRewardToken, !secretRewardToken.isEmpty {
    return firstSecretRewardIndexPath(rewards: rewards)
  }

  return backedRewardIndexPath(project, rewards: rewards)
}

private func firstSecretRewardIndexPath(rewards: [Reward]) -> IndexPath? {
  return rewards.firstIndex(where: { $0.isSecretReward })
    .flatMap { IndexPath(row: $0, section: 0) }
}

private func backedRewardIndexPath(_ project: Project, rewards: [Reward]) -> IndexPath? {
  guard let backing = project.personalization.backing else {
    return nil
  }

  let backedReward = reward(from: backing, inProject: project)
  return rewards
    .firstIndex(where: { $0.id == backedReward.id })
    .flatMap { IndexPath(row: $0, section: 0) }
}

private func backingAndShippingTotal(for project: Project, and reward: Reward) -> (Backing?, Double?) {
  let backing = project.personalization.backing
  let shippingTotal = reward.shipping.enabled ? backing?.shippingAmount.flatMap(Double.init) : 0.0

  return (backing, shippingTotal)
}

private func allowableSortedProjectRewards(from project: Project) -> [Reward] {
  var notReward: [Reward] = []
  var unavailableRewards: [Reward] = []
  var secretRewards: [Reward] = []
  var availableRewards: [Reward] = []

  for reward in project.rewards {
    if reward.isNoReward {
      notReward.append(reward)
      continue
    }

    if reward.isAvailable != true {
      unavailableRewards.append(reward)
      continue
    }

    if reward.isSecretReward {
      secretRewards.append(reward)
      continue
    }

    availableRewards.append(reward)
  }

  return notReward + secretRewards + availableRewards + unavailableRewards
}

private func filteredRewardsByLocation(
  _ rewards: [Reward],
  shippingRule: ShippingRule?
) -> [Reward] {
  return rewards.filter { reward in
    var shouldDisplayReward = false

    let isRewardLocalOrDigital = isRewardDigital(reward) || isRewardLocalPickup(reward)
    let isUnrestrictedShippingReward = reward.isUnRestrictedShippingPreference
    let isRestrictedShippingReward = reward.isRestrictedShippingPreference

    // Return all rewards that are no reward, digital, local pickup, or ship anywhere in the world.
    if rewards.first?.id == reward.id || isRewardLocalOrDigital || isUnrestrictedShippingReward {
      shouldDisplayReward = true

      // If restricted shipping, compare against selected shipping location.
    } else if isRestrictedShippingReward {
      shouldDisplayReward = rewardShipsTo(selectedLocation: shippingRule?.location.id, reward)
    }

    return shouldDisplayReward
  }
}

/// Returns true if a given selection location matches the countries the given reward is available to ship to.
private func rewardShipsTo(
  selectedLocation locationId: Int?,
  _ reward: Reward
) -> Bool {
  guard let selectedLocationId = locationId else { return false }

  var shippingLocationIds: [Int] = []

  reward.shippingRulesExpanded?.forEach { rule in
    shippingLocationIds.append(rule.location.id)
  }

  return shippingLocationIds.contains(selectedLocationId)
}
