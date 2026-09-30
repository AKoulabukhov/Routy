#if canImport(UIKit)

import UIKit

extension UIApplication {
    var compatibleKeyWindow: UIWindow? {
        if #available(iOS 13.0, *) {
            return connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .filter {
                    $0.activationState == .foregroundActive ||
                    $0.activationState == .foregroundInactive
                }
                .lazy
                .compactMap { scene in
                    scene.windows.first(where: { $0.isKeyWindow })
                }
                .first
        } else {
            return keyWindow
        }
    }
    var rootViewController: UIViewController? {
        compatibleKeyWindow?.rootViewController
    }
}

#endif
