import XCTest
import ApplicationServices
@testable import arrange_windows

/// Mock window info for testing
func createMockWindows(count: Int) -> [WindowInfo] {
    // We can't create real AXUIElement for tests, so we create placeholders
    // The layout algorithms only use window info for placement calculations
    var windows: [WindowInfo] = []

    for i in 0..<count {
        // Create a minimal window info - we only need position/size for layout tests
        let mockElement = AXUIElementCreateSystemWide()
        windows.append(WindowInfo(
            axElement: mockElement,
            title: "Window \(i + 1)",
            position: CGPoint(x: CGFloat(i * 100), y: CGFloat(i * 100)),
            size: CGSize(width: 800, height: 600),
            isMinimized: false
        ))
    }

    return windows
}

final class LayoutEngineTests: XCTestCase {
    let displayBounds = CGRect(x: 0, y: 25, width: 1920, height: 1055) // Typical display with menu bar
    let defaultOptions = LayoutOptions(
        windowSize: WindowSize.default,
        overlap: 30,
        margin: 20
    )

    // MARK: - Cascade Layout Tests

    func testCascadeLayout_singleWindow() {
        let layout = CascadeLayout()
        let windows = createMockWindows(count: 1)

        let placements = layout.apply(windows: windows, displayBounds: displayBounds, options: defaultOptions)

        XCTAssertEqual(placements.count, 1)
        XCTAssertEqual(placements[0].targetPosition.x, 20) // margin
        XCTAssertEqual(placements[0].targetPosition.y, 45) // display.y + margin
    }

    func testCascadeLayout_multipleWindows() {
        let layout = CascadeLayout()
        let windows = createMockWindows(count: 3)

        let placements = layout.apply(windows: windows, displayBounds: displayBounds, options: defaultOptions)

        XCTAssertEqual(placements.count, 3)

        // First window should start at margin
        XCTAssertEqual(placements[0].targetPosition.x, 20)
        XCTAssertEqual(placements[0].targetPosition.y, 45)

        // With default window size (1280x1000) on a 1920x1055 display (minus margins),
        // the cascade wraps after just 1 window due to size constraints.
        // Test that subsequent windows restart from beginning
        XCTAssertEqual(placements[1].targetPosition.x, 20)
        XCTAssertEqual(placements[2].targetPosition.x, 20)
    }

    func testCascadeLayout_emptyWindows() {
        let layout = CascadeLayout()
        let windows: [WindowInfo] = []

        let placements = layout.apply(windows: windows, displayBounds: displayBounds, options: defaultOptions)

        XCTAssertTrue(placements.isEmpty)
    }

    // MARK: - Grid Layout Tests

    func testGridLayout_singleWindow() {
        let layout = GridLayout()
        let windows = createMockWindows(count: 1)

        let placements = layout.apply(windows: windows, displayBounds: displayBounds, options: defaultOptions)

        XCTAssertEqual(placements.count, 1)
        // Single window should fill most of the screen
        XCTAssertGreaterThan(placements[0].targetSize.width, 1800)
        XCTAssertGreaterThan(placements[0].targetSize.height, 900)
    }

    func testGridLayout_fourWindows() {
        let layout = GridLayout()
        let windows = createMockWindows(count: 4)

        let placements = layout.apply(windows: windows, displayBounds: displayBounds, options: defaultOptions)

        XCTAssertEqual(placements.count, 4)

        // Should be a 2x2 grid
        let positions = placements.map { $0.targetPosition }

        // Check that we have windows in different quadrants
        XCTAssertTrue(positions.contains { $0.x < 960 && $0.y < 540 }) // top-left
        XCTAssertTrue(positions.contains { $0.x >= 960 && $0.y < 540 }) // top-right
        XCTAssertTrue(positions.contains { $0.x < 960 && $0.y >= 540 }) // bottom-left
        XCTAssertTrue(positions.contains { $0.x >= 960 && $0.y >= 540 }) // bottom-right
    }

    func testGridLayout_emptyWindows() {
        let layout = GridLayout()
        let windows: [WindowInfo] = []

        let placements = layout.apply(windows: windows, displayBounds: displayBounds, options: defaultOptions)

        XCTAssertTrue(placements.isEmpty)
    }

    // MARK: - Half Screen Layout Tests

    func testLeftHalfLayout() {
        let layout = LeftHalfLayout()
        let windows = createMockWindows(count: 2)

        let placements = layout.apply(windows: windows, displayBounds: displayBounds, options: defaultOptions)

        XCTAssertEqual(placements.count, 2)

        // All windows should be in the left half
        for placement in placements {
            XCTAssertLessThan(placement.targetPosition.x + placement.targetSize.width, 960 + 50) // Allow some margin
        }

        // Windows should be stacked vertically
        XCTAssertLessThan(placements[0].targetPosition.y, placements[1].targetPosition.y)
    }

