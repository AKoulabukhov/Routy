#if canImport(UIKit)

import Routy
import UIKit

public struct PushTransition: NavigationTransitionProtocol {

    private let navigationController: UINavigationController
    private let viewController: UIViewController
    private let animated: Bool
    private let completion: (() -> Void)?

    public init(
        navigationController: UINavigationController,
        viewController: UIViewController,
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        self.navigationController = navigationController
        self.viewController = viewController
        self.animated = animated
        self.completion = completion
    }

    public init?(
        presentingViewController: UIViewController,
        viewController: UIViewController,
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        guard let navigationController: UINavigationController = {
            if let navigationController = presentingViewController as? UINavigationController {
                return navigationController
            }
            if let navigationController = presentingViewController.navigationController {
                return navigationController
            }
            return nil
        }() else {
            return nil
        }
        self.init(
            navigationController: navigationController,
            viewController: viewController,
            animated: animated,
            completion: completion
        )
    }

    public func perform(completion: RouteCompletion?) {
        navigationController.pushViewController(
            viewController,
            animated: animated
        )
        let customCompletion = self.completion
        if animated, let coordinator = navigationController.transitionCoordinator {
            coordinator.animate(alongsideTransition: nil) { _ in
                customCompletion?()
                completion?(true)
            }
        } else {
            customCompletion?()
            completion?(true)
        }
    }

}

#endif
