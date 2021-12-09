#if canImport(UIKit)

import XCTest
@testable import RoutyIOS

final class ViewControllerStackSearcherTests: XCTestCase {

    // MARK: - Logic tests

    func testEmptyStackReturnsEmptyResult() {
        let sut = ViewControllerStackSearcher()

        let result = sut.findPathForViewController(
            with: { _ in true },
            in: []
        )

        XCTAssertEqual(result, [])
    }

    func testSimpleStackWithNoSuitableControllerReturnsEmptyResult() {
        let sut = ViewControllerStackSearcher()

        let result = sut.findPathForViewController(
            with: { _ in false },
            in: [
                UIViewController(),
                UIViewController(),
            ]
        )

        XCTAssertEqual(result, [])
    }

    func testSimpleStackWithSuitableControllerReturnsCorrectIndex() {
        let sut = ViewControllerStackSearcher()
        let suitableViewController = UIViewController()

        let result = sut.findPathForViewController(
            with: { $0 === suitableViewController },
            in: [
                UIViewController(),
                suitableViewController,
                UIViewController(),
            ]
        )

        XCTAssertEqual(result, [1])
    }

    func testSimpleStackWithMultipleSuitableControllersReturnsLastCorrectIndex() {
        let sut = ViewControllerStackSearcher()
        let suitableViewController = UIViewController()

        let result = sut.findPathForViewController(
            with: { $0 === suitableViewController },
            in: [
                UIViewController(),
                suitableViewController,
                UIViewController(),
                suitableViewController,
            ]
        )

        XCTAssertEqual(result, [3])
    }

    func testNestedStackWithSuitableControllerReturnsCorrectIndex() {
        let sut = ViewControllerStackSearcher()
        let suitableViewController = UIViewController()

        let result = sut.findPathForViewController(
            with: { $0 === suitableViewController },
            in: [
                UIViewController(),
                MockContainerViewController(nestedControllers: [
                    UIViewController(),
                    suitableViewController
                ]),
                UIViewController(),
            ]
        )

        XCTAssertEqual(result, [1, 1])
    }

    func testNestedStackWithMultipleSuitableControllersReturnsLastCorrectIndex() {
        let sut = ViewControllerStackSearcher()
        let suitableViewController = UIViewController()

        let result = sut.findPathForViewController(
            with: { $0 === suitableViewController },
            in: [
                UIViewController(),
                MockContainerViewController(nestedControllers: [
                    UIViewController(),
                    suitableViewController,
                ]),
                UIViewController(),
                MockContainerViewController(nestedControllers: [
                    MockContainerViewController(nestedControllers: [
                        suitableViewController,
                        UIViewController()
                    ]),
                    UIViewController(),
                ]),
            ]
        )

        XCTAssertEqual(result, [3, 0, 0])
    }

    // MARK: - Complexity tests

    func testSimpleStackComplexity() {
        let sut = ViewControllerStackSearcher()
        let suitableViewController = UIViewController()
        var predicateCallsCount = 0

        _ = sut.findPathForViewController(
            with: {
                predicateCallsCount += 1
                return $0 === suitableViewController
            },
            in: [
                UIViewController(),
                suitableViewController,
                UIViewController(),
            ]
        )

        XCTAssertTrue(predicateCallsCount <= 2)
    }

    func testNestedStackComplexity() {
        let sut = ViewControllerStackSearcher()
        let suitableViewController = UIViewController()
        var predicateCallsCount = 0

        _ = sut.findPathForViewController(
            with: {
                predicateCallsCount += 1
                return $0 === suitableViewController
            },
            in: [
                UIViewController(),
                MockContainerViewController(nestedControllers: [
                    UIViewController(),
                    suitableViewController,
                ]),
                UIViewController(),
                MockContainerViewController(nestedControllers: [
                    MockContainerViewController(nestedControllers: [
                        suitableViewController,
                        UIViewController()
                    ]),
                    UIViewController(),
                ]),
            ]
        )

        XCTAssertTrue(predicateCallsCount <= 5)
    }

}

#endif
