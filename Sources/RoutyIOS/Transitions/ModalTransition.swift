#if canImport(UIKit)

import Routy
import UIKit

public struct ModalTransition: NavigationTransitionProtocol {

    private let presentingViewController: UIViewController
    private let viewController: UIViewController
    private let animated: Bool
    private let completion: (() -> Void)?
    private let presentationStyle: UIModalPresentationStyle?
    private let transitionStyle: UIModalTransitionStyle?
    private let capturesStatusBarAppearance: Bool?

    public init(
        presentingViewController: UIViewController,
        viewController: UIViewController,
        animated: Bool = true,
        completion: (() -> Void)? = nil,
        presentationStyle: UIModalPresentationStyle? = nil,
        transitionStyle: UIModalTransitionStyle? = nil,
        capturesStatusBarAppearance: Bool? = nil
    ) {
        self.presentingViewController = presentingViewController
        self.viewController = viewController
        self.animated = animated
        self.completion = completion
        self.presentationStyle = presentationStyle
        self.transitionStyle = transitionStyle
        self.capturesStatusBarAppearance = capturesStatusBarAppearance
    }

    public func perform(completion: RouteCompletion?) {
        if let presentationStyle = presentationStyle {
            viewController.modalPresentationStyle = presentationStyle
        }
        if let transitionStyle = transitionStyle {
            viewController.modalTransitionStyle = transitionStyle
        }
        if let capturesStatusBarAppearance = capturesStatusBarAppearance {
            viewController.modalPresentationCapturesStatusBarAppearance = capturesStatusBarAppearance
        }
        let customCompletion = self.completion
        presentingViewController.present(viewController, animated: animated, completion: {
            customCompletion?()
            completion?(true)
        })
    }

}

#endif
