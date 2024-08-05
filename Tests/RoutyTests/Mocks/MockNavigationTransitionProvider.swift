@testable import Routy

final class MockNavigationTransitionProvider: NavigationTransitionProviderProtocol {
    typealias ContextType = MockNavigationContextType
    typealias Element = MockNavigationElement

    var _getNavigationStack = MockInvocation<Void, [Element]>()

    func getNavigationStack() -> [Element] {
        _getNavigationStack.calls.append(())
        return _getNavigationStack.output
    }

    var _makeReuseTransition = MockInvocation<(
        context: NavigationContext<MockNavigationContextType>,
        stack: [MockNavigationElement]
    ), NavigationTransitionProtocol?>()

    func makeReuseTransition(
        for context: NavigationContext<MockNavigationContextType>,
        in stack: [MockNavigationElement]
    ) -> NavigationTransitionProtocol? {
        _makeReuseTransition.calls.append((context, stack))
        return _makeReuseTransition.output
    }

    var _makePresentTransition = MockInvocation<(
        element: MockNavigationElement,
        stack: [MockNavigationElement]
    ), NavigationTransitionProtocol?>()

    func makePresentTransition(
        for element: MockNavigationElement,
        in stack: [MockNavigationElement]
    ) -> NavigationTransitionProtocol? {
        _makePresentTransition.calls.append((element, stack))
        return _makePresentTransition.output
    }

    var _makeDismissTransition = MockInvocation<(
        context: NavigationContext<MockNavigationContextType>,
        stack: [MockNavigationElement]
    ), NavigationTransitionProtocol?>()

    func makeDismissTransition(
        for context: NavigationContext<MockNavigationContextType>,
        in stack: [MockNavigationElement]
    ) -> NavigationTransitionProtocol? {
        _makeDismissTransition.calls.append((context, stack))
        return _makeDismissTransition.output
    }
}
