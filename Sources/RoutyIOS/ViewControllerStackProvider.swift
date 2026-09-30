#if canImport(UIKit)

import UIKit
import Routy

public final class ViewControllerStackProvider: NavigationStackProviderProtocol {
    public typealias RootViewControllerProvider = () -> UIViewController?
    public typealias WindowProvider = () -> UIWindow?

    private let rootViewControllerProvider: RootViewControllerProvider

    public init(
        rootViewControllerProvider: RootViewControllerProvider? = nil
    ) {
        self.rootViewControllerProvider = rootViewControllerProvider ?? {
            UIApplication.shared.rootViewController
        }
    }

    /// Creates a stack provider scoped to a specific window.
    /// Prefer this initializer in apps that support multiple scenes.
    public init(windowProvider: @escaping WindowProvider) {
        self.rootViewControllerProvider = {
            windowProvider()?.rootViewController
        }
    }

    public func getNavigationStack() -> [UIViewController] {
        guard let rootViewController = rootViewController else { return [] }
        return Array(sequence(
            first: rootViewController,
            next: { $0.presentedViewController }
        ).filter {
            !$0.isBeingDismissed
        })
    }

    private var rootViewController: UIViewController? {
        rootViewControllerProvider()
    }

}

#endif
