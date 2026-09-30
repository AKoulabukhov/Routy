#if canImport(UIKit)

import UIKit

extension UIApplication {
    var compatibleKeyWindow: UIWindow? {
        if #available(iOS 13.0, *) {
            return Self.compatibleKeyWindow(
                in: connectedScenes.compactMap { scene in
                    guard let windowScene = scene as? UIWindowScene else {
                        return nil
                    }
                    return (windowScene.activationState, windowScene.windows)
                }
            )
        } else {
            return keyWindow
        }
    }

    @available(iOS 13.0, *)
    static func compatibleKeyWindow(
        in scenes: [(activationState: UIScene.ActivationState, windows: [UIWindow])]
    ) -> UIWindow? {
        let foregroundWindow = scenes
            .filter {
                $0.activationState == .foregroundActive ||
                $0.activationState == .foregroundInactive
            }
            .lazy
            .compactMap { $0.windows.first(where: { $0.isKeyWindow }) }
            .first

        return foregroundWindow ?? scenes
            .lazy
            .compactMap { $0.windows.first(where: { $0.isKeyWindow }) }
            .first
    }

    var rootViewController: UIViewController? {
        compatibleKeyWindow?.rootViewController
    }
}

#endif
