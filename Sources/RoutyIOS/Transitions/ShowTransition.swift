#if canImport(UIKit)

import Routy
import UIKit

public struct ShowTransition: NavigationTransitionProtocol {

    private let presentingViewController: UIViewController
    private let viewController: UIViewController
    private let animated: Bool
    private let completion: (() -> Void)?
    private let modalPresentationStyle: UIModalPresentationStyle?
    private let modalTransitionStyle: UIModalTransitionStyle?
    private let modalCapturesStatusBarAppearance: Bool?

    public init(
        presentingViewController: UIViewController,
        viewController: UIViewController,
        animated: Bool = true,
        completion: (() -> Void)? = nil,
        modalPresentationStyle: UIModalPresentationStyle? = nil,
        modalTransitionStyle: UIModalTransitionStyle? = nil,
        modalCapturesStatusBarAppearance: Bool? = nil
    ) {
        self.presentingViewController = presentingViewController
        self.viewController = viewController
        self.animated = animated
        self.completion = completion
        self.modalPresentationStyle = modalPresentationStyle
        self.modalTransitionStyle = modalTransitionStyle
        self.modalCapturesStatusBarAppearance = modalCapturesStatusBarAppearance
    }

    public func perform(completion: RouteCompletion?) {
        let customCompletion = self.completion
        if let pushTransition = PushTransition(
            presentingViewController: presentingViewController,
            viewController: viewController,
            animated: animated,
            completion: customCompletion
        ) {
            pushTransition.perform(completion: completion)
        } else {
            ModalTransition(
                presentingViewController: presentingViewController,
                viewController: viewController,
                animated: animated,
                completion: customCompletion,
                presentationStyle: modalPresentationStyle,
                transitionStyle: modalTransitionStyle,
                capturesStatusBarAppearance: modalCapturesStatusBarAppearance
            ).perform(
                completion: completion
            )
        }
    }

}

#endif
