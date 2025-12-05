import CoreGraphics
import Foundation

/// Helper extensions for geometry calculations
extension CGRect {
    /// Returns a rect inset by the given margin on all sides
    func insetBy(margin: Int) -> CGRect {
        let m = CGFloat(margin)
        return insetBy(dx: m, dy: m)
    }

    /// Returns the left half of this rect
    var leftHalf: CGRect {
        CGRect(x: minX, y: minY, width: width / 2, height: height)
    }

    /// Returns the right half of this rect
    var rightHalf: CGRect {
        CGRect(x: midX, y: minY, width: width / 2, height: height)
    }

    /// Returns the top half of this rect
    var topHalf: CGRect {
        CGRect(x: minX, y: minY, width: width, height: height / 2)
    }

    /// Returns the bottom half of this rect
    var bottomHalf: CGRect {
        CGRect(x: minX, y: midY, width: width, height: height / 2)
    }

    /// Returns the four quarter rects (top-left, top-right, bottom-left, bottom-right)
    var quarters: (topLeft: CGRect, topRight: CGRect, bottomLeft: CGRect, bottomRight: CGRect) {
        let halfWidth = width / 2
        let halfHeight = height / 2

        return (
            topLeft: CGRect(x: minX, y: minY, width: halfWidth, height: halfHeight),
            topRight: CGRect(x: midX, y: minY, width: halfWidth, height: halfHeight),
            bottomLeft: CGRect(x: minX, y: midY, width: halfWidth, height: halfHeight),
            bottomRight: CGRect(x: midX, y: midY, width: halfWidth, height: halfHeight)
        )
    }

    /// Returns a centered rect for the given window size
    var center: CGPoint {
        CGPoint(x: midX, y: midY)
    }

    /// Create a rect centered in this rect with the given size
    func centeredRect(size: CGSize) -> CGRect {
        CGRect(
            x: midX - size.width / 2,
            y: midY - size.height / 2,
            width: size.width,
            height: size.height
        )
    }
}

extension CGSize {
    /// Create a CGSize from a WindowSize
    init(_ windowSize: WindowSize) {
        self.init(width: windowSize.width, height: windowSize.height)
    }
}

/// Calculate optimal grid dimensions for a given count of items
func calculateGridDimensions(count: Int, bounds: CGRect) -> (rows: Int, cols: Int) {
    guard count > 0 else { return (0, 0) }

    if count == 1 { return (1, 1) }
    if count == 2 { return bounds.width >= bounds.height ? (1, 2) : (2, 1) }

    // Calculate aspect ratio of the bounds
    let aspectRatio = bounds.width / bounds.height

    // Start with square-ish grid and adjust based on aspect ratio
    var bestRows = 1
    var bestCols = count

    for rows in 1...count {
        let cols = Int(ceil(Double(count) / Double(rows)))
        let cellWidth = bounds.width / CGFloat(cols)
        let cellHeight = bounds.height / CGFloat(rows)
        let cellAspect = cellWidth / cellHeight

        // Prefer cells that match screen aspect ratio
        let currentDiff = abs(cellAspect - aspectRatio)
        let bestCellWidth = bounds.width / CGFloat(bestCols)
        let bestCellHeight = bounds.height / CGFloat(bestRows)
        let bestDiff = abs((bestCellWidth / bestCellHeight) - aspectRatio)

        // Also penalize too many empty cells
        let emptyCells = (rows * cols) - count
        let bestEmptyCells = (bestRows * bestCols) - count

        if currentDiff < bestDiff || (currentDiff == bestDiff && emptyCells < bestEmptyCells) {
            bestRows = rows
            bestCols = cols
        }
    }

    return (bestRows, bestCols)
}
