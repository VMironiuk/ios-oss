import KsApi
import Library
import Prelude
import ReactiveSwift
import SwiftUI
import UIKit

internal final class SearchViewController: UITableViewController {
  internal let viewModel: SearchViewModelType = SearchViewModel()
  fileprivate let dataSource = SearchDataSource()

  @IBOutlet fileprivate var cancelButton: UIButton!
  @IBOutlet fileprivate var centeringStackView: UIStackView!
  @IBOutlet fileprivate var innerSearchStackView: UIStackView!
  @IBOutlet fileprivate var searchBarContainerView: UIView!
  @IBOutlet fileprivate var searchIconImageView: UIImageView!
  @IBOutlet fileprivate var searchStackView: UIStackView!
  @IBOutlet fileprivate var searchStackViewWidthConstraint: NSLayoutConstraint!
  @IBOutlet fileprivate var searchTextField: UITextField!
  @IBOutlet fileprivate var searchTextFieldHeightConstraint: NSLayoutConstraint!

  private let backgroundView = UIView()
  private let searchLoaderIndicator = UIActivityIndicatorView()
  private let showSortAndFilterHeader = MutableProperty<Bool>(false) // Bound to the view model property

  private var sortAndFilterHeader: UIViewController?

  internal static func instantiate() -> SearchViewController {
    return Storyboard.Search.instantiate(SearchViewController.self)
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.tableView.dataSource = self.dataSource

    self.tableView.register(nib: .BackerDashboardProjectCell)
    self.tableView.registerCellClass(SearchResultsCountCell.self)

    self.viewModel.inputs.viewDidLoad()

    let pillView = SelectedSearchFiltersHeaderView(
      selectedFilters: self.viewModel.outputs.searchFilters,
      didTapPill: { [weak self] pill in
        self?.viewModel.inputs.tappedButton(forFilterType: pill.filterType)
      }
    )

    let sortAndFilterHeader = UIHostingController(rootView: pillView)
    self.addChild(sortAndFilterHeader)

    self.sortAndFilterHeader = sortAndFilterHeader
  }

  internal override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    self.cancelButton.addTarget(
      self,
      action: #selector(SearchViewController.cancelButtonPressed),
      for: .touchUpInside
    )

    self.searchTextField.addTarget(
      self,
      action: #selector(SearchViewController.searchTextChanged(_:)),
      for: .editingChanged
    )

    self.searchTextField.addTarget(
      self,
      action: #selector(SearchViewController.searchTextEditingDidEnd),
      for: .editingDidEndOnExit
    )

    self.searchBarContainerView.addGestureRecognizer(
      UITapGestureRecognizer(target: self, action: #selector(SearchViewController.searchBarContainerTapped))
    )

    self.searchTextField.delegate = self

    self.viewModel.inputs.viewWillAppear(animated: animated)
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableControllerStyle(estimatedRowHeight: 86)

    _ = [self.searchLoaderIndicator]
      ||> baseActivityIndicatorStyle

    _ = self.cancelButton
      |> UIButton.lens.titleColor(for: .normal) .~ LegacyColors.ksr_support_400.uiColor()
      |> UIButton.lens.titleLabel.font .~ .ksr_callout(size: 15)
      |> UIButton.lens.title(for: .normal) %~ { _ in Strings.discovery_search_cancel() }

    _ = self.searchBarContainerView
      |> roundedStyle()
      |> UIView.lens.backgroundColor .~ LegacyColors.Background.search.uiColor()

    _ = self.searchIconImageView
      |> UIImageView.lens.tintColor .~ LegacyColors.ksr_support_400.uiColor()
      |> UIImageView.lens.image .~ image(named: "search-icon")

    _ = self.searchStackView
      |> UIStackView.lens.spacing .~ Styles.grid(1)
      |> UIStackView.lens.layoutMargins .~ .init(leftRight: Styles.grid(2))
      |> UIStackView.lens.isLayoutMarginsRelativeArrangement .~ true

    _ = self.innerSearchStackView
      |> UIStackView.lens.spacing .~ Styles.grid(1)

    _ = self.searchTextField
      |> UITextField.lens.font .~ .ksr_body(size: 14)
      |> UITextField.lens.textColor .~ LegacyColors.ksr_support_400.uiColor()

    self.searchTextField.attributedPlaceholder = NSAttributedString(
      string: Strings.tabbar_search(),
      attributes: [NSAttributedString.Key.foregroundColor: LegacyColors.ksr_support_400.uiColor()]
    )

    _ = self.tableView
      |> UITableView.lens.keyboardDismissMode .~ .onDrag

    self.searchTextFieldHeightConstraint.constant = Styles.grid(5)
    self.searchStackViewWidthConstraint.constant = self.view.frame.size.width * 0.8

    self.tableView.sectionHeaderTopPadding = 0
  }

