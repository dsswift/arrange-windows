import Foundation

/// Errors that can occur during window arrangement
enum ArrangeWindowsError: LocalizedError {
    case accessibilityPermissionDenied
    case applicationNotFound(String)
    case noWindowsFound(String)
    case displayNotFound(Int, String)
    case noSavedState(String)
    case windowManipulationFailed(String)
    case configParsingFailed(String)
    case stateLoadFailed(String)
    case stateSaveFailed(String)

    var errorDescription: String? {
        switch self {
        case .accessibilityPermissionDenied:
            return """
                Accessibility permission required.

                To enable:
                1. Open System Settings → Privacy & Security → Accessibility
                2. Click the '+' button and add this application
                3. Ensure the toggle is enabled

                Or run: open "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
                """

        case .applicationNotFound(let name):
            return "No application named '\(name)' is currently running.\n\nHint: Use the exact name shown in the menu bar or Activity Monitor, or try the bundle identifier (e.g., com.apple.Safari)."

        case .noWindowsFound(let name):
            return "No windows found for '\(name)'.\n\nThe application is running but has no visible windows. Use --include-minimized to include minimized windows."

        case .displayNotFound(let index, let available):
            return "Display \(index) not found.\n\nAvailable displays: \(available)"

        case .noSavedState(let name):
            return "No saved state found for '\(name)'.\n\nRun a layout command first to save window positions, then use --reset to restore them."

        case .windowManipulationFailed(let details):
            return "Failed to manipulate window: \(details)"

        case .configParsingFailed(let details):
            return "Failed to parse configuration file: \(details)"

        case .stateLoadFailed(let details):
            return "Failed to load saved state: \(details)"

        case .stateSaveFailed(let details):
            return "Failed to save window state: \(details)"
        }
    }
}
