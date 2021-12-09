#if canImport(UIKit)

import Routy
import UIKit

public struct RootTransition: NavigationTransitionProtocol {
    public typealias KeyWindowProvider = () -> UIWindow?

    private let viewController: UIViewController
    private let animated: Bool
    private let completion: (() -> Void)?
    private let keyWindowProvider: KeyWindowProvider

    public init(
        viewController: UIViewController,
        animated: Bool = true,
        keyWindowProvider: KeyWindowProvider? = nil,
        completion: (() -> Void)? = nil
    ) {
        self.viewController = viewController
        self.animated = animated
        self.keyWindowProvider = keyWindowProvider ?? {
            UIApplication.shared.compatibleKeyWindow
        }
        self.completion = completion
    }

    public func perform(completion: RouteCompletion?) {
        guard let keyWindow = keyWindowProvider() else {
            completion?(false)
            return
        }
        let animated = animated
        let viewController = viewController
        let dismissViewControllersIfNeeded: ((() -> Void)?) -> Void = { completion in
            guard
                let rootViewController = keyWindow.rootViewController,
                rootViewController.presentedViewController != nil
            else {
                completion?()
                return
            }
            rootViewController.dismiss(
                animated: animated,
                completion: completion
            )
        }
        dismissViewControllersIfNeeded {
            if animated {
                UIView.transition(
                    with: keyWindow,
                    duration: CATransaction.animationDuration(),
                    options: [.transitionCrossDissolve],
                    animations: {
                        keyWindow.rootViewController = viewController
                    },
                    completion: { _ in
                        completion?(true)
                    }
                )
            } else {
                keyWindow.rootViewController = viewController
                completion?(true)
            }
        }
    }

}

#endif
