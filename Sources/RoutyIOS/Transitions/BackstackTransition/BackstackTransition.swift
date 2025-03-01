#if canImport(UIKit)

import Routy
import UIKit

@MainActor public protocol PayloadUpdateableViewControllerProtocol: UIViewController {
    func canUpdate(with payload: NavigationContextPayloadProtocol?) -> Bool
    func update(with payload: NavigationContextPayloadProtocol?)
}

public final class BackstackTransition<ContextType: Equatable>: NavigationTransitionProtocol {

    private let stack: [UIViewController]
    private let context: NavigationContext<ContextType>
    private let animated: Bool
    private let supportingViewControllerIndexPath: [Int]

    public init?(
        stack: [UIViewController],
        context: NavigationContext<ContextType>,
        animated: Bool = true,
        stackSearcher: ViewControllerStackSearcherProtocol = ViewControllerStackSearcher()
    ) {
        let supportingControllerPath = stackSearcher.findPathForViewController(
            with: { $0.supportsContext(context: context) },
            in: stack
        )
        guard !supportingControllerPath.isEmpty else { return nil }
        self.stack = stack
        self.context = context
        self.animated = animated
        self.supportingViewControllerIndexPath = supportingControllerPath
    }

    public func perform(completion: RouteCompletion?) {
        typealias TransitionData = (
            sourceViewController: ViewControllerContainer,
            targetViewController: UIViewController
        )
        typealias Operation = (RouteCompletion?) -> Void

        let indexPath = supportingViewControllerIndexPath
        let stack = stack
        let context = context
        let animated = animated

        func makeIndexPath(length: Int) -> [Int] {
            Array(indexPath.prefix(length))
        }

        let rootOperation: Operation = { completion in
            stack[indexPath[0]].dismissPresentedViewController(
                animated: animated,
                completion: { completion?(true) }
            )
        }

        let containerTransitionData: [TransitionData] = (1..<indexPath.count).compactMap { length in
            let indexPath = makeIndexPath(length: length)
            let nextIndexPath = makeIndexPath(length: length + 1)
            guard
                let sourceViewController = stack.containedViewController(at: indexPath) as? ViewControllerContainer,
                let targetViewController = stack.containedViewController(at: nextIndexPath)
            else {
                assertionFailure("Incorrect indices")
                return nil
            }
            return (sourceViewController, targetViewController)
        }

        let containerOperations: [Operation] = containerTransitionData.map { transitionData in
            { operationCompletion in
                transitionData.sourceViewController.switch(
                    to: transitionData.targetViewController,
                    animated: animated,
                    completion: operationCompletion
                )
            }
        }

        let switchContextOperation: Operation = { completion in
            guard let targetViewController = stack.containedViewController(at: indexPath) else {
                assertionFailure("Incorrect indices")
                completion?(false)
                return
            }
            let targetContext = targetViewController.getNavigationContext(withContextType: ContextType.self)
            guard targetContext != context else {
                completion?(true)
                return
            }
            if let updateableViewController = targetViewController as? PayloadUpdateableViewControllerProtocol {
                updateableViewController.update(with: context.payload)
                completion?(true)
            } else {
                assertionFailure("Incorrect view controller type")
                completion?(false)
            }
        }

        let operations = [rootOperation] + containerOperations + [switchContextOperation]
        operations.chained()(completion)
    }

}

private extension UIViewController {
    func supportsContext<ContextType: Equatable>(context: NavigationContext<ContextType>) -> Bool {
        guard let ownContext = getNavigationContext(withContextType: ContextType.self) else { return false }
        guard ownContext.type == context.type else { return false }
        switch (ownContext.payload, context.payload) {
        case let (ownPayload?, payload?):
            if ownPayload.isEqual(to: payload) {
                return true
            } else {
                return canHandlePayload(payload)
            }
        case (_?, nil):
            return canHandlePayload(nil)
        case (nil, let payload?):
            return canHandlePayload(payload)
        case (nil, nil):
            return true
        }
    }
    func dismissPresentedViewController(
        animated: Bool,
        completion: (() -> Void)? = nil
    ) {
        if presentedViewController != nil {
            dismiss(
                animated: animated,
                completion: completion
            )
        } else {
            completion?()
        }
    }
    private func canHandlePayload(_ payload: NavigationContextPayloadProtocol?) -> Bool {
        (self as? PayloadUpdateableViewControllerProtocol)?.canUpdate(with: payload) == true
    }
}

#endif
