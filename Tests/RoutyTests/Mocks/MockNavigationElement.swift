import Foundation
@testable import Routy

final class MockNavigationElement: Equatable, NavigationElementProtocol {

    var _setContext = MockInvocation<Any?, Void>()

    func setNavigationContext<ContextType>(
        _ context: NavigationContext<ContextType>?
    ) where ContextType : Equatable {
        _setContext.calls.append(context)
    }

    var _getContext = MockInvocation<Any, Any?>()

    func getNavigationContext<ContextType>(
        withContextType contextType: ContextType.Type
    ) -> NavigationContext<ContextType>? where ContextType : Equatable {
        _getContext.calls.append(contextType)
        return _getContext.output as? NavigationContext<ContextType>
    }

    var _hasContext = MockInvocation<Void, Bool>()

    var hasContext: Bool {
        _hasContext.calls.append(())
        return _hasContext.output
    }

    static func == (lhs: MockNavigationElement, rhs: MockNavigationElement) -> Bool {
        lhs === rhs
    }
}
