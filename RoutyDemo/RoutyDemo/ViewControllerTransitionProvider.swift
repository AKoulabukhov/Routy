import Routy
import RoutyIOS
import UIKit

final class ViewControllerTransitionProvider: NavigationTransitionProviderProtocol {

    func makeReuseTransition(
        for context: NavigationContext<ViewControllerType>,
        in stack: [UIViewController]
    ) -> NavigationTransitionProtocol? {
        BackstackTransition(
            stack: stack,
            context: context
        )
    }

    func makePresentTransition(
        for element: UIViewController,
        in stack: [UIViewController]
    ) -> NavigationTransitionProtocol? {
        guard
            let context = element.getNavigationContext(withContextType: ViewControllerType.self)
        else {
            return nil
        }
        switch context.type {
        case .rootScreen, .rootScreen2:
            return RootTransition(
                viewController: element,
                animated: !stack.isEmpty
            )
        case .blueModal, .greenModal, .redNavigation:
            guard let presentingViewController = stack.last else { return nil }
            return ModalTransition(
                presentingViewController: presentingViewController,
                viewController: element,
                presentationStyle: context.type == .redNavigation ? .fullScreen : nil
            )
        case .purplePush, .redPush, .contextChanging:
            guard let presentingViewController = stack.last else { return nil }
            return PushTransition(
                presentingViewController: presentingViewController,
                viewController: element
            )
        }
    }

    func makeDismissTransition(
        for context: NavigationContext<ViewControllerType>,
        in stack: [UIViewController]
    ) -> NavigationTransitionProtocol? {
        DismissTransition(
            screenType: context.type,
            stack: stack
        )
    }
}

