public protocol NavigationTransitionProviderProtocol {
    associatedtype ContextType: Equatable
    associatedtype Element: NavigationElementProtocol
    /// Performed in advance to creation new element if it's possible to reuse current stack
    func makeTransition(
        for context: NavigationContext<ContextType>,
        in stack: [Element]
    ) -> NavigationTransitionProtocol?
    /// New element is created and needs to be placed in stack
    func makeTransition(
        for element: Element,
        in stack: [Element]
    ) -> NavigationTransitionProtocol?
}
