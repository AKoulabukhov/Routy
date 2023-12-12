#if canImport(UIKit)

import UIKit
import Routy

public final class DismissTransition<ScreenType: Equatable>: NavigationTransitionProtocol {
    private weak var viewController: UIViewController?
    private let logError: (String) -> Void

    public init?(
        screenType: ScreenType,
        stack: [UIViewController],
        stackSearcher: ViewControllerStackSearcherProtocol = ViewControllerStackSearcher(),
        logError: @escaping (String) -> Void = { _ in }
    ) {
        let path = stackSearcher.findPathForViewController(
            with: { $0.getNavigationContext(withContextType: ScreenType.self)?.type == screenType },
            in: stack
        )
        guard let viewController = stack.viewController(
            at: path,
            logError: logError
        ) else {
            return nil
        }
        self.viewController = viewController
        self.logError = logError
    }

    public func perform(completion: RouteCompletion?) {
        guard let viewController = viewController else {
            completion?(false)
            return
        }
        if performModalDismissIfNeeded(
            viewController: viewController,
            completion: completion
        ) {
            return
        }
        if performNavigationControllerDismissIfNeeded(
            viewController: viewController,
            completion: completion
        ) {
            return
        }
        logError("Can not dismiss \(contextType(of: viewController) as AnyObject)")
        completion?(false)
    }

    private func performModalDismissIfNeeded(
        viewController: UIViewController,
        completion: RouteCompletion?
    ) -> Bool {
        guard
            let presentingViewController = viewController.presentingViewController,
            presentingViewController.presentedViewController == viewController
        else {
            return false
        }
        presentingViewController.dismiss(
            animated: true,
            completion: {
                completion?(true)
            }
        )
        return true
    }

    private func performNavigationControllerDismissIfNeeded(
        viewController: UIViewController,
        completion: RouteCompletion?
    ) -> Bool {
        guard
            let navigationController = viewController.navigationController,
            navigationController.viewControllers.contains(viewController)
        else {
            return false
        }
        if navigationController.topViewController == viewController {
            if navigationController.viewControllers.count == 1 {
                guard
                    let presentingViewController = navigationController.presentingViewController,
                    presentingViewController.presentedViewController == navigationController
                else {
                    logError("Can not dismiss \(contextType(of: viewController) as AnyObject)")
                    return false
                }
                presentingViewController.dismiss(
                    animated: true,
                    completion: {
                        completion?(true)
                    }
                )
                return true
            } else {
                navigationController.popViewController(
                    animated: true
                )
                if let transitionCoordinator = navigationController.transitionCoordinator {
                    transitionCoordinator.animate(
                        alongsideTransition: nil,
                        completion: { _ in
                            completion?(true)
                        }
                    )
                } else {
                    completion?(true)
                }
                return true
            }
        } else {
            navigationController.setViewControllers(
                navigationController.viewControllers.filter {
                    $0 != viewController
                },
                animated: false
            )
            completion?(true)
            return true
        }
    }

    private func contextType(of viewController: UIViewController) -> ScreenType? {
        viewController.getNavigationContext(withContextType: ScreenType.self)?.type
    }
}

private extension Array where Element == UIViewController {
    func viewController(
        at path: [Int],
        logError: (String) -> Void
    ) -> UIViewController? {
        guard !path.isEmpty else {
            return nil
        }
        var path = path
        var result = self[path.removeFirst()]
        while !path.isEmpty {
            let index = path.removeFirst()
            guard
                let viewControllerContainer = (result as? ViewControllerContainer),
                viewControllerContainer.containedViewControllers.indices.contains(index)
            else {
                logError("Invalid path")
                return nil
            }
            result = viewControllerContainer.containedViewControllers[index]
        }
        return result
    }
}

#endif