  internal override func bindViewModel() {
    self.viewModel.outputs.searchResults
      .observeForUI()
      .observeValues { [weak self] results in
        self?.dataSource.load(results: results)
        self?.tableView.reloadData()
      }

    self.viewModel.outputs.searchLoaderIndicatorIsAnimating
      .observeForUI()
      .observeValues { [weak self] isAnimating in
        guard let _self = self else { return }
        _self.tableView.tableFooterView = isAnimating ? _self.searchLoaderIndicator : nil
        if let footerView = _self.tableView.tableFooterView {
          footerView.frame = CGRect(
            x: footerView.frame.origin.x,
            y: footerView.frame.origin.y,
            width: footerView.frame.size.width,
            height: Styles.grid(15)
          )
        }
      }

    self.viewModel.outputs.showEmptyState
      .observeForUI()
      .observeValues { [weak self] params, visible in
        self?.dataSource.load(params: params, visible: visible)
        self?.tableView.reloadData()
      }

    self.viewModel.outputs.goToProject
      .observeForControllerAction()
      .observeValues { [weak self] projectId, refTag in
        self?.goTo(projectId: projectId, refTag: refTag)
      }

    self.searchTextField.rac.text = self.viewModel.outputs.searchFieldText
    self.searchTextField.rac.isFirstResponder = self.viewModel.outputs.resignFirstResponder.mapConst(false)

    self.searchLoaderIndicator.rac.animating = self.viewModel.outputs.searchLoaderIndicatorIsAnimating

    self.viewModel.outputs.changeSearchFieldFocus
      .observeForControllerAction() // NB: don't change this until we figure out the deadlock problem.
      .observeValues { [weak self] in
        self?.changeSearchFieldFocus(focus: $0, animated: $1)
      }

    self.viewModel.outputs.showFilters
      .observeForControllerAction()
      .observeValues { [weak self] type in
        if type == .sort {
          // Sort is a special case modal, not part of the root filter view.
          self?.showSort()
          return
        }

        // All other filters go to the same modal.
        self?.showFilters(filterType: type)
      }

    self.showSortAndFilterHeader <~ self.viewModel.outputs.showSortAndFilterHeader
  }

  fileprivate func present(sheet viewController: UIViewController, withHeight _: CGFloat) {
    let presenter = BottomSheetPresenter()
    presenter.present(viewController: viewController, from: self)
  }

  fileprivate func showSort() {
    let sortViewModel = SortViewModel(
      sortOptions: self.viewModel.outputs.searchFilters.sort.sortOptions,
      selectedSortOption: self.viewModel.outputs.searchFilters.sort.selectedSort
    )

    let sortView = SortView(
      viewModel: sortViewModel,
      onSelectedSort: { [weak self] sortOption in
        self?.viewModel.inputs.selectedFilter(.sort(sortOption))
      },
      onClosed: { [weak self] in
        self?.dismiss(animated: true)
      }
    )

    let hostingController = UIHostingController(rootView: sortView)
    self.present(sheet: hostingController, withHeight: sortView.dynamicHeight())
  }

