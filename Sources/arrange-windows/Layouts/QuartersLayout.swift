import CoreGraphics
import Foundation

/// Quarters layout: windows in corners with cascade overflow in center
struct QuartersLayout: LayoutEngine {
    func apply(windows: [WindowInfo], displayBounds: CGRect, options: LayoutOptions) -> [WindowPlacement] {
        guard !windows.isEmpty else { return [] }

        let workArea = displayBounds.insetBy(margin: options.margin)
        let quarters = workArea.quarters

        let gap: CGFloat = 4
        var placements: [WindowPlacement] = []

        // Place first 4 windows in corners
        let cornerBounds = [quarters.topLeft, quarters.topRight, quarters.bottomLeft, quarters.bottomRight]

        for (index, window) in windows.prefix(4).enumerated() {
            let bounds = cornerBounds[index]

            placements.append(WindowPlacement(
                window: window,
                targetPosition: CGPoint(x: bounds.minX + gap / 2, y: bounds.minY + gap / 2),
                targetSize: CGSize(width: bounds.width - gap, height: bounds.height - gap)
            ))
        }

        // Cascade any remaining windows in the center
        if windows.count > 4 {
            let overflowWindows = Array(windows.dropFirst(4))
            let centerArea = workArea.insetBy(dx: workArea.width * 0.15, dy: workArea.height * 0.15)

            let overlap = CGFloat(options.overlap)
            let windowSize = fitSizeToBounds(options.cgSize, bounds: centerArea)

            var currentX = centerArea.minX
            var currentY = centerArea.minY

            for window in overflowWindows {
                placements.append(WindowPlacement(
                    window: window,
                    targetPosition: CGPoint(x: currentX, y: currentY),
                    targetSize: windowSize
                ))

                currentX += overlap
                currentY += overlap

                // Wrap if needed
                if currentX + windowSize.width > centerArea.maxX || currentY + windowSize.height > centerArea.maxY {
                    currentX = centerArea.minX
                    currentY = centerArea.minY
                }
            }
        }

        return placements
    }
}
