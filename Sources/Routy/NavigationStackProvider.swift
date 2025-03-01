@MainActor
public protocol NavigationStackProviderProtocol: AnyObject {
    associatedtype Element: NavigationElementProtocol
    func getNavigationStack() -> [Element]
}
