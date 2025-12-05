import XCTest
@testable import arrange_windows

final class GeometryTests: XCTestCase {
    func testRectInsetByMargin() {
        let rect = CGRect(x: 0, y: 0, width: 1920, height: 1080)
        let inset = rect.insetBy(margin: 20)

        XCTAssertEqual(inset.origin.x, 20)
        XCTAssertEqual(inset.origin.y, 20)
        XCTAssertEqual(inset.width, 1880)
        XCTAssertEqual(inset.height, 1040)
    }

    func testLeftHalf() {
        let rect = CGRect(x: 0, y: 0, width: 1920, height: 1080)
        let left = rect.leftHalf

        XCTAssertEqual(left.origin.x, 0)
        XCTAssertEqual(left.origin.y, 0)
        XCTAssertEqual(left.width, 960)
        XCTAssertEqual(left.height, 1080)
    }

    func testRightHalf() {
        let rect = CGRect(x: 0, y: 0, width: 1920, height: 1080)
        let right = rect.rightHalf

        XCTAssertEqual(right.origin.x, 960)
        XCTAssertEqual(right.origin.y, 0)
        XCTAssertEqual(right.width, 960)
        XCTAssertEqual(right.height, 1080)
    }

    func testTopHalf() {
        let rect = CGRect(x: 0, y: 0, width: 1920, height: 1080)
        let top = rect.topHalf

        XCTAssertEqual(top.origin.x, 0)
        XCTAssertEqual(top.origin.y, 0)
        XCTAssertEqual(top.width, 1920)
        XCTAssertEqual(top.height, 540)
    }

    func testBottomHalf() {
        let rect = CGRect(x: 0, y: 0, width: 1920, height: 1080)
        let bottom = rect.bottomHalf

        XCTAssertEqual(bottom.origin.x, 0)
        XCTAssertEqual(bottom.origin.y, 540)
        XCTAssertEqual(bottom.width, 1920)
        XCTAssertEqual(bottom.height, 540)
    }

    func testQuarters() {
        let rect = CGRect(x: 0, y: 0, width: 1920, height: 1080)
        let quarters = rect.quarters

        // Top-left
        XCTAssertEqual(quarters.topLeft.origin.x, 0)
        XCTAssertEqual(quarters.topLeft.origin.y, 0)
        XCTAssertEqual(quarters.topLeft.width, 960)
        XCTAssertEqual(quarters.topLeft.height, 540)

        // Top-right
        XCTAssertEqual(quarters.topRight.origin.x, 960)
        XCTAssertEqual(quarters.topRight.origin.y, 0)
        XCTAssertEqual(quarters.topRight.width, 960)
        XCTAssertEqual(quarters.topRight.height, 540)

        // Bottom-left
        XCTAssertEqual(quarters.bottomLeft.origin.x, 0)
        XCTAssertEqual(quarters.bottomLeft.origin.y, 540)
        XCTAssertEqual(quarters.bottomLeft.width, 960)
        XCTAssertEqual(quarters.bottomLeft.height, 540)

        // Bottom-right
        XCTAssertEqual(quarters.bottomRight.origin.x, 960)
        XCTAssertEqual(quarters.bottomRight.origin.y, 540)
        XCTAssertEqual(quarters.bottomRight.width, 960)
        XCTAssertEqual(quarters.bottomRight.height, 540)
    }

    func testCenteredRect() {
        let bounds = CGRect(x: 0, y: 0, width: 1920, height: 1080)
        let centered = bounds.centeredRect(size: CGSize(width: 800, height: 600))

        XCTAssertEqual(centered.origin.x, 560)
        XCTAssertEqual(centered.origin.y, 240)
        XCTAssertEqual(centered.width, 800)
        XCTAssertEqual(centered.height, 600)
    }

    func testGridDimensions_singleWindow() {
        let bounds = CGRect(x: 0, y: 0, width: 1920, height: 1080)
        let (rows, cols) = calculateGridDimensions(count: 1, bounds: bounds)

        XCTAssertEqual(rows, 1)
        XCTAssertEqual(cols, 1)
    }

    func testGridDimensions_twoWindows_landscape() {
        let bounds = CGRect(x: 0, y: 0, width: 1920, height: 1080)
        let (rows, cols) = calculateGridDimensions(count: 2, bounds: bounds)

        XCTAssertEqual(rows, 1)
        XCTAssertEqual(cols, 2)
    }

    func testGridDimensions_twoWindows_portrait() {
        let bounds = CGRect(x: 0, y: 0, width: 1080, height: 1920)
        let (rows, cols) = calculateGridDimensions(count: 2, bounds: bounds)

        XCTAssertEqual(rows, 2)
        XCTAssertEqual(cols, 1)
    }

    func testGridDimensions_fourWindows() {
        let bounds = CGRect(x: 0, y: 0, width: 1920, height: 1080)
        let (rows, cols) = calculateGridDimensions(count: 4, bounds: bounds)

        XCTAssertEqual(rows, 2)
        XCTAssertEqual(cols, 2)
    }

    func testGridDimensions_nineWindows() {
        let bounds = CGRect(x: 0, y: 0, width: 1920, height: 1080)
        let (rows, cols) = calculateGridDimensions(count: 9, bounds: bounds)

        XCTAssertEqual(rows, 3)
        XCTAssertEqual(cols, 3)
    }

    func testGridDimensions_zeroWindows() {
        let bounds = CGRect(x: 0, y: 0, width: 1920, height: 1080)
        let (rows, cols) = calculateGridDimensions(count: 0, bounds: bounds)

        XCTAssertEqual(rows, 0)
        XCTAssertEqual(cols, 0)
    }

    func testWindowSizeFromArgument_dimensions() {
        let size = WindowSize(argument: "1400x1000")

        XCTAssertNotNil(size)
        XCTAssertEqual(size?.width, 1400)
        XCTAssertEqual(size?.height, 1000)
    }

    func testWindowSizeFromArgument_square() {
        let size = WindowSize(argument: "square")

        XCTAssertNotNil(size)
        XCTAssertEqual(size?.width, 1000)
        XCTAssertEqual(size?.height, 1000)
    }

    func testWindowSizeFromArgument_squareUppercase() {
        let size = WindowSize(argument: "SQUARE")

        XCTAssertNotNil(size)
        XCTAssertEqual(size?.width, 1000)
        XCTAssertEqual(size?.height, 1000)
    }

    func testWindowSizeFromArgument_invalid() {
        XCTAssertNil(WindowSize(argument: "invalid"))
        XCTAssertNil(WindowSize(argument: "100"))
        XCTAssertNil(WindowSize(argument: "x100"))
        XCTAssertNil(WindowSize(argument: "-100x100"))
    }
}
