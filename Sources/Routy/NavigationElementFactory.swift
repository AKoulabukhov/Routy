public protocol NavigationElementFactoryProtocol {
    associatedtype ContextType: Equatable
    associatedtype Element: NavigationElementProtocol
    func makeElement(for context: NavigationContext<ContextType>) -> Element?
}
