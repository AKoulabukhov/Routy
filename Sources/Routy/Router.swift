public final class Router<
    ElementFactory: NavigationElementFactoryProtocol,
    StackProvider: NavigationStackProviderProtocol,
    TransitionProvider: NavigationTransitionProviderProtocol
> where
    ElementFactory.Element == StackProvider.Element,
    ElementFactory.ContextType == TransitionProvider.ContextType,
    ElementFactory.Element == TransitionProvider.Element
{
    public typealias Element = ElementFactory.Element
    public typealias ContextType = ElementFactory.ContextType

    private let elementFactory: ElementFactory
    private let stackProvider: StackProvider
    private let transitionProvider: TransitionProvider
    private let queue: RouterQueueProtocol

    public init(
        elementFactory: ElementFactory,
        stackProvider: StackProvider,
        transitionProvider: TransitionProvider,
        queue: RouterQueueProtocol = RouterQueue()
    ) {
        self.elementFactory = elementFactory
        self.stackProvider = stackProvider
        self.transitionProvider = transitionProvider
        self.queue = queue
    }

    public func route(
        to contextType: ContextType,
        completion: RouteCompletion?
    ) {
        route(
            to: [contextType],
            completion: completion
        )
    }

    public func route(
        to contextTypes: [ContextType],
        completion: RouteCompletion?
    ) {
        route(
            to: contextTypes.map {
                NavigationContext(type: $0)
            },
            completion: completion
        )
    }

    public func route(
        to context: NavigationContext<ContextType>,
        completion: RouteCompletion?
    ) {
        route(
            to: [context],
            completion: completion
        )
    }

    public func route(
        to contexts: [NavigationContext<ContextType>],
        completion: RouteCompletion?
    ) {
        let performRoute = contexts
            .map { makeRouteOperation(to: $0) }
            .chained()
        queue.enqueue(
            operation: { queueCompletion in
                performRoute { routeResult in
                    completion?(routeResult)
                    queueCompletion()
                }
            }
        )
    }

    private func makeRouteOperation(
        to context: NavigationContext<ContextType>
    ) -> RouteOperation {
        return { [elementFactory, stackProvider, transitionProvider] completion in

            let stack = stackProvider.getNavigationStack()

            if let transition = transitionProvider.makeTransition(
                for: context,
                in: stack
            ) {
                transition.perform(completion: completion)
                return
            }

            guard let element = elementFactory.makeElement(for: context) else {
                completion?(false)
                return
            }

            if !element.hasContext {
                element.setNavigationContext(context)
            }

            guard let transition = transitionProvider.makeTransition(for: element, in: stack) else {
                completion?(false)
                return
            }

            transition.perform(completion: completion)
        }
    }

}
