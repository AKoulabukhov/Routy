import ObjectiveC

@MainActor public protocol NavigationElementProtocol {
    func setNavigationContext<ContextType: Equatable>(_ context: NavigationContext<ContextType>?)
    func getNavigationContext<ContextType: Equatable>(withContextType contextType: ContextType.Type) -> NavigationContext<ContextType>?
    var hasContext: Bool { get }
}

/*
 Basic implementation for iOS / MacOS
 */

@MainActor private var associatedContextHolder = 0

extension NavigationElementProtocol where Self: NSObject {

    public var hasContext: Bool {
        untypedContext != nil
    }

    public func setNavigationContext<ContextType: Equatable>(_ context: NavigationContext<ContextType>?) {
        objc_setAssociatedObject(
            self,
            &associatedContextHolder,
            context.map { NavigationContextClass($0) },
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
    }

    public func getNavigationContext<ContextType: Equatable>(withContextType contextType: ContextType.Type) -> NavigationContext<ContextType>? {
        (untypedContext as? NavigationContextClass)?.navigationContext
    }

    @MainActor private var untypedContext: Any? {
        objc_getAssociatedObject(
            self,
            &associatedContextHolder
        )
    }
}

/*
 Class wrapper for value types
 */

private final class NavigationContextClass<ContextType: Equatable> {
    let navigationContext: NavigationContext<ContextType>
    init(_ navigationContext: NavigationContext<ContextType>) {
        self.navigationContext = navigationContext
    }
}
