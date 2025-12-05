import Foundation
import TOMLDecoder

/// Raw TOML configuration structure
private struct RawConfig: Decodable {
    var global: GlobalSettings?
    var apps: [String: AppSettings]?

    enum CodingKeys: String, CodingKey {
        case global
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.global = try container.decodeIfPresent(GlobalSettings.self, forKey: .global)

        // Decode remaining keys as app settings
        let allContainer = try decoder.container(keyedBy: DynamicKey.self)
        var apps: [String: AppSettings] = [:]

        for key in allContainer.allKeys {
            if key.stringValue != "global" {
                if let appSettings = try? allContainer.decode(AppSettings.self, forKey: key) {
                    apps[key.stringValue] = appSettings
                }
            }
        }

        self.apps = apps.isEmpty ? nil : apps
    }
}

/// Dynamic coding key for arbitrary app names
private struct DynamicKey: CodingKey {
    var stringValue: String
    var intValue: Int? { nil }

    init?(stringValue: String) {
        self.stringValue = stringValue
    }

    init?(intValue: Int) {
        return nil
    }
}

/// Loads and parses configuration from TOML file
struct ConfigLoader {
    private let configPath: URL

    init() {
        let home = FileManager.default.homeDirectoryForCurrentUser
        self.configPath = home
            .appendingPathComponent(".config", isDirectory: true)
            .appendingPathComponent("arrange-windows", isDirectory: true)
            .appendingPathComponent("config.toml")
    }

    /// Load configuration from the config file
    /// - Returns: The parsed configuration, or empty defaults if file doesn't exist
    func loadConfig() throws -> Config {
        guard FileManager.default.fileExists(atPath: configPath.path) else {
            return Config()
        }

        do {
            let contents = try String(contentsOf: configPath, encoding: .utf8)
            let decoder = TOMLDecoder()
            let rawConfig = try decoder.decode(RawConfig.self, from: contents)

            var config = Config()
            config.global = rawConfig.global ?? GlobalSettings()
            config.apps = rawConfig.apps ?? [:]

            return config
        } catch {
            throw ArrangeWindowsError.configParsingFailed(error.localizedDescription)
        }
    }

    /// Get the path to the config file
    var path: String {
        configPath.path
    }
}
