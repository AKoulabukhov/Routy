extension Router {
    public func present(
        _ contextType: ContextType,
        completion: RouteCompletion?
    ) {
        present(
            [contextType],
            completion: completion
        )
    }

    public func present(
        _ contextTypes: [ContextType],
        completion: RouteCompletion?
    ) {
        present(
            contextTypes.map {
                NavigationContext(type: $0)
            },
            completion: completion
        )
    }

    public func present(
        _ context: NavigationContext<ContextType>,
        completion: RouteCompletion?
    ) {
        present(
            [context],
            completion: completion
        )
    }

    public func present(
        _ contexts: [NavigationContext<ContextType>],
        completion: RouteCompletion?
    ) {
        perform(
            steps: contexts.map { .present($0) },
            completion: completion
        )
    }

    public func dismiss(
        _ contextType: ContextType,
        completion: RouteCompletion?
    ) {
        dismiss(
            [contextType],
            completion: completion
        )
    }

    public func dismiss(
        _ contextTypes: [ContextType],
        completion: RouteCompletion?
    ) {
        dismiss(
            contextTypes.map {
                NavigationContext(type: $0)
            },
            completion: completion
        )
    }

    public func dismiss(
        _ context: NavigationContext<ContextType>,
        completion: RouteCompletion?
    ) {
        dismiss(
            [context],
            completion: completion
        )
    }

    public func dismiss(
        _ contexts: [NavigationContext<ContextType>],
        completion: RouteCompletion?
    ) {
        perform(
            steps: contexts.map { .dismiss($0) },
            completion: completion
        )
    }
}
