import CoreGraphics
import Foundation

/// Left half layout: windows tiled vertically in the left half of the screen
struct LeftHalfLayout: LayoutEngine {
    func apply(windows: [WindowInfo], displayBounds: CGRect, options: LayoutOptions) -> [WindowPlacement] {
        guard !windows.isEmpty else { return [] }

        let workArea = displayBounds.insetBy(margin: options.margin).leftHalf
        return tileVertically(windows: windows, in: workArea)
    }
}

/// Right half layout: windows tiled vertically in the right half of the screen
struct RightHalfLayout: LayoutEngine {
    func apply(windows: [WindowInfo], displayBounds: CGRect, options: LayoutOptions) -> [WindowPlacement] {
        guard !windows.isEmpty else { return [] }

        let workArea = displayBounds.insetBy(margin: options.margin).rightHalf
        return tileVertically(windows: windows, in: workArea)
    }
}

/// Top half layout: windows tiled horizontally in the top half of the screen
struct TopHalfLayout: LayoutEngine {
    func apply(windows: [WindowInfo], displayBounds: CGRect, options: LayoutOptions) -> [WindowPlacement] {
        guard !windows.isEmpty else { return [] }

        let workArea = displayBounds.insetBy(margin: options.margin).topHalf
        return tileHorizontally(windows: windows, in: workArea)
    }
}

/// Bottom half layout: windows tiled horizontally in the bottom half of the screen
struct BottomHalfLayout: LayoutEngine {
    func apply(windows: [WindowInfo], displayBounds: CGRect, options: LayoutOptions) -> [WindowPlacement] {
        guard !windows.isEmpty else { return [] }

        let workArea = displayBounds.insetBy(margin: options.margin).bottomHalf
        return tileHorizontally(windows: windows, in: workArea)
    }
}

// MARK: - Helper Functions

/// Tile windows vertically within a given area
func tileVertically(windows: [WindowInfo], in bounds: CGRect) -> [WindowPlacement] {
    guard !windows.isEmpty else { return [] }

    let gap: CGFloat = 4
    let windowHeight = (bounds.height - gap * CGFloat(windows.count - 1)) / CGFloat(windows.count)
    let windowWidth = bounds.width

    var placements: [WindowPlacement] = []

    for (index, window) in windows.enumerated() {
        let y = bounds.minY + CGFloat(index) * (windowHeight + gap)

        placements.append(WindowPlacement(
            window: window,
            targetPosition: CGPoint(x: bounds.minX, y: y),
            targetSize: CGSize(width: windowWidth, height: windowHeight)
        ))
    }

    return placements
}

/// Tile windows horizontally within a given area
func tileHorizontally(windows: [WindowInfo], in bounds: CGRect) -> [WindowPlacement] {
    guard !windows.isEmpty else { return [] }

    let gap: CGFloat = 4
    let windowWidth = (bounds.width - gap * CGFloat(windows.count - 1)) / CGFloat(windows.count)
    let windowHeight = bounds.height

    var placements: [WindowPlacement] = []

    for (index, window) in windows.enumerated() {
        let x = bounds.minX + CGFloat(index) * (windowWidth + gap)

        placements.append(WindowPlacement(
            window: window,
            targetPosition: CGPoint(x: x, y: bounds.minY),
            targetSize: CGSize(width: windowWidth, height: windowHeight)
        ))
    }

    return placements
}
