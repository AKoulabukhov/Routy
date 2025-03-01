#if canImport(UIKit)

import UIKit

@MainActor 
public protocol ViewControllerStackSearcherProtocol: AnyObject {
    typealias Predicate = (UIViewController) -> Bool
    func findPathForViewController(
        with predicate: @escaping Predicate, // @escaping makes testing easier
        in stack: [UIViewController]
    ) -> [Int]
}

public final class ViewControllerStackSearcher: ViewControllerStackSearcherProtocol {

    public init() { }

    public func findPathForViewController(
        with predicate: @escaping (UIViewController) -> Bool,
        in stack: [UIViewController]
    ) -> [Int] {
        findPathForViewController(
            with: predicate,
            in: stack,
            initialPath: []
        )
    }

    private func findPathForViewController(
        with predicate: (UIViewController) -> Bool,
        in stack: [UIViewController],
        initialPath: [Int]
    ) -> [Int] {
        // Using .reversed() to perform the least possible number of sub-transitions (modal presentations, navigation controllers, etc.)
        for index in stack.indices.reversed() {

            let viewController = stack[index]
            let newPath = initialPath + [index]

            if predicate(stack[index]) {
                return newPath
            }

            if let container = viewController as? ViewControllerContainer {
                let subviewsPath = findPathForViewController(
                    with: predicate,
                    in: container.containedViewControllers,
                    initialPath: newPath
                )
                if !subviewsPath.isEmpty {
                    return subviewsPath
                }
            }
        }
        return []
    }

}

#endif
