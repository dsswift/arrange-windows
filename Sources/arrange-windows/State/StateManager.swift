import Foundation

/// Saved state for a single window
struct WindowState: Codable {
    let title: String
    let position: CGPointCodable
    let size: CGSizeCodable
}

/// Codable wrapper for CGPoint
struct CGPointCodable: Codable {
    let x: CGFloat
    let y: CGFloat

    init(_ point: CGPoint) {
        self.x = point.x
        self.y = point.y
    }

    var cgPoint: CGPoint {
        CGPoint(x: x, y: y)
    }
}

/// Codable wrapper for CGSize
struct CGSizeCodable: Codable {
    let width: CGFloat
    let height: CGFloat

    init(_ size: CGSize) {
        self.width = size.width
        self.height = size.height
    }

    var cgSize: CGSize {
        CGSize(width: width, height: height)
    }
}

/// Saved state for an application's windows
struct AppState: Codable {
    let appName: String
    let timestamp: Date
    let windows: [WindowState]
}

/// All saved states
struct SavedStates: Codable {
    var states: [String: AppState]

    init() {
        self.states = [:]
    }
}

/// Manages saving and restoring window states
struct StateManager {
    private let stateFileURL: URL

    init() {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appFolder = appSupport.appendingPathComponent("arrange-windows", isDirectory: true)
        self.stateFileURL = appFolder.appendingPathComponent("state.json")
    }

    /// Save the current state of windows for an application
    func saveState(windows: [WindowInfo], appName: String) throws {
        var savedStates = loadAllStates()

        let windowStates = windows.map { window in
            WindowState(
                title: window.title,
                position: CGPointCodable(window.position),
                size: CGSizeCodable(window.size)
            )
        }

        savedStates.states[appName.lowercased()] = AppState(
            appName: appName,
            timestamp: Date(),
            windows: windowStates
        )

        try saveAllStates(savedStates)
    }

    /// Load the saved state for an application
    func loadState(for appName: String) throws -> AppState? {
        let savedStates = loadAllStates()
        return savedStates.states[appName.lowercased()]
    }

    /// Apply a saved state to windows
    func applyState(_ state: AppState, to windows: [WindowInfo], using windowManager: WindowManager) throws {
        // Match windows by title
        for savedWindow in state.windows {
            if let window = windows.first(where: { $0.title == savedWindow.title }) {
                try windowManager.setPosition(savedWindow.position.cgPoint, for: window)
                try windowManager.setSize(savedWindow.size.cgSize, for: window)
            }
        }
    }

    // MARK: - Private

    private func loadAllStates() -> SavedStates {
        guard FileManager.default.fileExists(atPath: stateFileURL.path) else {
            return SavedStates()
        }

        do {
            let data = try Data(contentsOf: stateFileURL)
            return try JSONDecoder().decode(SavedStates.self, from: data)
        } catch {
            return SavedStates()
        }
    }

    private func saveAllStates(_ states: SavedStates) throws {
        // Ensure directory exists
        let directory = stateFileURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(states)
        try data.write(to: stateFileURL)
    }
}
