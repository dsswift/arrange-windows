import Foundation

/// Global configuration settings
struct GlobalSettings: Codable {
    var windowSize: WindowSize?
    var overlap: Int?
    var margin: Int?
    var display: Int?
    var includeMinimized: Bool?
    var defaultLayout: String?

    enum CodingKeys: String, CodingKey {
        case windowSize = "window_size"
        case overlap
        case margin
        case display
        case includeMinimized = "include_minimized"
        case defaultLayout = "default_layout"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Parse window_size as string (e.g., "1280x1000" or "square")
        if let sizeString = try container.decodeIfPresent(String.self, forKey: .windowSize) {
            self.windowSize = WindowSize(argument: sizeString)
        } else {
            self.windowSize = nil
        }

        self.overlap = try container.decodeIfPresent(Int.self, forKey: .overlap)
        self.margin = try container.decodeIfPresent(Int.self, forKey: .margin)
        self.display = try container.decodeIfPresent(Int.self, forKey: .display)
        self.includeMinimized = try container.decodeIfPresent(Bool.self, forKey: .includeMinimized)
        self.defaultLayout = try container.decodeIfPresent(String.self, forKey: .defaultLayout)
    }

    init() {
        self.windowSize = nil
        self.overlap = nil
        self.margin = nil
        self.display = nil
        self.includeMinimized = nil
        self.defaultLayout = nil
    }
}

/// Per-application configuration settings
struct AppSettings: Codable {
    var windowSize: WindowSize?
    var overlap: Int?
    var margin: Int?
    var display: Int?
    var includeMinimized: Bool?
    var defaultLayout: String?

    enum CodingKeys: String, CodingKey {
        case windowSize = "window_size"
        case overlap
        case margin
        case display
        case includeMinimized = "include_minimized"
        case defaultLayout = "default_layout"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let sizeString = try container.decodeIfPresent(String.self, forKey: .windowSize) {
            self.windowSize = WindowSize(argument: sizeString)
        } else {
            self.windowSize = nil
        }

        self.overlap = try container.decodeIfPresent(Int.self, forKey: .overlap)
        self.margin = try container.decodeIfPresent(Int.self, forKey: .margin)
        self.display = try container.decodeIfPresent(Int.self, forKey: .display)
        self.includeMinimized = try container.decodeIfPresent(Bool.self, forKey: .includeMinimized)
        self.defaultLayout = try container.decodeIfPresent(String.self, forKey: .defaultLayout)
    }
}

/// Complete configuration with global and per-app settings
struct Config {
    var global: GlobalSettings
    var apps: [String: AppSettings]

    init() {
        self.global = GlobalSettings()
        self.apps = [:]
    }
}
