import FBSDKLoginKit
import KsApi
import Prelude
import ReactiveSwift

public typealias SignInWithAppleData = (appId: String, firstName: String?, lastName: String?, token: String)

public enum AuthServicesError {
  case canceled
  case other(Error)
}

public protocol LoginToutViewModelInputs {
  /// Call when Apple completes authorization
  func appleAuthorizationDidSucceed(with data: SignInWithAppleData?)

  /// Call when Apple completes authorization with error
  func appleAuthorizationDidFail(with error: AuthServicesError)

  /// Call when Continue withApple button is pressed
  func appleLoginButtonPressed()

  /// Call to set the reason the user is attempting to log in
  func configureWith(_ intent: LoginIntent)

  /// Call when the environment has been logged into
  func environmentLoggedIn()

  /// Call when Faceboook login button is pressed
  func facebookLoginButtonPressed()

  /// Call when Facebook login completed with error
  func facebookLoginFail(error: Error?)

  /// Call when Facebook login completed successfully with a result
  func facebookLoginSuccess(result: LoginManagerLoginResult)

  /// Call with login with OAuth button is pressed
  func signupOrLoginWithOAuthButtonPressed()

  /// Call when a user session starts.
  func userSessionStarted()

  /// Call when the view appears with a boolean telling us whether or not this controller was presented,
  /// i.e. it's presentingViewController is non-`nil`.
  func view(isPresented: Bool)

  /// Call when the view controller's viewWillAppear() method is called
  func viewWillAppear()
}

public protocol LoginToutViewModelOutputs {
  /// Emits when Apple login should start
  var attemptAppleLogin: Signal<Void, Never> { get }

  /// Emits when Facebook login should start
  var attemptFacebookLogin: Signal<(), Never> { get }

  /// Emits when the controller should be dismissed.
  var dismissViewController: Signal<(), Never> { get }

  /// Emits if label should be hidden.
  var headlineLabelHidden: Signal<Bool, Never> { get }

  /// Emits whether a request is loading or not
  var isLoading: Signal<Bool, Never> { get }

  /// Emits the login context to be displayed.
  var logInContextText: Signal<String, Never> { get }

  /// Emits an access token envelope that can be used to update the environment via Apple.
  var logIntoEnvironmentWithApple: Signal<AccessTokenEnvelope, Never> { get }

  /// Emits an access token envelope that can be used to update the environment via Facebook.
  var logIntoEnvironmentWithFacebook: Signal<AccessTokenEnvelope, Never> { get }

  /// Emits when a login success notification should be posted.
  var postNotification: Signal<(Notification, Notification), Never> { get }

  /// Emits when should show Apple error alert with error message
  var showAppleErrorAlert: Signal<String, Never> { get }

  /// Emits when should show Facebook error alert with AlertError
  var showFacebookErrorAlert: Signal<AlertError, Never> { get }

  /// Emits when OAuth flow should be shown
  var startOAuthSignupOrLogin: Signal<(), Never> { get }

  /// Emits a Facebook user and access token when Facebook login has occurred
  var startFacebookConfirmation: Signal<(ErrorEnvelope.FacebookUser?, String), Never> { get }

  /// Emits an access token to show 2fa view when Facebook login fails with tfaRequired error
  var startTwoFactorChallenge: Signal<String, Never> { get }
}

public protocol LoginToutViewModelType {
  var inputs: LoginToutViewModelInputs { get }
  var outputs: LoginToutViewModelOutputs { get }
}