  fileprivate func showFilters(filterType: SearchFilterModalType) {
    var filterView = FilterRootView(
      filterType: filterType,
      searchFilters: self.viewModel.outputs.searchFilters
    )
    filterView.onFilter = { [weak self] filterEvent in
      self?.viewModel.inputs.selectedFilter(filterEvent)
    }
    filterView.onSearchedForLocations = { [weak self] locationQuery in
      self?.viewModel.inputs.searchedForLocations(locationQuery)
    }
    filterView.onReset = { [weak self] type in
      self?.viewModel.inputs.resetFilters(for: type)
    }
    filterView.onResults = { [weak self] in
      self?.dismiss(animated: true)
    }
    filterView.onClose = { [weak self] in
      self?.dismiss(animated: true)
    }
    let hostingController = UIHostingController(rootView: filterView)
    self.present(hostingController, animated: true)
  }

  fileprivate func goTo(projectId: Int, refTag: RefTag) {
    let projectParam = Either<Project, any ProjectPageParam>(right: Param.id(projectId))
    let vc = ProjectPageViewController.configuredWith(
      projectOrParam: projectParam,
      refInfo: RefInfo(refTag)
    )

    let nav = NavigationController(rootViewController: vc)
    nav.modalPresentationStyle = self.traitCollection.userInterfaceIdiom == .pad ? .fullScreen : .formSheet

    self.present(nav, animated: true, completion: nil)
  }

  fileprivate func changeSearchFieldFocus(focus: Bool, animated _: Bool) {
    if focus {
      self.cancelButton.isHidden = false

      self.centeringStackView.alignment = .fill

      if !self.searchTextField.isFirstResponder {
        self.searchTextField.becomeFirstResponder()
      }
    } else {
      self.cancelButton.isHidden = true

      self.centeringStackView.alignment = .center

      if self.searchTextField.isFirstResponder {
        self.searchTextField.resignFirstResponder()
      }
    }
  }

  internal override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
    if let project = self.dataSource.indexOfProject(forCellAtIndexPath: indexPath) {
      self.viewModel.inputs.tapped(projectAtIndex: project)
    }
  }

  internal override func tableView(
    _: UITableView,
    willDisplay _: UITableViewCell,
    forRowAt indexPath: IndexPath
  ) {
    self.viewModel.inputs.willDisplayRow(
      self.dataSource.itemIndexAt(indexPath),
      outOf: self.dataSource.numberOfItems()
    )
  }

  override func tableView(_: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    guard section == SearchDataSource.Section.projects.rawValue,
          self.showSortAndFilterHeader.value == true else {
      return nil
    }

    return self.sortAndFilterHeader?.view
  }

  private var headerHeight: CGFloat? = nil
  override func tableView(_: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    guard section == SearchDataSource.Section.projects.rawValue,
          self.showSortAndFilterHeader.value == true else {
      return 0
    }

    if self.headerHeight == nil,
       let fittingSize = self.sortAndFilterHeader?.view.systemLayoutSizeFitting(self.view.bounds.size) {
      self.headerHeight = fittingSize.height
    }

    return self.headerHeight ?? 0
  }

  @objc fileprivate func searchTextChanged(_ textField: UITextField) {
    self.viewModel.inputs.searchTextChanged(textField.text ?? "")
  }

  @objc fileprivate func searchTextEditingDidEnd() {
    self.viewModel.inputs.searchTextEditingDidEnd()
  }

  @objc fileprivate func cancelButtonPressed() {
    self.viewModel.inputs.cancelButtonPressed()
  }

  @objc fileprivate func searchBarContainerTapped() {
    self.viewModel.inputs.searchFieldDidBeginEditing()
  }
}

extension SearchViewController: UITextFieldDelegate {
  internal func textFieldDidBeginEditing(_: UITextField) {
    self.viewModel.inputs.searchFieldDidBeginEditing()
  }

  internal func textFieldShouldClear(_: UITextField) -> Bool {
    self.viewModel.inputs.clearSearchText()
    return true
  }
}

extension SearchViewController: TabBarControllerScrollable {}
