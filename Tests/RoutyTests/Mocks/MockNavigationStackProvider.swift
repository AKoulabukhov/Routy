@testable import Routy

final class MockNavigationStackProvider: NavigationStackProviderProtocol {
    typealias Element = MockNavigationElement

    var _getNavigationStack = MockInvocation<Void, [Element]>()

    func getNavigationStack() -> [Element] {
        _getNavigationStack.calls.append(())
        return _getNavigationStack.output
    }
}
