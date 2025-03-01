@MainActor
public protocol NavigationTransitionProviderProtocol {
    associatedtype ContextType: Equatable
    associatedtype Element: NavigationElementProtocol
    /// Performed in advance to creation new element if it's possible to reuse current stack
    func makeReuseTransition(
        for context: NavigationContext<ContextType>,
        in stack: [Element]
    ) -> NavigationTransitionProtocol?
    /// New element is created and needs to be placed in stack
    func makePresentTransition(
        for element: Element,
        in stack: [Element]
    ) -> NavigationTransitionProtocol?
    /// Removes element from stack
    func makeDismissTransition(
        for context: NavigationContext<ContextType>,
        in stack: [Element]
    ) -> NavigationTransitionProtocol?
}