public final class LoginToutViewModel: LoginToutViewModelType, LoginToutViewModelInputs,
  LoginToutViewModelOutputs {
  public init() {
    let intent: Signal<LoginIntent, Never> = self.loginIntentProperty.signal.skipNil()
      .takeWhen(self.viewWillAppearProperty.signal)

    self.logInContextText = intent.map { (intent: LoginIntent) -> String in statusString(intent) }

    self.headlineLabelHidden = intent.map { (intent: LoginIntent) -> Bool in
      intent != LoginIntent.generic && intent != LoginIntent.discoveryOnboarding
    }

    let isLoading: MutableProperty<Bool> = MutableProperty(false)

    self.isLoading = isLoading.signal.skipRepeats()
    self.startOAuthSignupOrLogin = self.signupOrLoginWithOAuthButtonPressedProperty.signal
    self.attemptFacebookLogin = self.facebookLoginButtonPressedProperty.signal
    self.attemptAppleLogin = self.appleLoginButtonPressedProperty.signal.ignoreValues()

    let tokenString: Signal<String, Never> = self.facebookLoginSuccessProperty.signal.skipNil()
      .map { $0.token?.tokenString ?? "" }

    let facebookLogin = tokenString
      .switchMap { token in
        AppEnvironment.current.apiService.login(facebookAccessToken: token, code: nil)
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .on(
            starting: {
              isLoading.value = true
            },
            terminated: {
              isLoading.value = false
            }
          )
          .materialize()
      }

    let tfaRequiredError = facebookLogin.errors()
      .filter { $0.ksrCode == .TfaRequired }

    let facebookSignupError = facebookLogin.errors()
      .filter { $0.ksrCode == .ConfirmFacebookSignup }

    let genericFacebookErrorAlert = facebookLogin.errors()
      .filter { env in
        env.ksrCode != .TfaRequired &&
          env.ksrCode != .ConfirmFacebookSignup &&
          env.ksrCode != .FacebookInvalidAccessToken
      }
      .map { AlertError.genericFacebookError(envelope: $0) }

    let facebookTokenFailAlert = facebookLogin.errors()
      .filter { $0.ksrCode == .FacebookInvalidAccessToken }
      .ignoreValues()
      .mapConst(AlertError.facebookTokenFail)

    let facebookLoginAttemptFailAlert = self.facebookLoginFailProperty.signal
      .map { $0 as NSError? }
      .skipNil()
      .map(AlertError.facebookLoginAttemptFail)

    self.startTwoFactorChallenge = tokenString.takeWhen(tfaRequiredError)

    self.startFacebookConfirmation = tokenString
      .takePairWhen(facebookSignupError)
      .map { token, error in (error.facebookUser ?? nil, token) }

    self.postNotification = self.environmentLoggedInProperty.signal
      .mapConst((
        Notification(name: .ksr_sessionStarted),
        Notification(
          name: .ksr_showNotificationsDialog,
          userInfo: [UserInfoKeys.context: PushNotificationDialog.Context.login]
        )
      ))
      // Post notifications on the next run loop to avoid race condition with VCs being deallocated.
      .ksr_delay(.nanoseconds(0), on: AppEnvironment.current.scheduler)

    self.dismissViewController = self.viewIsPresentedProperty.signal
      .filter(isTrue)
      .takeWhen(self.userSessionStartedProperty.signal)
      .ignoreValues()

    self.showFacebookErrorAlert = Signal.merge(
      facebookTokenFailAlert,
      facebookLoginAttemptFailAlert,
      genericFacebookErrorAlert
    )

    let logIntoEnvironmentWithFacebook = facebookLogin.values()

    // MARK: - Sign-in with Apple

    let appleSignInInput = self.appleAuthorizationDidSucceedWithDataProperty.signal
      .skipNil()
      .map { data in
        SignInWithAppleInput(
          appId: data.appId,
          authCode: data.token,
          firstName: data.firstName,
          lastName: data.lastName
        )
      }

    let appleSignInEvent = appleSignInInput
      .switchMap { input in
        AppEnvironment.current.apiService.signInWithApple(input: input)
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .on(
            starting: {
              isLoading.value = true
            },
            failed: { _ in
              isLoading.value = false
            }
          )
          .materialize()
      }

    let userId = appleSignInEvent.values()
      .map { envelope in Int(envelope.signInWithApple.user.uid) }
      .skipNil()

    let apiAccessToken = appleSignInEvent.values()
      .map(\.signInWithApple.apiAccessToken)

    let fetchUserEvent = userId
      .switchMap { id in
        AppEnvironment.current.apiService.fetchUser(userId: id)
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .on(
            starting: {
              isLoading.value = true
            },
            terminated: {
              isLoading.value = false
            }
          )
          .materialize()
      }

    let logIntoEnvironmentWithApple = Signal.combineLatest(apiAccessToken, fetchUserEvent.values())
      .map(AccessTokenEnvelope.init)

    let appleSignInEventError = appleSignInEvent.errors()
      .map { error in error.localizedDescription }

    let appleAuthorizationError = self.appleAuthorizationDidFailWithErrorProperty.signal
      .skipNil()
      .map(errorMessage(from:))
      .skipNil()

    let fetchUserEventError = fetchUserEvent.errors()
      .map { error in error.localizedDescription }

    self.showAppleErrorAlert = Signal
      .merge(appleAuthorizationError, fetchUserEventError, appleSignInEventError)

    self.logIntoEnvironmentWithApple = logIntoEnvironmentWithApple.signal
    self.logIntoEnvironmentWithFacebook = logIntoEnvironmentWithFacebook.signal
  }

  public var inputs: LoginToutViewModelInputs { return self }
  public var outputs: LoginToutViewModelOutputs { return self }

  fileprivate let appleLoginButtonPressedProperty = MutableProperty(())
  public func appleLoginButtonPressed() {
    self.appleLoginButtonPressedProperty.value = ()
  }

  fileprivate let appleAuthorizationDidSucceedWithDataProperty = MutableProperty<SignInWithAppleData?>(nil)
  public func appleAuthorizationDidSucceed(with data: SignInWithAppleData?) {
    self.appleAuthorizationDidSucceedWithDataProperty.value = data
  }

  fileprivate let appleAuthorizationDidFailWithErrorProperty = MutableProperty<AuthServicesError?>(nil)
  public func appleAuthorizationDidFail(with error: AuthServicesError) {
    self.appleAuthorizationDidFailWithErrorProperty.value = error
  }

  fileprivate let loginIntentProperty = MutableProperty<LoginIntent?>(.loginTab)
  public func configureWith(_ intent: LoginIntent) {
    self.loginIntentProperty.value = intent
  }

  fileprivate let environmentLoggedInProperty = MutableProperty(())
  public func environmentLoggedIn() {
    self.environmentLoggedInProperty.value = ()
  }

  fileprivate let facebookLoginButtonPressedProperty = MutableProperty(())
  public func facebookLoginButtonPressed() {
    self.facebookLoginButtonPressedProperty.value = ()
  }

  fileprivate let facebookLoginFailProperty = MutableProperty<Error?>(nil)
  public func facebookLoginFail(error: Error?) {
    self.facebookLoginFailProperty.value = error
  }

  fileprivate let facebookLoginSuccessProperty = MutableProperty<LoginManagerLoginResult?>(nil)
  public func facebookLoginSuccess(result: LoginManagerLoginResult) {
    self.facebookLoginSuccessProperty.value = result
  }

  fileprivate let signupOrLoginWithOAuthButtonPressedProperty = MutableProperty(())
  public func signupOrLoginWithOAuthButtonPressed() {
    self.signupOrLoginWithOAuthButtonPressedProperty.value = ()
  }

  fileprivate let userSessionStartedProperty = MutableProperty(())
  public func userSessionStarted() {
    self.userSessionStartedProperty.value = ()
  }

  fileprivate let viewIsPresentedProperty = MutableProperty<Bool>(false)
  public func view(isPresented: Bool) {
    self.viewIsPresentedProperty.value = isPresented
  }

  fileprivate var viewWillAppearProperty = MutableProperty(())
  public func viewWillAppear() {
    self.viewWillAppearProperty.value = ()
  }

  public let attemptAppleLogin: Signal<(), Never>
  public let attemptFacebookLogin: Signal<(), Never>
  public let dismissViewController: Signal<(), Never>
  public let headlineLabelHidden: Signal<Bool, Never>
  public let isLoading: Signal<Bool, Never>
  public let logInContextText: Signal<String, Never>
  public let logIntoEnvironmentWithApple: Signal<AccessTokenEnvelope, Never>
  public let logIntoEnvironmentWithFacebook: Signal<AccessTokenEnvelope, Never>
  public let postNotification: Signal<(Notification, Notification), Never>
  public let startFacebookConfirmation: Signal<(ErrorEnvelope.FacebookUser?, String), Never>
  public let startOAuthSignupOrLogin: Signal<(), Never>
  public let startTwoFactorChallenge: Signal<String, Never>
  public let showAppleErrorAlert: Signal<String, Never>
  public let showFacebookErrorAlert: Signal<AlertError, Never>
}

private func statusString(_ forStatus: LoginIntent) -> String {
  switch forStatus {
  case .starProject:
    return Strings.Log_in_or_sign_up_to_save_this_project_and_we_ll_remind_you()
  case .backProject:
    return Strings.Please_log_in_or_sign_up_to_back_this_project()
  case .messageCreator:
    return Strings.Please_log_in_or_sign_up_to_message_this_creator()
  case .discoveryOnboarding, .onboarding, .generic, .activity, .loginTab, .erroredPledge:
    return Strings.Pledge_to_projects_and_view_all_your_saved_and_backed_projects_in_one_place()
  }
}

private func errorMessage(from error: AuthServicesError) -> String? {
  switch error {
  case let .other(error):
    return error.localizedDescription
  case .canceled:
    return nil
  }
}
