@testable import Routy

final class MockRouterQueue: RouterQueueProtocol {

    var _enqueue = MockInvocation<RouterQueueOperation, Void>()

    func enqueue(operation: @escaping RouterQueueOperation) {
        _enqueue.calls.append(operation)
    }

}
