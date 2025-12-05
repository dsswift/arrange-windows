import CoreGraphics
import Foundation

/// Grid layout: windows arranged in an auto-calculated grid
struct GridLayout: LayoutEngine {
    func apply(windows: [WindowInfo], displayBounds: CGRect, options: LayoutOptions) -> [WindowPlacement] {
        guard !windows.isEmpty else { return [] }

        let workArea = displayBounds.insetBy(margin: options.margin)

        // Calculate grid dimensions
        let (rows, cols) = calculateGridDimensions(count: windows.count, bounds: workArea)

        // Calculate cell size
        let cellWidth = workArea.width / CGFloat(cols)
        let cellHeight = workArea.height / CGFloat(rows)

        // Window size is the cell size minus a small gap
        let gap: CGFloat = 4
        let windowWidth = cellWidth - gap
        let windowHeight = cellHeight - gap

        var placements: [WindowPlacement] = []

        for (index, window) in windows.enumerated() {
            let row = index / cols
            let col = index % cols

            let x = workArea.minX + CGFloat(col) * cellWidth + gap / 2
            let y = workArea.minY + CGFloat(row) * cellHeight + gap / 2

            placements.append(WindowPlacement(
                window: window,
                targetPosition: CGPoint(x: x, y: y),
                targetSize: CGSize(width: windowWidth, height: windowHeight)
            ))
        }

        return placements
    }
}
