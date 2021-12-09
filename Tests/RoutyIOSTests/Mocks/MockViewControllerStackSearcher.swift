#if canImport(UIKit)

import UIKit
import RoutyIOS

final class MockViewControllerStackSearcher: ViewControllerStackSearcherProtocol {

    var _findPathForViewController = MockInvocation<(predicate: ((UIViewController) -> Bool), stack: [UIViewController]), [Int]>()

    func findPathForViewController(
        with predicate: @escaping (UIViewController) -> Bool,
        in stack: [UIViewController]
    ) -> [Int] {
        _findPathForViewController.calls.append((predicate, stack))
        return _findPathForViewController.output
    }

}

#endif
