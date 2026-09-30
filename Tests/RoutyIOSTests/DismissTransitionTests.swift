#if canImport(UIKit)

import XCTest
@testable import RoutyIOS

@MainActor
final class DismissTransitionTests: XCTestCase {
    private typealias Transition = DismissTransition<MockNavigationContextType>

    func testThatTransitionIsNotCreatedWhenContextIsMissing() {
        let viewController = UIViewController()
        viewController.setNavigationContext(MockNavigationContext(type: .type1))

        let sut = Transition(
            screenType: .type2,
            stack: [viewController]
        )

        XCTAssertNil(sut)
    }

    func testThatContextInitializerComparesPayload() {
        let viewController = UIViewController()
        viewController.setNavigationContext(MockNavigationContext(
            type: .type1,
            payload: MockNavigationContextPayload1(field: "actual")
        ))

        let sut = Transition(
            context: MockNavigationContext(
                type: .type1,
                payload: MockNavigationContextPayload1(field: "requested")
            ),
            stack: [viewController]
        )

        XCTAssertNil(sut)
    }

    func testThatModalViewControllerIsDismissed() throws {
        let presenter = MockViewController()
        let viewController = MockViewController()
        presenter._presentedViewController.output = viewController
        viewController._presentingViewController.output = presenter
        viewController.setNavigationContext(MockNavigationContext(type: .type1))
        let sut = try XCTUnwrap(Transition(
            screenType: .type1,
            stack: [presenter, viewController]
        ))
        var routeResults = [Bool]()

        sut.perform(completion: { routeResults.append($0) })

        XCTAssertTrue(routeResults.isEmpty)
        let dismissCompletion = try XCTUnwrap(presenter._dismiss.lastCall?.completion)
        dismissCompletion()
        XCTAssertEqual(routeResults, [true])
    }

    func testThatTopNavigationControllerChildIsPopped() throws {
        let rootViewController = UIViewController()
        let viewController = UIViewController()
        viewController.setNavigationContext(MockNavigationContext(type: .type1))
        let navigationController = UINavigationController()
        navigationController.setViewControllers(
            [rootViewController, viewController],
            animated: false
        )
        let sut = try XCTUnwrap(Transition(
            screenType: .type1,
            stack: [navigationController]
        ))
        var routeResults = [Bool]()

        sut.perform(completion: { routeResults.append($0) })

        XCTAssertEqual(navigationController.viewControllers, [rootViewController])
        XCTAssertEqual(routeResults, [true])
    }

    func testThatNonTopNavigationControllerChildIsRemoved() throws {
        let rootViewController = UIViewController()
        let viewController = UIViewController()
        let topViewController = UIViewController()
        viewController.setNavigationContext(MockNavigationContext(type: .type1))
        let navigationController = UINavigationController()
        navigationController.setViewControllers(
            [rootViewController, viewController, topViewController],
            animated: false
        )
        let sut = try XCTUnwrap(Transition(
            screenType: .type1,
            stack: [navigationController]
        ))
        var routeResults = [Bool]()

        sut.perform(completion: { routeResults.append($0) })

        XCTAssertEqual(
            navigationController.viewControllers,
            [rootViewController, topViewController]
        )
        XCTAssertEqual(routeResults, [true])
    }

    func testThatSingleChildPresentedNavigationControllerIsDismissed() throws {
        let presenter = MockViewController()
        let viewController = UIViewController()
        viewController.setNavigationContext(MockNavigationContext(type: .type1))
        let navigationController = MockNavigationController(
            rootViewController: viewController
        )
        presenter._presentedViewController.output = navigationController
        navigationController._presentingViewController.output = presenter
        let sut = try XCTUnwrap(Transition(
            screenType: .type1,
            stack: [presenter, navigationController]
        ))
        var routeResults = [Bool]()

        sut.perform(completion: { routeResults.append($0) })

        XCTAssertTrue(routeResults.isEmpty)
        let dismissCompletion = try XCTUnwrap(presenter._dismiss.lastCall?.completion)
        dismissCompletion()
        XCTAssertEqual(routeResults, [true])
    }

    func testThatUndismissableViewControllerFailsAndLogsError() throws {
        let viewController = UIViewController()
        viewController.setNavigationContext(MockNavigationContext(type: .type1))
        var errors = [String]()
        let sut = try XCTUnwrap(Transition(
            screenType: .type1,
            stack: [viewController],
            logError: { errors.append($0) }
        ))
        var routeResults = [Bool]()

        sut.perform(completion: { routeResults.append($0) })

        XCTAssertEqual(routeResults, [false])
        XCTAssertEqual(errors.count, 1)
    }
}

#endif
