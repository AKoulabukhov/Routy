@testable import Routy

enum MockNavigationContextType: Equatable {
    case type1, type2
}

typealias MockNavigationContext = NavigationContext<MockNavigationContextType>

struct MockNavigationContextPayload1: Equatable, NavigationContextPayloadProtocol {
    let field: String
}

struct MockNavigationContextPayload2: Equatable, NavigationContextPayloadProtocol {
    let field: Int
}
