import Routy
import RoutyIOS
import UIKit

final class ViewControllerTransitionProvider: NavigationTransitionProviderProtocol {

    func makeTransition(
        for context: NavigationContext<ViewControllerType>,
        in stack: [UIViewController]
    ) -> NavigationTransitionProtocol? {
        if case .dismissBlueModal = context.type {
            return DismissTransition(
                screenType: ViewControllerType.blueModal,
                stack: stack
            )
        }
        return BackstackTransition(
            stack: stack,
            context: context
        )
    }

    func makeTransition(
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
        case .dismissBlueModal:
            return nil
        }
    }

}

