import CoreGraphics
import Foundation

/// Cascade layout: windows stacked diagonally from top-left
struct CascadeLayout: LayoutEngine {
    func apply(windows: [WindowInfo], displayBounds: CGRect, options: LayoutOptions) -> [WindowPlacement] {
        guard !windows.isEmpty else { return [] }

        let overlap = CGFloat(options.overlap)
        let workArea = displayBounds.insetBy(margin: options.margin)

        // Fit window size to available area
        let windowSize = fitSizeToBounds(options.cgSize, bounds: workArea)

        var placements: [WindowPlacement] = []
        var currentX = workArea.minX
        var currentY = workArea.minY
        var cascadeCount = 0

        // Calculate how many windows can cascade before we need to wrap
        let maxCascadeX = workArea.maxX - windowSize.width
        let maxCascadeY = workArea.maxY - windowSize.height
        let maxCascades = min(
            Int((maxCascadeX - workArea.minX) / overlap) + 1,
            Int((maxCascadeY - workArea.minY) / overlap) + 1
        )

        for window in windows {
            let position = CGPoint(x: currentX, y: currentY)

            placements.append(WindowPlacement(
                window: window,
                targetPosition: position,
                targetSize: windowSize
            ))

            cascadeCount += 1

            // Move to next cascade position
            currentX += overlap
            currentY += overlap

            // Wrap if we've reached the edge or max cascades
            if cascadeCount >= maxCascades || currentX > maxCascadeX || currentY > maxCascadeY {
                cascadeCount = 0
                currentX = workArea.minX
                currentY = workArea.minY
            }
        }

        return placements
    }
}
