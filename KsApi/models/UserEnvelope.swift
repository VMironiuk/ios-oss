import Foundation
import GraphAPI
import ReactiveSwift

public struct UserEnvelope<T: Decodable>: Decodable {
  public let me: T
}

// MARK: - GraphQL Adapters

extension UserEnvelope {
  static func envelopeProducer(from data: GraphAPI.FetchUserQuery.Data)
    -> SignalProducer<UserEnvelope<GraphUser>, ErrorEnvelope> {
    guard let envelope = UserEnvelope.userEnvelope(from: data) else {
      return .empty
    }
    return SignalProducer(value: envelope)
  }

  static func envelopeProducer(from data: GraphAPI.FetchUserEmailQuery.Data)
    -> SignalProducer<UserEnvelope<GraphUserEmail>, ErrorEnvelope> {
    guard let envelope = UserEnvelope.userEnvelope(from: data) else {
      return .empty
    }
    return SignalProducer(value: envelope)
  }

  static func envelopeProducer(from data: GraphAPI.FetchUserSetupQuery.Data)
    -> SignalProducer<UserEnvelope<GraphUserSetup>, ErrorEnvelope> {
    guard let envelope = UserEnvelope.userEnvelope(from: data) else {
      return .empty
    }
    return SignalProducer(value: envelope)
  }

  static func envelopeProducer(from data: GraphAPI.FetchUserQuery.Data)
    -> SignalProducer<UserEnvelope<User>, ErrorEnvelope> {
    guard let envelope = UserEnvelope.user(from: data) else {
      return .empty
    }
    return SignalProducer(value: envelope)
  }
}
