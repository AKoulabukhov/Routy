import XCTest
@testable import Routy

final class RouterTests: XCTestCase {
    private typealias Router = Routy.Router<
        MockNavigationElementFactory,
        MockNavigationStackProvider,
        MockNavigationTransitionProvider
    >

    private var elementFactory: MockNavigationElementFactory!
    private var stackProvider: MockNavigationStackProvider!
    private var transitionProvider: MockNavigationTransitionProvider!
    private var queue: MockRouterQueue!
    private var sut: Router!

    override func setUp() {
        super.setUp()
        elementFactory = .init()
        elementFactory._makeElement.output = .some(nil)
        stackProvider = .init()
        stackProvider._getNavigationStack.output = []
        transitionProvider = .init()
        transitionProvider._makeReuseTransition.output = .some(nil)
        transitionProvider._makePresentTransition.output = .some(nil)
        transitionProvider._makeDismissTransition.output = .some(nil)
        queue = .init()
        sut = .init(
            elementFactory: elementFactory,
            stackProvider: stackProvider,
            transitionProvider: transitionProvider,
            queue: queue
        )
    }

    override func tearDown() {
        elementFactory = nil
        stackProvider = nil
        transitionProvider = nil
        queue = nil
        sut = nil
        super.tearDown()
    }

    func testThatWhenRouteRequestedThenOperationAddedToTheQueue() {
        sut.present(.type1, completion: nil)

        XCTAssertEqual(queue._enqueue.callsCount, 1)
    }

    func testThatWhenRouteSequenceRequestedThenSingleOperationAddedToTheQueue() {
        sut.present([.type1, .type2], completion: nil)

        XCTAssertEqual(queue._enqueue.callsCount, 1)
    }

    func testThatIfContextTransitionExistsThenItPerformedWithoutElementCreation() {
        let transition = MockNavigationTransition()
        stackProvider._getNavigationStack.output = [MockNavigationElement()]
        transitionProvider._makeReuseTransition.output = transition
        let context = MockNavigationContext(
            type: .type1,
            payload: MockNavigationContextPayload1(
                field: "field"
            )
        )

        sut.present(context, completion: nil)
        queue._enqueue.lastCall?({ })

        XCTAssertEqual(transitionProvider._makeReuseTransition.callsCount, 1)
        XCTAssertEqual(transitionProvider._makeReuseTransition.lastCall?.context, context)
        XCTAssertEqual(transitionProvider._makeReuseTransition.lastCall?.stack, stackProvider._getNavigationStack.output)
        XCTAssertEqual(transition._perform.callsCount, 1)
    }

    func testThatWhenDismissCalledThenDismissTransitionPerformed() {
        let transition = MockNavigationTransition()
        stackProvider._getNavigationStack.output = [MockNavigationElement()]
        transitionProvider._makeDismissTransition.output = transition
        let context = MockNavigationContext(
            type: .type1,
            payload: MockNavigationContextPayload1(
                field: "field"
            )
        )

        sut.dismiss(context, completion: nil)
        queue._enqueue.lastCall?({ })

        XCTAssertEqual(transitionProvider._makeDismissTransition.callsCount, 1)
        XCTAssertEqual(transitionProvider._makeDismissTransition.lastCall?.context, context)
        XCTAssertEqual(transitionProvider._makeDismissTransition.lastCall?.stack, stackProvider._getNavigationStack.output)
        XCTAssertEqual(transition._perform.callsCount, 1)
    }

    func testThatWhenTransitionCompletesThenCompletionCalled() {
        let transition = MockNavigationTransition()
        transitionProvider._makeReuseTransition.output = transition
        var completionHistory = [Bool]()

        sut.present(.type1, completion: { completionHistory.append($0) })
        queue._enqueue.lastCall?({ })
        transition._perform.lastCall??(true)

        XCTAssertEqual(completionHistory, [true])
    }

    func testThatWhenTransitionFailsThenCompletionCalled() {
        let transition = MockNavigationTransition()
        transitionProvider._makeReuseTransition.output = transition
        var completionHistory = [Bool]()

        sut.present(.type1, completion: { completionHistory.append($0) })
        queue._enqueue.lastCall?({ })
        transition._perform.lastCall??(false)

        XCTAssertEqual(completionHistory, [false])
    }

