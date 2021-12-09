#if canImport(UIKit)

import XCTest
@testable import RoutyIOS

final class ViewControllerStackProviderTests: XCTestCase {

    func testThatStackBuildFromPresentedViewControllers() {
        let rootViewController = MockViewController()
        let viewController1 = MockViewController()
        rootViewController._presentedViewController.output = viewController1
        let viewController2 = MockViewController()
        viewController1._presentedViewController.output = viewController2
        viewController2._presentedViewController.output = .some(nil)

        let expectedStack: [MockViewController] = [
            rootViewController,
            viewController1,
            viewController2
        ]

        let actualStack = ViewControllerStackProvider(
            rootViewControllerProvider: { rootViewController }
        ).getNavigationStack()

        XCTAssertEqual(expectedStack, actualStack)
        XCTAssertTrue(expectedStack.allSatisfy {
            $0._presentedViewController.callsCount == 1
        })
    }

}

#endif
