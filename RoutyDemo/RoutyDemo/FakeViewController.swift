import UIKit
import Routy
import RoutyIOS

class FakeViewController: UIViewController {
    struct Action {
        let title: String
        let action: () -> Void
    }
    let color: UIColor
    let actions: [Action]

    init(
        color: UIColor = .systemBackground,
        actions: [Action] = []
    ) {
        self.color = color
        self.actions = actions
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.color = .systemBackground
        self.actions = []
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 16
        view.addSubview(stackView)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        actions.forEach { action in
            let button = UIButton(
                configuration: .filled(),
                primaryAction: UIAction(
                    title: action.title,
                    handler: { _ in
                        action.action()
                    }
                )
            )
            stackView.addArrangedSubview(button)
        }

        view.backgroundColor = color
    }
}

class FakeContextChangingViewController: FakeViewController, PayloadUpdateableViewControllerProtocol {
    func canUpdate(with payload: NavigationContextPayloadProtocol?) -> Bool {
        return payload == nil || payload is ContextChangingPayload
    }

    func update(with payload: NavigationContextPayloadProtocol?) {
        let payload = payload as? ContextChangingPayload
        view.backgroundColor = payload?.color ?? .systemBackground
    }
}