    func testThatWhenTransitionSequenceCompletesThenCompletionCalledOnce() {
        let transition1 = MockNavigationTransition()
        let transition2 = MockNavigationTransition()

        transitionProvider._makeReuseTransition.output = transition1
        var completionHistory = [Bool]()

        sut.present([.type1, .type2], completion: { completionHistory.append($0) })
        queue._enqueue.lastCall?({ }) // Start execution
        transitionProvider._makeReuseTransition.output = transition2 // Update transition in advance to first one finished

        transition1._perform.lastCall??(true)
        transition2._perform.lastCall??(true)

        XCTAssertEqual(completionHistory, [true])
    }

    func testThatWhenTransitionSequenceFailsThenNextNotRequestedAndCompletionCalledOnce() {
        let transition = MockNavigationTransition()
        transitionProvider._makeReuseTransition.output = transition
        var completionHistory = [Bool]()

        sut.present([.type1, .type2], completion: { completionHistory.append($0) })
        queue._enqueue.lastCall?({ })

        transition._perform.lastCall??(false)

        XCTAssertEqual(transitionProvider._makeReuseTransition.callsCount, 1)
        XCTAssertEqual(completionHistory, [false])
    }

    func testThatWhenFailedToCreateElementThenRouteFails() {
        var completionHistory = [Bool]()

        sut.present(.type1, completion: { completionHistory.append($0) })
        queue._enqueue.lastCall?({ })

        XCTAssertEqual(completionHistory, [false])
    }

    func testThatWhenElementCreatedThenTransitionRequested() {
        stackProvider._getNavigationStack.output = [MockNavigationElement()]
        let element = MockNavigationElement()
        element._hasContext.output = true
        elementFactory._makeElement.output = element
        let context = MockNavigationContext(
            type: .type1,
            payload: MockNavigationContextPayload1(
                field: "field"
            )
        )

        sut.present(context, completion: { _ in })
        queue._enqueue.lastCall?({ })

        XCTAssertEqual(elementFactory._makeElement.callsCount, 1)
        XCTAssertEqual(elementFactory._makeElement.lastCall, context)

        XCTAssertEqual(transitionProvider._makePresentTransition.callsCount, 1)
        XCTAssertEqual(transitionProvider._makePresentTransition.lastCall?.element, element)
        XCTAssertEqual(transitionProvider._makePresentTransition.lastCall?.stack, stackProvider._getNavigationStack.output)
    }

    func testThatWhenElementCreatedWithoutContextThenContextSet() {
        let element = MockNavigationElement()
        element._hasContext.output = false
        elementFactory._makeElement.output = element
        let context = MockNavigationContext(
            type: .type1,
            payload: MockNavigationContextPayload1(
                field: "field"
            )
        )

        sut.present(context, completion: { _ in })
        queue._enqueue.lastCall?({ })

        XCTAssertEqual(element._setContext.callsCount, 1)
        XCTAssertEqual(element._setContext.lastCall as? MockNavigationContext, context)
    }

    func testThatWhenElementCreatedWithContextThenItsNotOverriden() {
        let element = MockNavigationElement()
        element._hasContext.output = true
        elementFactory._makeElement.output = element

        sut.present(.type1, completion: { _ in })
        queue._enqueue.lastCall?({ })

        XCTAssertEqual(element._setContext.callsCount, 0)
    }

    func testThatWhenElementTransitionNotCreatedThenCompletionCalled() {
        var completionHistory = [Bool]()
        let element = MockNavigationElement()
        element._hasContext.output = false
        elementFactory._makeElement.output = element

        sut.present(.type1, completion: { completionHistory.append($0) })
        queue._enqueue.lastCall?({ })

        XCTAssertEqual(completionHistory, [false])
    }

    func testThatWhenElementTransitionCompletesThenCompletionCalled() {
        var completionHistory = [Bool]()
        let element = MockNavigationElement()
        element._hasContext.output = false
        elementFactory._makeElement.output = element
        let transition = MockNavigationTransition()
        transitionProvider._makePresentTransition.output = transition

        sut.present(.type1, completion: { completionHistory.append($0) })
        queue._enqueue.lastCall?({ })
        transition._perform.lastCall??(true)

        XCTAssertEqual(completionHistory, [true])
    }
    func testThatWhenElementTransitionFailsThenCompletionCalled() {
        var completionHistory = [Bool]()
        let element = MockNavigationElement()
        element._hasContext.output = false
        elementFactory._makeElement.output = element
        let transition = MockNavigationTransition()
        transitionProvider._makePresentTransition.output = transition

        sut.present(.type1, completion: { completionHistory.append($0) })
        queue._enqueue.lastCall?({ })
        transition._perform.lastCall??(false)

        XCTAssertEqual(completionHistory, [false])
    }
}
