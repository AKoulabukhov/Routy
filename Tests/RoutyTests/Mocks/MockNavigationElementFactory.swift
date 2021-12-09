@testable import Routy

final class MockNavigationElementFactory: NavigationElementFactoryProtocol {
    typealias ContextType = MockNavigationContextType
    typealias Element = MockNavigationElement

    var _makeElement = MockInvocation<NavigationContext<MockNavigationContextType>, MockNavigationElement?>()

    func makeElement(for context: NavigationContext<MockNavigationContextType>) -> MockNavigationElement? {
        _makeElement.calls.append(context)
        return _makeElement.output
    }
}
