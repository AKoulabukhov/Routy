import XCTest
@testable import Routy

final class NavigationContextTests: XCTestCase {

    func testThatContextOfDifferentTypesAreNotEqual() throws {
        let context1 = MockNavigationContext(type: .type1)
        let context2 = MockNavigationContext(type: .type2)
        XCTAssertNotEqual(context1, context2)
    }

    func testThatContextOfTheSameTypeWithoutPayloadAreEqual() throws {
        let context1 = MockNavigationContext(type: .type1)
        let context2 = MockNavigationContext(type: .type1)
        XCTAssertEqual(context1, context2)
    }

    func testThatContextOfTheSameTypeWithAndWithoutPayloadAreNotEqual() throws {
        let context1 = MockNavigationContext(
            type: .type1,
            payload: MockNavigationContextPayload1(
                field: "field"
            )
        )
        let context2 = MockNavigationContext(type: .type1)
        XCTAssertNotEqual(context1, context2)
    }

    func testThatContextOfTheSameTypeWithDifferentPayloadAreNotEqual() throws {
        let context1 = MockNavigationContext(
            type: .type1,
            payload: MockNavigationContextPayload1(
                field: "field1"
            )
        )
        let context2 = MockNavigationContext(
            type: .type1,
            payload: MockNavigationContextPayload1(
                field: "field2"
            )
        )
        XCTAssertNotEqual(context1, context2)
    }

    func testThatContextOfTheSameTypeWithTheSamePayloadAreEqual() throws {
        let context1 = MockNavigationContext(
            type: .type1,
            payload: MockNavigationContextPayload1(
                field: "field"
            )
        )
        let context2 = MockNavigationContext(
            type: .type1,
            payload: MockNavigationContextPayload1(
                field: "field"
            )
        )
        XCTAssertEqual(context1, context2)
    }

    func testThatContextOfTheSameTypeWithDifferentPayloadTypesAreNotEqual() throws {
        let context1 = MockNavigationContext(
            type: .type1,
            payload: MockNavigationContextPayload1(
                field: "field"
            )
        )
        let context2 = MockNavigationContext(
            type: .type1,
            payload: MockNavigationContextPayload2(
                field: 1
            )
        )
        XCTAssertNotEqual(context1, context2)
    }

}
