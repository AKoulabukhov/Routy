#if canImport(UIKit)

import XCTest
@testable import RoutyIOS

@MainActor
@available(iOS 13.0, *)
final class UIApplicationKeyWindowTests: XCTestCase {

    func testThatUnattachedSceneKeyWindowIsUsedDuringSceneConnection() {
        let window = KeyWindow()

        let result = UIApplication.compatibleKeyWindow(
            in: [(.unattached, [window])]
        )

        XCTAssertIdentical(result, window)
    }

    func testThatForegroundSceneTakesPrecedenceOverFallbackScene() {
        let fallbackWindow = KeyWindow()
        let foregroundWindow = KeyWindow()

        let result = UIApplication.compatibleKeyWindow(
            in: [
                (.unattached, [fallbackWindow]),
                (.foregroundActive, [foregroundWindow]),
            ]
        )

        XCTAssertIdentical(result, foregroundWindow)
    }
}

private final class KeyWindow: UIWindow {
    override var isKeyWindow: Bool { true }
}

#endif
