public typealias RouterQueueOperation = (_ completion: @escaping () -> Void) -> Void

public protocol RouterQueueProtocol {
    func enqueue(operation: @escaping RouterQueueOperation)
}

public final class RouterQueue: RouterQueueProtocol {
    private var operations = [RouterQueueOperation]()

    public init() { }

    public func enqueue(operation: @escaping RouterQueueOperation) {
        let shouldStartAutomatically = operations.isEmpty
        operations.append(operation)
        if shouldStartAutomatically {
            startNextOperation()
        }
    }

    private func startNextOperation() {
        guard let operation = operations.first else { return }
        operation { [weak self] in
            guard let self = self else { return }
            self.operations.removeFirst()
            self.startNextOperation()
        }
    }
}
