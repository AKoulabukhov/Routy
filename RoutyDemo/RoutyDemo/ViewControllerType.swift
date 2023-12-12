import Routy
import UIKit

enum ViewControllerType: Equatable {
    case rootScreen
    case rootScreen2
    
    case blueModal
    case greenModal

    case redNavigation
    case redPush
    case purplePush

    case contextChanging

    case dismissBlueModal
}

struct ContextChangingPayload: Equatable, NavigationContextPayloadProtocol {
    let color: UIColor
}
