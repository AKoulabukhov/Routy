@testable import Routy

final class MockNavigationTransitionProvider: NavigationTransitionProviderProtocol {
    typealias ContextType = MockNavigationContextType
    typealias Element = MockNavigationElement

    var _getNavigationStack = MockInvocation<Void, [Element]>()

    func getNavigationStack() -> [Element] {
        _getNavigationStack.calls.append(())
        return _getNavigationStack.output
    }

    var _makeTransitionForContext = MockInvocation<(
        context: NavigationContext<MockNavigationContextType>,
        stack: [MockNavigationElement]
    ), NavigationTransitionProtocol?>()

    func makeTransition(
        for context: NavigationContext<MockNavigationContextType>,
        in stack: [MockNavigationElement]
    ) -> NavigationTransitionProtocol? {
        _makeTransitionForContext.calls.append((context, stack))
        return _makeTransitionForContext.output
    }

    var _makeTransitionForElement = MockInvocation<(
        element: MockNavigationElement,
        stack: [MockNavigationElement]
    ), NavigationTransitionProtocol?>()

    func makeTransition(
        for element: MockNavigationElement,
        in stack: [MockNavigationElement]
    ) -> NavigationTransitionProtocol? {
        _makeTransitionForElement.calls.append((element, stack))
        return _makeTransitionForElement.output
    }
}
