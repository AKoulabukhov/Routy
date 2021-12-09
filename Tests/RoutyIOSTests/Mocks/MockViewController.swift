#if canImport(UIKit)

import UIKit
@testable import Routy
@testable import RoutyIOS

final class MockViewController: UIViewController {

    var _presentedViewController = MockInvocation<Void, UIViewController?>()

    override var presentedViewController: UIViewController? {
        _presentedViewController.calls.append(())
        if let presentedViewController = _presentedViewController.output {
            return presentedViewController
        }
        return super.presentedViewController
    }

    var _dismiss = MockInvocation<(animated: Bool, completion: (() -> Void)?), Void>()

    override func dismiss(
        animated flag: Bool,
        completion: (() -> Void)? = nil
    ) {
        _dismiss.calls.append((flag, completion))
    }

}

final class MockContainerViewController: UIViewController, ViewControllerContainer {

    var _containedViewControllers = MockInvocation<Void, [UIViewController]>()

    var containedViewControllers: [UIViewController] {
        _containedViewControllers.calls.append(())
        return _containedViewControllers.output
    }

    var _switch = MockInvocation<(viewController: UIViewController, animated: Bool, completion: RouteCompletion?), Void>()

    func `switch`(to viewController: UIViewController, animated: Bool, completion: RouteCompletion?) {
        _switch.calls.append((viewController, animated, completion))
    }

    var _presentedViewController = MockInvocation<Void, UIViewController?>()

    override var presentedViewController: UIViewController? {
        _presentedViewController.calls.append(())
        if let presentedViewController = _presentedViewController.output {
            return presentedViewController
        }
        return super.presentedViewController
    }

    var _dismiss = MockInvocation<(animated: Bool, completion: (() -> Void)?), Void>()

    override func dismiss(
        animated flag: Bool,
        completion: (() -> Void)? = nil
    ) {
        _dismiss.calls.append((flag, completion))
    }

    convenience init(nestedControllers: [UIViewController]) {
        self.init(nibName: nil, bundle: nil)
        _containedViewControllers.output = nestedControllers
    }
}

final class MockPayloadUpdateableViewController: UIViewController, PayloadUpdateableViewControllerProtocol {

    var _canUpdate = MockInvocation<NavigationContextPayloadProtocol?, Bool>()

    func canUpdate(with payload: NavigationContextPayloadProtocol?) -> Bool {
        _canUpdate.calls.append(payload)
        return _canUpdate.output
    }

    var _update = MockInvocation<NavigationContextPayloadProtocol?, Void>()

    func update(with payload: NavigationContextPayloadProtocol?) {
        _update.calls.append(payload)
    }

}

#endif
