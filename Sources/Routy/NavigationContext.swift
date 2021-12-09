public protocol NavigationContextPayloadProtocol {
    func isEqual(to payload: NavigationContextPayloadProtocol) -> Bool
}

extension NavigationContextPayloadProtocol where Self: Equatable {
    public func isEqual(to payload: NavigationContextPayloadProtocol) -> Bool {
        (payload as? Self) == self
    }
}

public struct NavigationContext<ContextType: Equatable>: Equatable {
    public let type: ContextType
    public let payload: NavigationContextPayloadProtocol?

    public init(
        type: ContextType,
        payload: NavigationContextPayloadProtocol? = nil
    ) {
        self.type = type
        self.payload = payload
    }

    public static func == (lhs: NavigationContext<ContextType>, rhs: NavigationContext<ContextType>) -> Bool {
        guard lhs.type == rhs.type else { return false }
        switch (lhs.payload, rhs.payload) {
        case let (lhs?, rhs?):
            return lhs.isEqual(to: rhs)
        case (_?, nil), (nil, _?):
            return false
        case (nil, nil):
            return true
        }
    }
}
