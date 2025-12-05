import CoreGraphics
import Foundation

/// Options for layout algorithms
struct LayoutOptions {
    let windowSize: WindowSize
    let overlap: Int
    let margin: Int

    var cgSize: CGSize {
        CGSize(windowSize)
    }
}

/// A placement for a single window
struct WindowPlacement {
    let window: WindowInfo
    let targetPosition: CGPoint
    let targetSize: CGSize
}

/// Protocol for layout algorithms
protocol LayoutEngine {
    /// Apply the layout to a set of windows
    /// - Parameters:
    ///   - windows: The windows to arrange
    ///   - displayBounds: The visible bounds of the target display
    ///   - options: Layout options (window size, overlap, margin)
    /// - Returns: An array of window placements
    func apply(windows: [WindowInfo], displayBounds: CGRect, options: LayoutOptions) -> [WindowPlacement]
}

/// Base layout with common functionality
extension LayoutEngine {
    /// Constrain a window position to keep it within display bounds
    func constrainToBounds(_ position: CGPoint, size: CGSize, bounds: CGRect) -> CGPoint {
        var x = position.x
        var y = position.y

        // Keep window within horizontal bounds
        if x < bounds.minX {
            x = bounds.minX
        } else if x + size.width > bounds.maxX {
            x = bounds.maxX - size.width
        }

        // Keep window within vertical bounds
        if y < bounds.minY {
            y = bounds.minY
        } else if y + size.height > bounds.maxY {
            y = bounds.maxY - size.height
        }

        return CGPoint(x: x, y: y)
    }

    /// Fit a window size to available bounds
    func fitSizeToBounds(_ size: CGSize, bounds: CGRect) -> CGSize {
        var width = size.width
        var height = size.height

        if width > bounds.width {
            width = bounds.width
        }

        if height > bounds.height {
            height = bounds.height
        }

        return CGSize(width: width, height: height)
    }
}
