public typealias RouteCompletion = (Bool) -> Void
public typealias RouteOperation = (RouteCompletion?) -> Void

public extension Array where Element == RouteOperation {
    /// Performs an ordered execution of each operation in the array. If any operation fails, then executions stops and completion called with `false`
    func chained() -> RouteOperation {
        reversed().reduce(
            { operationCompletion in
                operationCompletion?(true)
            },
            { chain, operation in
                return { operationCompletion in
                    operation { isOperationSuccess in
                        if isOperationSuccess {
                            chain { isChainSuccess in
                                operationCompletion?(isChainSuccess)
                            }
                        } else {
                            operationCompletion?(false)
                        }
                    }
                }
            }
        )
    }
}
