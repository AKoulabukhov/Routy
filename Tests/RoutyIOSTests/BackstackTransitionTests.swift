#if canImport(UIKit)

import XCTest
@testable import RoutyIOS

final class BackstackTransitionTests: XCTestCase {
    typealias BackstackTransition = RoutyIOS.BackstackTransition<MockNavigationContextType>

    func testThatWhenStackSearcherDidntFindPathThenTransitionIsNotCreated() {
        XCTAssertNil(makeSut())
    }

    func testThatStackPassedToStackSearcher() {
        let stack = [UIViewController()]
        let stackSearcher = MockViewControllerStackSearcher()
        _ = makeSut(
            stack: stack,
            stackSearcher: stackSearcher
        )

        XCTAssertEqual(stack, stackSearcher._findPathForViewController.lastCall?.stack)
    }

    func testThatStackSearchersPredicateSkipsWrongContext() throws {
        let context = MockNavigationContext(type: .type2)
        let stackSearcher = MockViewControllerStackSearcher()
        _ = makeSut(
            context: context,
            stackSearcher: stackSearcher
        )
        let viewController = MockViewController()
        viewController.setNavigationContext(MockNavigationContext(type: .type1))

        let predicate = try XCTUnwrap(stackSearcher._findPathForViewController.lastCall?.predicate)
        XCTAssertFalse(predicate(viewController))
    }

    func testThatStackSearchersPredicateAcceptsEqualContext() throws {
        let context = MockNavigationContext(
            type: .type1,
            payload: MockNavigationContextPayload1(
                field: "field"
            )
        )
        let stackSearcher = MockViewControllerStackSearcher()
        _ = makeSut(
            context: context,
            stackSearcher: stackSearcher
        )
        let viewController = MockViewController()
        viewController.setNavigationContext(
            MockNavigationContext(
                type: .type1,
                payload: MockNavigationContextPayload1(
                    field: "field"
                )
            )
        )

        let predicate = try XCTUnwrap(stackSearcher._findPathForViewController.lastCall?.predicate)
        XCTAssertTrue(predicate(viewController))
    }

    func testThatStackSearchersPredicateAcceptsSameTypeContextIfPayloadMaybeUpdated() throws {
        let context = MockNavigationContext(
            type: .type1,
            payload: MockNavigationContextPayload1(
                field: "field"
            )
        )
        let stackSearcher = MockViewControllerStackSearcher()
        _ = makeSut(
            context: context,
            stackSearcher: stackSearcher
        )
        let viewController = MockPayloadUpdateableViewController()
        viewController._canUpdate.output = true
        viewController.setNavigationContext(
            MockNavigationContext(
                type: .type1,
                payload: MockNavigationContextPayload2(
                    field: 0
                )
            )
        )

        let predicate = try XCTUnwrap(stackSearcher._findPathForViewController.lastCall?.predicate)
        XCTAssertTrue(predicate(viewController))
    }

    func testThatIfHierarchyIsAlreadyInCorrectStateThenNoActionsPerformed() {
        let context = MockNavigationContext(
            type: .type1,
            payload: MockNavigationContextPayload1(
                field: "field"
            )
        )
        let stackSearcher = MockViewControllerStackSearcher()
        stackSearcher._findPathForViewController.output = [0]
        let viewController = MockContainerViewController()
        viewController.setNavigationContext(context)
        let sut = makeSut(
            stack: [viewController],
            context: context,
            stackSearcher: stackSearcher
        )
        var completions = [Bool]()

        sut?.perform(completion: { completions.append($0) })

        XCTAssertEqual(completions, [true])
    }

    func testThatViewControllerDismissesToBeShownAndCompletesTransition() throws {
        let context = MockNavigationContext(type: .type1)
        let stackSearcher = MockViewControllerStackSearcher()
        stackSearcher._findPathForViewController.output = [0]

        let presentedViewController = UIViewController()

        let viewController = MockViewController()
        viewController.setNavigationContext(context)
        viewController._presentedViewController.output = presentedViewController

        let animated = false
        let sut = makeSut(
            stack: [viewController, presentedViewController],
            context: context,
            animated: animated,
            stackSearcher: stackSearcher
        )
        var completions = [Bool]()

        sut?.perform(completion: { completions.append($0) })

        let completion = try XCTUnwrap(viewController._dismiss.lastCall?.completion)
        completion()

        XCTAssertEqual(viewController._dismiss.lastCall?.animated, animated)
        XCTAssertEqual(completions, [true])
    }

