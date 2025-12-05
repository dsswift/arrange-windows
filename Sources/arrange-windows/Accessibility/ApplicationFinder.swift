import AppKit
import Foundation

/// Finds running applications by name or bundle identifier
struct ApplicationFinder {
    /// Find an application by display name or bundle identifier
    /// - Parameter named: The application name (as shown in menu bar) or bundle ID
    /// - Returns: The running application, or nil if not found
    func findApplication(named name: String) throws -> NSRunningApplication? {
        let workspace = NSWorkspace.shared
        let runningApps = workspace.runningApplications

        // First, try exact match on localized name
        if let app = runningApps.first(where: { $0.localizedName == name }) {
            return app
        }

        // Try case-insensitive match on localized name
        if let app = runningApps.first(where: {
            $0.localizedName?.lowercased() == name.lowercased()
        }) {
            return app
        }

        // Try matching bundle identifier (exact)
        if let app = runningApps.first(where: { $0.bundleIdentifier == name }) {
            return app
        }

        // Try case-insensitive bundle identifier match
        if let app = runningApps.first(where: {
            $0.bundleIdentifier?.lowercased() == name.lowercased()
        }) {
            return app
        }

        // Try partial match on localized name (contains)
        if let app = runningApps.first(where: {
            $0.localizedName?.lowercased().contains(name.lowercased()) == true
        }) {
            return app
        }

        return nil
    }

    /// List all running applications with windows
    func listRunningApplications() -> [NSRunningApplication] {
        NSWorkspace.shared.runningApplications.filter {
            $0.activationPolicy == .regular
        }
    }
}
