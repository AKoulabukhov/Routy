# Routy
![example workflow](https://github.com/AKoulabukhov/Routy/actions/workflows/swift.yml/badge.svg)

Context based navigation written in Swift. Contains basic navigation logic in `Routy` module and extended functionality for iOS platform in `RoutyIOS`.

## NavigationContext
Context is an equtable abstraction which has two properties:
1. `type` - identifies type of the screen (user, feed, order etc.)
2. `payload` - contains data OR another useful info to identify data currently shown by screen (userId, itemIds, orderId etc.), I suggest not to use it for passing callbacks (use your data layer instead), but it's up to you.

## The basic steps to perform a navigation to context(s) are:
1. Grab the current `NavigationElementProtocol` stack (`UIViewController` conforms this protocol by default, `RoutyIOS` has `ViewControllerStackProvider`).
2. Check if we can reuse existing stack to show required context (in `NavigationTransitionProviderProtocol`). `RoutyIOS` comes with `BackstackTransition` which checks if current context already in hierarchy OR there is a `UIViewController` of the same `type` but with different `payload` AND is can show this payload (`PayloadUpdateableViewControllerProtocol` might be adopted to support this option).
3. If its possible to complete navigation using current stack - it completes.
4. If there's no possibility - `NavigationElementFactoryProtocol`, which is created in your app, - asked to provide new `NavigationElementProtocol` (`UIViewController`) for required context.
5. `NavigationTransitionProviderProtocol` asked to provide transition for newly created `NavigationElementProtocol` (`UIViewController`).
6. Transition completes and calls completion for navigation.

## Which problems are solved:
1. Navigation logic can be easily tested because it decoupled from `UIViewController`s.
2. It supports `UITabBarController`, `UINavigationController`, `UIWindow.rootViewController` out of box.
2. New deeplinks are easily supported. Just convert your link into sequence of contexts.
3. Navigation can be easily intercepted. For example, some contexts require user to be authorized, so you can either do not return transition and handle failed transitions externally or return transition to Authorization screen passing desired screen in `AuthorizationContextPayload`, so after successfull authorization you'll be able to route user where he wanted to be.

Routy is competely tested and RoutyIOS has tests for almost all the classes except simple wrappers for `.present`, `.push`.

## Contribution
Feel free to raise issues and contribute to solve them :)

*Join my [Instagram](https://instagram.com/swift_codes), check my [apps](https://nsurl.dev)*
