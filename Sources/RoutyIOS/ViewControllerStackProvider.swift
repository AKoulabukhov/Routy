#if canImport(UIKit)

import UIKit
import Routy

public final class ViewControllerStackProvider: NavigationStackProviderProtocol {
    public typealias RootViewControllerProvider = () -> UIViewController?

    private let rootViewControllerProvider: RootViewControllerProvider

    public init(
        rootViewControllerProvider: RootViewControllerProvider? = nil
    ) {
        self.rootViewControllerProvider = rootViewControllerProvider ?? {
            UIApplication.shared.rootViewController
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
