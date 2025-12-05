import ApplicationServices
import AppKit
import Foundation

/// Manages macOS Accessibility API permissions
struct AccessibilityManager {
    /// Check if the application has accessibility permissions
    /// - Returns: true if accessibility is enabled, false otherwise
    func checkPermission() -> Bool {
        return AXIsProcessTrusted()
    }

    /// Check permission and prompt for access if not granted
    /// - Returns: true if permission is granted
    func checkPermissionWithPrompt() -> Bool {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        return AXIsProcessTrustedWithOptions(options)
    }

    /// Open System Settings to the Accessibility privacy pane
    func openAccessibilitySettings() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
        NSWorkspace.shared.open(url)
    }
}
