#if canImport(UIKit)

import XCTest
@testable import RoutyIOS

@MainActor
final class RootTransitionTests: XCTestCase {

    func testThatMissingWindowFailsTransitionWithoutCustomCompletion() {
        var customCompletionCallsCount = 0
        var routeResults = [Bool]()
        let sut = RootTransition(
            viewController: UIViewController(),
            animated: false,
            keyWindowProvider: { nil },
            completion: { customCompletionCallsCount += 1 }
        )

        sut.perform(completion: { routeResults.append($0) })

        XCTAssertEqual(customCompletionCallsCount, 0)
        XCTAssertEqual(routeResults, [false])
    }

    func testThatNonAnimatedTransitionSetsRootAndCallsCompletionsInOrder() {
        let window = UIWindow()
        let viewController = UIViewController()
        var completionEvents = [String]()
        let sut = RootTransition(
            viewController: viewController,
            animated: false,
            keyWindowProvider: { window },
            completion: { completionEvents.append("custom") }
        )

        sut.perform(completion: { completionEvents.append("route:\($0)") })

        XCTAssertIdentical(window.rootViewController, viewController)
        XCTAssertEqual(completionEvents, ["custom", "route:true"])
    }

    func testThatPresentedControllersAreDismissedBeforeReplacingRoot() throws {
        let window = UIWindow()
        let currentRoot = MockViewController()
        currentRoot._presentedViewController.output = UIViewController()
        window.rootViewController = currentRoot
        let newRoot = UIViewController()
        var routeResults = [Bool]()
        let sut = RootTransition(
            viewController: newRoot,
            animated: false,
            keyWindowProvider: { window }
        )

        sut.perform(completion: { routeResults.append($0) })

        XCTAssertIdentical(window.rootViewController, currentRoot)
        XCTAssertTrue(routeResults.isEmpty)

        let dismissCompletion = try XCTUnwrap(currentRoot._dismiss.lastCall?.completion)
        dismissCompletion()

        XCTAssertIdentical(window.rootViewController, newRoot)
        XCTAssertEqual(routeResults, [true])
    }
}

#endif