    func testThatContainerViewControllerSwitchedToRequiredChildAndCompletesTransition() throws {
        let context = MockNavigationContext(type: .type1)
        let stackSearcher = MockViewControllerStackSearcher()
        stackSearcher._findPathForViewController.output = [0, 1]

        let childViewController1 = UIViewController()
        let childViewController2 = UIViewController()
        childViewController2.setNavigationContext(context)

        let viewController = MockContainerViewController(nestedControllers: [
            childViewController1,
            childViewController2,
        ])

        let animated = false
        let sut = makeSut(
            stack: [viewController],
            context: context,
            animated: animated,
            stackSearcher: stackSearcher
        )
        var completions = [Bool]()

        sut?.perform(completion: { completions.append($0) })

        let completion = try XCTUnwrap(viewController._switch.lastCall?.completion)
        completion(true)

        XCTAssertEqual(viewController._switch.lastCall?.viewController, childViewController2)
        XCTAssertEqual(viewController._switch.lastCall?.animated, animated)
        XCTAssertEqual(completions, [true])
    }

    func testThatUpdateableControllerUpdatesAndCompletesTransition() throws {
        let context = MockNavigationContext(type: .type1)
        let stackSearcher = MockViewControllerStackSearcher()
        stackSearcher._findPathForViewController.output = [0]

        let viewController = MockPayloadUpdateableViewController()
        viewController.setNavigationContext(context)

        let expectedPayload = MockNavigationContextPayload1(
            field: "field"
        )

        let sut = makeSut(
            stack: [viewController],
            context: MockNavigationContext(
                type: .type1,
                payload: expectedPayload
            ),
            stackSearcher: stackSearcher
        )
        var completions = [Bool]()

        sut?.perform(completion: { completions.append($0) })

        let actualPayload = try XCTUnwrap(XCTUnwrap(viewController._update.lastCall))

        XCTAssertTrue(expectedPayload.isEqual(to: actualPayload))
        XCTAssertEqual(completions, [true])
    }

    func testThatInNestedHierarchyDismissSwitchAndUpdatePayloadPerformedInCorrectOrder() throws {
        let context = MockNavigationContext(type: .type1)
        let stackSearcher = MockViewControllerStackSearcher()
        stackSearcher._findPathForViewController.output = [1, 1]

        let payloadUpdateableViewController = MockPayloadUpdateableViewController()
        payloadUpdateableViewController.setNavigationContext(context)

        let topViewController = UIViewController()

        let containerViewController = MockContainerViewController(nestedControllers: [
            UIViewController(),
            payloadUpdateableViewController,
        ])
        containerViewController._presentedViewController.output = topViewController

        let stack: [UIViewController] = [
            UIViewController(),
            containerViewController,
            topViewController,
        ]

        let expectedPayload = MockNavigationContextPayload1(
            field: "field"
        )

        let sut = makeSut(
            stack: stack,
            context: MockNavigationContext(
                type: .type1,
                payload: expectedPayload
            ),
            stackSearcher: stackSearcher
        )
        var completions = [Bool]()

        sut?.perform(completion: { completions.append($0) })

        let dismissCompletion = try XCTUnwrap(containerViewController._dismiss.lastCall?.completion)
        XCTAssertNil(containerViewController._switch.lastCall)
        dismissCompletion()

        let switchCompletion = try XCTUnwrap(containerViewController._switch.lastCall?.completion)
        XCTAssertFalse(payloadUpdateableViewController._update.hasCalls)
        switchCompletion(true)

        XCTAssertTrue(payloadUpdateableViewController._update.hasCalls)
        XCTAssertEqual(completions, [true])
    }

    private func makeSut(
        stack: [UIViewController] = [],
        context: MockNavigationContext = MockNavigationContext(type: .type1, payload: nil),
        animated: Bool = true,
        stackSearcher: MockViewControllerStackSearcher = MockViewControllerStackSearcher()
    ) -> BackstackTransition? {
        if stackSearcher._findPathForViewController.output == nil {
            stackSearcher._findPathForViewController.output = []
        }
        return .init(
            stack: stack,
            context: context,
            animated: animated,
            stackSearcher: stackSearcher
        )
    }

}

#endif
