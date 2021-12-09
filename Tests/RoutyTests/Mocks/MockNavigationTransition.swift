@testable import Routy

final class MockNavigationTransition: Equatable, NavigationTransitionProtocol {

    var _perform = MockInvocation<RouteCompletion?, Void>()

    func perform(completion: RouteCompletion?) {
        _perform.calls.append(completion)
    }

    static func == (lhs: MockNavigationTransition, rhs: MockNavigationTransition) -> Bool {
        lhs === rhs
    }

}
