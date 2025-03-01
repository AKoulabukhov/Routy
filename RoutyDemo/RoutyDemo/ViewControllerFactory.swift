import Routy
import RoutyIOS
import UIKit

@MainActor let router = Router(
    elementFactory: ViewControllerFactory(),
    stackProvider: ViewControllerStackProvider(),
    transitionProvider: ViewControllerTransitionProvider()
)

@MainActor func presentPrintCompletion(to: ViewControllerType) {
    router.present(to, completion: {
        print("Finished presentation for \(String(describing: to)), isSuccess = \($0)")
    })
}

@MainActor func presentPrintCompletion(to: [ViewControllerType]) {
    router.present(to, completion: {
        print("Finished presentation for \(to.map { String(describing: $0) }.joined(separator: ", ")), isSuccess = \($0)")
    })
}

@MainActor func dismissPrintCompletion(of: ViewControllerType) {
    router.dismiss(of, completion: {
        print("Finished dismiss for \(String(describing: of)), isSuccess = \($0)")
    })
}

@MainActor func makePresentAction(to: ViewControllerType) -> FakeViewController.Action {
    .init(
        title: String(describing: to),
        action: { presentPrintCompletion(to: to) }
    )
}

@MainActor func makeDismissAction(of: ViewControllerType) -> FakeViewController.Action {
    .init(
        title: "Dismiss " + String(describing: of),
        action: { dismissPrintCompletion(of: of) }
    )
}

@MainActor func makePresentAction(
    to: ViewControllerType,
    payload: NavigationContextPayloadProtocol,
    payloadText: String
) -> FakeViewController.Action {
    let context = NavigationContext(type: to, payload: payload)
    let description = String(describing: to) + " " + payloadText
    return .init(
        title: description,
        action: {
            router.present(context, completion: {
                print("Finished presentation for \(description), isSuccess = \($0)")
            })
        }
    )
}

@MainActor func makePresentAction(to: [ViewControllerType]) -> FakeViewController.Action {
    .init(
        title: to.map { String(describing: $0) }.joined(separator: ", "),
        action: { presentPrintCompletion(to: to) }
    )
}

final class ViewControllerFactory: NavigationElementFactoryProtocol {

    func makeElement(for context: NavigationContext<ViewControllerType>) -> UIViewController? {
        switch context.type {
        case .rootScreen:
            return FakeViewController(
                actions: [
                    makePresentAction(to: .blueModal),
                    makePresentAction(to: .greenModal),
                    makePresentAction(to: [.blueModal, .greenModal]),
                    makePresentAction(to: .redNavigation),
                    makePresentAction(to: [.redNavigation, .purplePush]),
                    makePresentAction(to: .rootScreen2),
                ]
            )
        case .rootScreen2:
            return FakeViewController(
                color: .systemBrown,
                actions: [
                    makePresentAction(to: .rootScreen),
                ]
            )
        case .blueModal:
            return FakeViewController(
                color: .blue,
                actions: [makeDismissAction(of: .blueModal)]
            )
        case .greenModal:
            return FakeViewController(
                color: .green,
                actions: [makePresentAction(to: .rootScreen)]
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
                    makePresentAction(to: .redPush),
                    makePresentAction(to: .rootScreen),
                    makePresentAction(
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
                    makePresentAction(to: .purplePush),
                    makePresentAction(to: .rootScreen),
                    makePresentAction(to: .contextChanging),
                ]
            )
        case .contextChanging:
            return FakeContextChangingViewController(
                color: (context.payload as? ContextChangingPayload)?.color ?? .systemBackground,
                actions: [
                    makePresentAction(
                        to: .contextChanging,
                        payload: ContextChangingPayload(
                            color: .systemFill
                        ),
                        payloadText: "system fill"
                    ),
                    makePresentAction(to: .purplePush),
                ]
            )
        }
    }
    
}