    func testRightHalfLayout() {
        let layout = RightHalfLayout()
        let windows = createMockWindows(count: 2)

        let placements = layout.apply(windows: windows, displayBounds: displayBounds, options: defaultOptions)

        XCTAssertEqual(placements.count, 2)

        // All windows should be in the right half
        for placement in placements {
            XCTAssertGreaterThan(placement.targetPosition.x, 900) // Allow some margin
        }
    }

    func testTopHalfLayout() {
        let layout = TopHalfLayout()
        let windows = createMockWindows(count: 2)

        let placements = layout.apply(windows: windows, displayBounds: displayBounds, options: defaultOptions)

        XCTAssertEqual(placements.count, 2)

        // All windows should be in the top half
        for placement in placements {
            XCTAssertLessThan(placement.targetPosition.y + placement.targetSize.height, 600)
        }
    }

    func testBottomHalfLayout() {
        let layout = BottomHalfLayout()
        let windows = createMockWindows(count: 2)

        let placements = layout.apply(windows: windows, displayBounds: displayBounds, options: defaultOptions)

        XCTAssertEqual(placements.count, 2)

        // All windows should be in the bottom half
        for placement in placements {
            XCTAssertGreaterThan(placement.targetPosition.y, 500)
        }
    }

    // MARK: - Quarters Layout Tests

    func testQuartersLayout_fourWindows() {
        let layout = QuartersLayout()
        let windows = createMockWindows(count: 4)

        let placements = layout.apply(windows: windows, displayBounds: displayBounds, options: defaultOptions)

        XCTAssertEqual(placements.count, 4)

        // Each window should be roughly quarter-screen size
        for placement in placements {
            XCTAssertLessThan(placement.targetSize.width, 1000)
            XCTAssertLessThan(placement.targetSize.height, 600)
        }
    }

    func testQuartersLayout_moreWindowsCascadeInCenter() {
        let layout = QuartersLayout()
        let windows = createMockWindows(count: 6)

        let placements = layout.apply(windows: windows, displayBounds: displayBounds, options: defaultOptions)

        XCTAssertEqual(placements.count, 6)

        // First 4 should be in corners
        // Last 2 should be in center area (cascaded)
        let centerX = displayBounds.midX
        let centerY = displayBounds.midY

        // The overflow windows should be near center
        let overflowPlacements = Array(placements.suffix(2))
        for placement in overflowPlacements {
            let windowCenterX = placement.targetPosition.x + placement.targetSize.width / 2
            let windowCenterY = placement.targetPosition.y + placement.targetSize.height / 2

            // Should be roughly in the center region
            XCTAssertGreaterThan(windowCenterX, centerX - 600)
            XCTAssertLessThan(windowCenterX, centerX + 600)
            XCTAssertGreaterThan(windowCenterY, centerY - 400)
            XCTAssertLessThan(windowCenterY, centerY + 400)
        }
    }

    func testQuartersLayout_emptyWindows() {
        let layout = QuartersLayout()
        let windows: [WindowInfo] = []

        let placements = layout.apply(windows: windows, displayBounds: displayBounds, options: defaultOptions)

        XCTAssertTrue(placements.isEmpty)
    }

    // MARK: - Layout Engine Helpers

    func testConstrainToBounds() {
        let layout = CascadeLayout()
        let bounds = CGRect(x: 0, y: 0, width: 1920, height: 1080)
        let size = CGSize(width: 800, height: 600)

        // Test position within bounds
        let normal = layout.constrainToBounds(CGPoint(x: 100, y: 100), size: size, bounds: bounds)
        XCTAssertEqual(normal.x, 100)
        XCTAssertEqual(normal.y, 100)

        // Test position past right edge
        let pastRight = layout.constrainToBounds(CGPoint(x: 1500, y: 100), size: size, bounds: bounds)
        XCTAssertEqual(pastRight.x, 1120) // 1920 - 800

        // Test position past bottom edge
        let pastBottom = layout.constrainToBounds(CGPoint(x: 100, y: 800), size: size, bounds: bounds)
        XCTAssertEqual(pastBottom.y, 480) // 1080 - 600

        // Test position past left edge
        let pastLeft = layout.constrainToBounds(CGPoint(x: -100, y: 100), size: size, bounds: bounds)
        XCTAssertEqual(pastLeft.x, 0)

        // Test position past top edge
        let pastTop = layout.constrainToBounds(CGPoint(x: 100, y: -100), size: size, bounds: bounds)
        XCTAssertEqual(pastTop.y, 0)
    }

    func testFitSizeToBounds() {
        let layout = CascadeLayout()
        let bounds = CGRect(x: 0, y: 0, width: 1920, height: 1080)

        // Test size within bounds
        let normal = layout.fitSizeToBounds(CGSize(width: 800, height: 600), bounds: bounds)
        XCTAssertEqual(normal.width, 800)
        XCTAssertEqual(normal.height, 600)

        // Test size larger than bounds
        let tooLarge = layout.fitSizeToBounds(CGSize(width: 2500, height: 1500), bounds: bounds)
        XCTAssertEqual(tooLarge.width, 1920)
        XCTAssertEqual(tooLarge.height, 1080)
    }
}
