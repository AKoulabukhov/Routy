@MainActor 
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

    public func perform(
        steps: [NavigationStep<ContextType>],
        completion: RouteCompletion?
    ) {
        let performSteps = steps
            .map(makeStepOperation)
            .chained()
        queue.enqueue(
            operation: { operationCompletion in
                performSteps { result in
                    completion?(result)
                    operationCompletion()
                }
            }
        )
    }

    private func makeStepOperation(
        _ step: NavigationStep<ContextType>
    ) -> RouteOperation {
        switch step.intent {
        case .present:
            return makePresentOperation(to: step.context)
        case .dismiss:
            return makeDismissOperation(of: step.context)
        }
    }

    private func makePresentOperation(
        to context: NavigationContext<ContextType>
    ) -> RouteOperation {
        return { [elementFactory, stackProvider, transitionProvider] completion in

            let stack = stackProvider.getNavigationStack()

            if let transition = transitionProvider.makeReuseTransition(
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

            guard let transition = transitionProvider.makePresentTransition(
                for: element,
                in: stack
            ) else {
                completion?(false)
                return
            }

            transition.perform(completion: completion)
        }
    }

    private func makeDismissOperation(
        of context: NavigationContext<ContextType>
    ) -> RouteOperation {
        return { [stackProvider, transitionProvider] completion in

            let stack = stackProvider.getNavigationStack()

            guard let transition = transitionProvider.makeDismissTransition(
                for: context,
                in: stack
            ) else {
                completion?(false)
                return
            }

            transition.perform(completion: completion)
        }
    }
}
