import XCTest
@testable import Routy

final class RouterQueueTests: XCTestCase {

    private var sut: RouterQueue!

    override func setUp() {
        super.setUp()
        sut = .init()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testThatIfQueueIsEmptyThenAddedOperationExecutesImmediately() {
        var operationExecutionsCount = 0
        let operation: RouterQueueOperation = { _ in
            operationExecutionsCount += 1
        }

        sut.enqueue(operation: operation)

        XCTAssertEqual(operationExecutionsCount, 1)
    }

    func testThatIfQueueIsNotEmptyThenAddedOperationNotExecutes() {
        sut.enqueue(operation: { _ in })

        var operationExecutionsCount = 0
        let operation: RouterQueueOperation = { _ in
            operationExecutionsCount += 1
        }

        sut.enqueue(operation: operation)

        XCTAssertEqual(operationExecutionsCount, 0)
    }

    func testThatWHenPreviousOperationFinishesThenNextOperationStarts() {
        var firstOperationCompletion: (() -> Void)?
        sut.enqueue(operation: { firstOperationCompletion = $0 })

        var secondOperationExecutionsCount = 0
        let secondOperation: RouterQueueOperation = { _ in
            secondOperationExecutionsCount += 1
        }

        sut.enqueue(operation: secondOperation)
        firstOperationCompletion?()

        XCTAssertEqual(secondOperationExecutionsCount, 1)
    }

}
