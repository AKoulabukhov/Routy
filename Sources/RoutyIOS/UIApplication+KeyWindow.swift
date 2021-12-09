#if canImport(UIKit)

import UIKit

extension UIApplication {
    var compatibleKeyWindow: UIWindow? {
        if #available(iOS 13.0, *) {
            return windows.first(where: { $0.isKeyWindow })
        } else {
            return keyWindow
        }
    }
    var rootViewController: UIViewController? {
        compatibleKeyWindow?.rootViewController
    }
}

#endif
