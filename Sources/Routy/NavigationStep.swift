public struct NavigationStep<ContextType: Equatable> {
    public let intent: NavigationIntent
    public let context: NavigationContext<ContextType>

    public init(
        intent: NavigationIntent,
        context: NavigationContext<ContextType>
    ) {
        self.intent = intent
        self.context = context
    }

    public static func present(
        _ context: NavigationContext<ContextType>
    ) -> Self {
        Self(
            intent: .present,
            context: context
        )
    }

    public static func present(
        _ contextType: ContextType
    ) -> Self {
        .present(NavigationContext(
            type: contextType
        ))
    }

    public static func dismiss(
        _ context: NavigationContext<ContextType>
    ) -> Self {
        Self(
            intent: .dismiss,
            context: context
        )
    }

    public static func dismiss(
        _ contextType: ContextType
    ) -> Self {
        .dismiss(NavigationContext(
            type: contextType
        ))
    }
}
