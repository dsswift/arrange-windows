import XCTest
@testable import arrange_windows

final class ArgumentParserTests: XCTestCase {
    func testWindowSizeParsing_dimensions() {
        let size = WindowSize(argument: "1400x1000")

        XCTAssertNotNil(size)
        XCTAssertEqual(size?.width, 1400)
        XCTAssertEqual(size?.height, 1000)
    }

    func testWindowSizeParsing_square() {
        let size = WindowSize(argument: "square")

        XCTAssertNotNil(size)
        XCTAssertEqual(size, WindowSize.square)
    }

    func testWindowSizeParsing_invalid() {
        XCTAssertNil(WindowSize(argument: "invalid"))
        XCTAssertNil(WindowSize(argument: "100"))
        XCTAssertNil(WindowSize(argument: "100x"))
        XCTAssertNil(WindowSize(argument: "x100"))
        XCTAssertNil(WindowSize(argument: "0x0"))
        XCTAssertNil(WindowSize(argument: "-100x100"))
        XCTAssertNil(WindowSize(argument: "100x-100"))
    }

    func testWindowSizeEquality() {
        let size1 = WindowSize(argument: "1400x1000")!
        let size2 = WindowSize(argument: "1400x1000")!
        let size3 = WindowSize(argument: "1000x1000")!

        XCTAssertEqual(size1, size2)
        XCTAssertNotEqual(size1, size3)
    }

    func testWindowSizeDefaultValue() {
        XCTAssertEqual(WindowSize.default.width, 1280)
        XCTAssertEqual(WindowSize.default.height, 1000)
    }

    func testWindowSizeSquareValue() {
        XCTAssertEqual(WindowSize.square.width, 1000)
        XCTAssertEqual(WindowSize.square.height, 1000)
    }

    func testLayoutModeRawValues() {
        XCTAssertEqual(LayoutMode.cascade.rawValue, "cascade")
        XCTAssertEqual(LayoutMode.grid.rawValue, "grid")
        XCTAssertEqual(LayoutMode.leftHalf.rawValue, "left-half")
        XCTAssertEqual(LayoutMode.rightHalf.rawValue, "right-half")
        XCTAssertEqual(LayoutMode.topHalf.rawValue, "top-half")
        XCTAssertEqual(LayoutMode.bottomHalf.rawValue, "bottom-half")
        XCTAssertEqual(LayoutMode.quarters.rawValue, "quarters")
        XCTAssertEqual(LayoutMode.reset.rawValue, "reset")
    }

    func testLayoutModeFromString() {
        XCTAssertEqual(LayoutMode(rawValue: "cascade"), .cascade)
        XCTAssertEqual(LayoutMode(rawValue: "grid"), .grid)
        XCTAssertEqual(LayoutMode(rawValue: "left-half"), .leftHalf)
        XCTAssertEqual(LayoutMode(rawValue: "right-half"), .rightHalf)
        XCTAssertEqual(LayoutMode(rawValue: "top-half"), .topHalf)
        XCTAssertEqual(LayoutMode(rawValue: "bottom-half"), .bottomHalf)
        XCTAssertEqual(LayoutMode(rawValue: "quarters"), .quarters)
        XCTAssertEqual(LayoutMode(rawValue: "reset"), .reset)
        XCTAssertNil(LayoutMode(rawValue: "invalid"))
    }

    func testLayoutModeCaseIterable() {
        XCTAssertEqual(LayoutMode.allCases.count, 8)
        XCTAssertTrue(LayoutMode.allCases.contains(.cascade))
        XCTAssertTrue(LayoutMode.allCases.contains(.grid))
        XCTAssertTrue(LayoutMode.allCases.contains(.leftHalf))
        XCTAssertTrue(LayoutMode.allCases.contains(.rightHalf))
        XCTAssertTrue(LayoutMode.allCases.contains(.topHalf))
        XCTAssertTrue(LayoutMode.allCases.contains(.bottomHalf))
        XCTAssertTrue(LayoutMode.allCases.contains(.quarters))
        XCTAssertTrue(LayoutMode.allCases.contains(.reset))
    }
}
