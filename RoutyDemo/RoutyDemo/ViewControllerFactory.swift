import Routy
import RoutyIOS
import UIKit

let router = Router(
    elementFactory: ViewControllerFactory(),
    stackProvider: ViewControllerStackProvider(),
    transitionProvider: ViewControllerTransitionProvider()
)

func routePrintCompletion(to: ViewControllerType) {
    router.route(to: to, completion: {
        print("Finished presentation for \(String(describing: to)), isSuccess = \($0)")
    })
}

func routePrintCompletion(to: [ViewControllerType]) {
    router.route(to: to, completion: {
        print("Finished presentation for \(to.map { String(describing: $0) }.joined(separator: ", ")), isSuccess = \($0)")
    })
}

func makeRouteAction(to: ViewControllerType) -> FakeViewController.Action {
    .init(
        title: String(describing: to),
        action: { routePrintCompletion(to: to) }
    )
}

func makeRouteAction(
    to: ViewControllerType,
    payload: NavigationContextPayloadProtocol,
    payloadText: String
) -> FakeViewController.Action {
    let context = NavigationContext(type: to, payload: payload)
    let description = String(describing: to) + " " + payloadText
    return .init(
        title: description,
        action: {
            router.route(to: context, completion: {
                print("Finished presentation for \(description), isSuccess = \($0)")
            })
        }
    )
}

func makeRouteAction(to: [ViewControllerType]) -> FakeViewController.Action {
    .init(
        title: to.map { String(describing: $0) }.joined(separator: ", "),
        action: { routePrintCompletion(to: to) }
    )
}

final class ViewControllerFactory: NavigationElementFactoryProtocol {

    func makeElement(for context: NavigationContext<ViewControllerType>) -> UIViewController? {
        switch context.type {
        case .rootScreen:
            return FakeViewController(
                actions: [
                    makeRouteAction(to: .blueModal),
                    makeRouteAction(to: .greenModal),
                    makeRouteAction(to: [.blueModal, .greenModal]),
                    makeRouteAction(to: .redNavigation),
                    makeRouteAction(to: [.redNavigation, .purplePush]),
                    makeRouteAction(to: .rootScreen2),
                ]
            )
        case .rootScreen2:
            return FakeViewController(
                color: .systemBrown,
                actions: [
                    makeRouteAction(to: .rootScreen),
                ]
            )
        case .blueModal:
            return FakeViewController(
                color: .blue,
                actions: [makeRouteAction(to: .dismissBlueModal)]
            )
        case .greenModal:
            return FakeViewController(
                color: .green,
                actions: [makeRouteAction(to: .rootScreen)]
            )
        case .redNavigation:
            let redPush = NavigationContext(
                type: ViewControllerType.redPush
            )
            guard let viewController = makeElement(for: redPush) else {
                return nil
            }
            viewController.setNavigationContext(redPush)

            return UINavigationController(rootViewController: viewController)
        case .purplePush:
            return FakeViewController(
                color: .purple,
                actions: [
                    makeRouteAction(to: .redPush),
                    makeRouteAction(to: .rootScreen),
                    makeRouteAction(
                        to: .contextChanging,
                        payload: ContextChangingPayload(
                            color: .systemTeal
                        ),
                        payloadText: "teal"
                    ),
                ]
            )
        case .redPush:
            return FakeViewController(
                color: .red,
                actions: [
                    makeRouteAction(to: .purplePush),
                    makeRouteAction(to: .rootScreen),
                    makeRouteAction(to: .contextChanging),
                ]
            )
        case .contextChanging:
            return FakeContextChangingViewController(
                color: (context.payload as? ContextChangingPayload)?.color ?? .systemBackground,
                actions: [
                    makeRouteAction(
                        to: .contextChanging,
                        payload: ContextChangingPayload(
                            color: .systemFill
                        ),
                        payloadText: "system fill"
                    ),
                    makeRouteAction(to: .purplePush),
                ]
            )
        case .dismissBlueModal:
            return nil
        }
    }
    
}
