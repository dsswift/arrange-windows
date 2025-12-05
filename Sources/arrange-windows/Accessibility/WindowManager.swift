import ApplicationServices
import AppKit
import Foundation

/// Information about a window
struct WindowInfo {
    let axElement: AXUIElement
    let title: String
    let position: CGPoint
    let size: CGSize
    let isMinimized: Bool

    /// Unique identifier for matching windows (title + approximate position)
    var identifier: String {
        "\(title)|\(Int(position.x))|\(Int(position.y))"
    }
}

/// Manages window enumeration and manipulation using the Accessibility API
struct WindowManager {
    /// Get all windows for an application
    func getWindows(for app: NSRunningApplication) throws -> [WindowInfo] {
        let appElement = AXUIElementCreateApplication(app.processIdentifier)

        var windowsRef: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(appElement, kAXWindowsAttribute as CFString, &windowsRef)

        guard result == .success, let windows = windowsRef as? [AXUIElement] else {
            if result == .apiDisabled {
                throw ArrangeWindowsError.accessibilityPermissionDenied
            }
            return []
        }

        return windows.compactMap { window -> WindowInfo? in
            guard let title = getWindowTitle(window),
                  let position = getWindowPosition(window),
                  let size = getWindowSize(window) else {
                return nil
            }

            let isMinimized = getWindowMinimized(window)

            return WindowInfo(
                axElement: window,
                title: title,
                position: position,
                size: size,
                isMinimized: isMinimized
            )
        }
    }

    /// Set the position of a window
    func setPosition(_ position: CGPoint, for window: WindowInfo) throws {
        var point = position
        let value = AXValueCreate(.cgPoint, &point)!
        let result = AXUIElementSetAttributeValue(window.axElement, kAXPositionAttribute as CFString, value)

        if result != .success && result != .actionUnsupported {
            throw ArrangeWindowsError.windowManipulationFailed("Failed to set position for '\(window.title)'")
        }
    }

    /// Set the size of a window
    func setSize(_ size: CGSize, for window: WindowInfo) throws {
        var newSize = size
        let value = AXValueCreate(.cgSize, &newSize)!
        let result = AXUIElementSetAttributeValue(window.axElement, kAXSizeAttribute as CFString, value)

        if result != .success && result != .actionUnsupported {
            throw ArrangeWindowsError.windowManipulationFailed("Failed to set size for '\(window.title)'")
        }
    }

    /// Raise a window to the front
    func raise(window: WindowInfo) throws {
        let result = AXUIElementPerformAction(window.axElement, kAXRaiseAction as CFString)

        if result != .success && result != .actionUnsupported {
            throw ArrangeWindowsError.windowManipulationFailed("Failed to raise '\(window.title)'")
        }
    }

    /// Activate an application (bring to front)
    func activateApplication(_ app: NSRunningApplication) throws {
        let success = app.activate()
        if !success {
            throw ArrangeWindowsError.windowManipulationFailed("Failed to activate application")
        }
    }

    // MARK: - Private Helpers

    private func getWindowTitle(_ window: AXUIElement) -> String? {
        var titleRef: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(window, kAXTitleAttribute as CFString, &titleRef)

        guard result == .success, let title = titleRef as? String else {
            // Some windows don't have titles - use a placeholder
            return "Untitled Window"
        }

        return title.isEmpty ? "Untitled Window" : title
    }

    private func getWindowPosition(_ window: AXUIElement) -> CGPoint? {
        var positionRef: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(window, kAXPositionAttribute as CFString, &positionRef)

        guard result == .success, let value = positionRef else {
            return nil
        }

        var point = CGPoint.zero
        AXValueGetValue(value as! AXValue, .cgPoint, &point)
        return point
    }

    private func getWindowSize(_ window: AXUIElement) -> CGSize? {
        var sizeRef: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(window, kAXSizeAttribute as CFString, &sizeRef)

        guard result == .success, let value = sizeRef else {
            return nil
        }

        var size = CGSize.zero
        AXValueGetValue(value as! AXValue, .cgSize, &size)
        return size
    }

    private func getWindowMinimized(_ window: AXUIElement) -> Bool {
        var minimizedRef: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(window, kAXMinimizedAttribute as CFString, &minimizedRef)

        guard result == .success, let minimized = minimizedRef as? Bool else {
            return false
        }

        return minimized
    }
}
