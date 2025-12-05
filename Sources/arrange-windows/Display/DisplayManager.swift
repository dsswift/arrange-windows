import AppKit
import CoreGraphics
import Foundation

/// Information about a display
struct DisplayInfo {
    let id: CGDirectDisplayID
    let index: Int
    let bounds: CGRect
    let visibleBounds: CGRect // Excludes menu bar and dock

    var isMain: Bool {
        CGDisplayIsMain(id) != 0
    }
}

/// Manages display enumeration and information
struct DisplayManager {
    /// Get all active displays
    func getDisplays() -> [DisplayInfo] {
        var displayCount: UInt32 = 0
        CGGetActiveDisplayList(0, nil, &displayCount)

        guard displayCount > 0 else { return [] }

        var displayIDs = [CGDirectDisplayID](repeating: 0, count: Int(displayCount))
        CGGetActiveDisplayList(displayCount, &displayIDs, &displayCount)

        return displayIDs.enumerated().map { index, displayID in
            createDisplayInfo(for: displayID, index: index + 1)
        }
    }

    /// Get the main (primary) display
    func getMainDisplay() -> DisplayInfo {
        let mainDisplayID = CGMainDisplayID()
        return createDisplayInfo(for: mainDisplayID, index: 1)
    }

    /// Get a display by its index (1-based)
    func getDisplay(byIndex index: Int) -> DisplayInfo? {
        let displays = getDisplays()
        guard index >= 1 && index <= displays.count else { return nil }
        return displays[index - 1]
    }

    // MARK: - Private

    private func createDisplayInfo(for displayID: CGDirectDisplayID, index: Int) -> DisplayInfo {
        let bounds = CGDisplayBounds(displayID)
        let visibleBounds = calculateVisibleBounds(for: displayID, fullBounds: bounds)

        return DisplayInfo(
            id: displayID,
            index: index,
            bounds: bounds,
            visibleBounds: visibleBounds
        )
    }

    private func calculateVisibleBounds(for displayID: CGDirectDisplayID, fullBounds: CGRect) -> CGRect {
        // Get the screen that matches this display
        guard let screen = NSScreen.screens.first(where: { screen in
            guard let screenNumber = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber else {
                return false
            }
            return CGDirectDisplayID(screenNumber.uint32Value) == displayID
        }) else {
            return fullBounds
        }

        // visibleFrame excludes the dock and menu bar
        return screen.visibleFrame
    }
}
