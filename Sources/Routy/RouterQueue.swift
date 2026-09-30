public typealias RouterQueueOperation = (_ completion: @escaping () -> Void) -> Void

@MainActor
public protocol RouterQueueProtocol {
    func enqueue(operation: @escaping RouterQueueOperation)
}

@MainActor
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
        var didComplete = false
        operation { [weak self] in
            guard !didComplete else { return }
            didComplete = true
            guard let self = self else { return }
            self.operations.removeFirst()
            self.startNextOperation()
        }
    }
}
