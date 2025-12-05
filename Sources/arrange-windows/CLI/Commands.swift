import ArgumentParser
import Foundation

/// Available layout modes for window arrangement
enum LayoutMode: String, CaseIterable, ExpressibleByArgument {
    case cascade
    case grid
    case leftHalf = "left-half"
    case rightHalf = "right-half"
    case topHalf = "top-half"
    case bottomHalf = "bottom-half"
    case quarters
    case reset

    var defaultValueDescription: String {
        rawValue
    }
}

/// Window size specification
struct WindowSize: Equatable, Codable {
    let width: Int
    let height: Int

    static let `default` = WindowSize(width: 1280, height: 1000)
    static let square = WindowSize(width: 1000, height: 1000)

    init(width: Int, height: Int) {
        self.width = width
        self.height = height
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringValue = try container.decode(String.self)
        guard let parsed = WindowSize(argument: stringValue) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid window size format")
        }
        self.width = parsed.width
        self.height = parsed.height
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode("\(width)x\(height)")
    }
}

extension WindowSize: ExpressibleByArgument {
    init?(argument: String) {
        if argument.lowercased() == "square" {
            self = .square
            return
        }

        let parts = argument.lowercased().split(separator: "x")
        guard parts.count == 2,
              let width = Int(parts[0]),
              let height = Int(parts[1]),
              width > 0,
              height > 0 else {
            return nil
        }

        self.width = width
        self.height = height
    }

    var defaultValueDescription: String {
        "\(width)x\(height)"
    }
}

/// The main command for arranging windows
@main
struct ArrangeWindows: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "arrange-windows",
        abstract: "Arrange windows of a specific application into organized layouts",
        discussion: """
            A fast, native macOS tool that arranges windows belonging to a specific application
            using one of several built-in layouts. Uses the Accessibility API for reliable
            window manipulation across all macOS applications.

            Examples:
              arrange-windows Finder --cascade
              arrange-windows Safari --grid
              arrange-windows "Visual Studio Code" --left-half
              arrange-windows com.apple.Terminal --quarters
            """,
        version: "1.0.0"
    )

    // MARK: - Arguments

    @Argument(help: "Application name (as shown in menu bar) or bundle identifier")
    var appName: String

    // MARK: - Layout Options (mutually exclusive)

    @Flag(name: .long, help: "Cascade windows from top-left with offset stacking (default)")
    var cascade: Bool = false

    @Flag(name: .long, help: "Arrange windows in an auto-calculated grid")
    var grid: Bool = false

    @Flag(name: .long, help: "Tile windows in the left half of the screen")
    var leftHalf: Bool = false

    @Flag(name: .long, help: "Tile windows in the right half of the screen")
    var rightHalf: Bool = false

    @Flag(name: .long, help: "Tile windows in the top half of the screen")
    var topHalf: Bool = false

    @Flag(name: .long, help: "Tile windows in the bottom half of the screen")
    var bottomHalf: Bool = false

    @Flag(name: .long, help: "Place windows in screen corners with center cascade for overflow")
    var quarters: Bool = false

    @Flag(name: .long, help: "Restore windows to their positions before the last arrangement")
    var reset: Bool = false

    // MARK: - Layout Configuration Options

    @Option(name: .long, help: "Window size as WxH (e.g., 1400x1000) or 'square'")
    var size: WindowSize?

    @Option(name: .long, help: "Pixel overlap between cascaded windows (default: 30)")
    var overlap: Int?

    @Option(name: .long, help: "Margin from screen edges in pixels (default: 20)")
    var margin: Int?

    @Option(name: .long, help: "Target display number (1 = primary, 2 = secondary, etc.)")
    var display: Int?

    @Flag(name: .long, help: "Include minimized windows in arrangement")
    var includeMinimized: Bool = false

    @Flag(name: .long, help: "Print planned actions without making changes")
    var dryRun: Bool = false

    @Flag(name: .long, help: "Show verbose output")
    var verbose: Bool = false

    // MARK: - Computed Properties

    /// Determine which layout mode was selected
    var selectedLayout: LayoutMode {
        if grid { return .grid }
        if leftHalf { return .leftHalf }
        if rightHalf { return .rightHalf }
        if topHalf { return .topHalf }
        if bottomHalf { return .bottomHalf }
        if quarters { return .quarters }
        if reset { return .reset }
        return .cascade // default
    }

    // MARK: - Validation

    func validate() throws {
        // Check for mutually exclusive layout flags
        let layoutFlags = [cascade, grid, leftHalf, rightHalf, topHalf, bottomHalf, quarters, reset]
        let selectedCount = layoutFlags.filter { $0 }.count

        if selectedCount > 1 {
            throw ValidationError("Only one layout option can be specified at a time")
        }

        // Validate overlap
        if let overlap = overlap, overlap < 0 {
            throw ValidationError("Overlap must be a non-negative number")
        }

        // Validate margin
        if let margin = margin, margin < 0 {
            throw ValidationError("Margin must be a non-negative number")
        }

        // Validate display number
        if let display = display, display < 1 {
            throw ValidationError("Display number must be 1 or greater")
        }
    }

    // MARK: - Execution

    func run() throws {
        let logger = Logger(verbose: verbose, dryRun: dryRun)

        // Check accessibility permissions
        let accessibilityManager = AccessibilityManager()
        guard accessibilityManager.checkPermission() else {
            throw ArrangeWindowsError.accessibilityPermissionDenied
        }

        // Load configuration
        let configLoader = ConfigLoader()
        let config = try configLoader.loadConfig()

        // Merge settings: CLI > per-app > global > defaults
        let effectiveSettings = mergeSettings(config: config, appName: appName)

        logger.info("Arranging windows for: \(appName)")
        logger.debug("Layout: \(selectedLayout.rawValue)")
        logger.debug("Settings: size=\(effectiveSettings.windowSize), overlap=\(effectiveSettings.overlap), margin=\(effectiveSettings.margin)")

        // Find the application
        let applicationFinder = ApplicationFinder()
        guard let app = try applicationFinder.findApplication(named: appName) else {
            throw ArrangeWindowsError.applicationNotFound(appName)
        }

        logger.info("Found application: \(app.localizedName ?? appName) (PID: \(app.processIdentifier))")

        // Get target display
        let displayManager = DisplayManager()
        let targetDisplay: DisplayInfo

        if let displayNumber = effectiveSettings.displayNumber {
            guard let display = displayManager.getDisplay(byIndex: displayNumber) else {
                let availableDisplays = displayManager.getDisplays().map { String($0.index) }.joined(separator: ", ")
                throw ArrangeWindowsError.displayNotFound(displayNumber, availableDisplays)
            }
            targetDisplay = display
        } else {
            targetDisplay = displayManager.getMainDisplay()
        }

        logger.debug("Target display: \(targetDisplay.index) - \(Int(targetDisplay.visibleBounds.width))x\(Int(targetDisplay.visibleBounds.height))")

        // Get windows for the application
        let windowManager = WindowManager()
        var windows = try windowManager.getWindows(for: app)

        // Filter minimized windows unless explicitly included
        if !effectiveSettings.includeMinimized {
            windows = windows.filter { !$0.isMinimized }
        }

        guard !windows.isEmpty else {
            throw ArrangeWindowsError.noWindowsFound(appName)
        }

        logger.info("Found \(windows.count) window(s)")

        // Handle reset separately
        if selectedLayout == .reset {
            let stateManager = StateManager()
            guard let savedState = try stateManager.loadState(for: appName) else {
                throw ArrangeWindowsError.noSavedState(appName)
            }

            logger.info("Restoring \(savedState.windows.count) window(s) to saved positions")

            if dryRun {
                for windowState in savedState.windows {
                    logger.dryRun("Would restore '\(windowState.title)' to position (\(Int(windowState.position.x)), \(Int(windowState.position.y))) size \(Int(windowState.size.width))x\(Int(windowState.size.height))")
                }
            } else {
                try stateManager.applyState(savedState, to: windows, using: windowManager)
                try windowManager.activateApplication(app)
            }

            logger.success("Windows restored to previous positions")
            return
        }

        // Save current state before modification
        let stateManager = StateManager()
        try stateManager.saveState(windows: windows, appName: appName)
        logger.debug("Saved current window state")

        // Create layout options
        let layoutOptions = LayoutOptions(
            windowSize: effectiveSettings.windowSize,
            overlap: effectiveSettings.overlap,
            margin: effectiveSettings.margin
        )

        // Get the appropriate layout engine
        let layoutEngine = createLayoutEngine(for: selectedLayout)

        // Calculate placements
        let placements = layoutEngine.apply(windows: windows, displayBounds: targetDisplay.visibleBounds, options: layoutOptions)

        // Apply or preview placements
        if dryRun {
            for placement in placements {
                let currentPos = placement.window.position
                let currentSize = placement.window.size
                logger.dryRun("'\(placement.window.title)': (\(Int(currentPos.x)), \(Int(currentPos.y))) \(Int(currentSize.width))x\(Int(currentSize.height)) → (\(Int(placement.targetPosition.x)), \(Int(placement.targetPosition.y))) \(Int(placement.targetSize.width))x\(Int(placement.targetSize.height))")
            }
        } else {
            for placement in placements {
                try windowManager.setPosition(placement.targetPosition, for: placement.window)
                try windowManager.setSize(placement.targetSize, for: placement.window)
                try windowManager.raise(window: placement.window)
            }

            // Activate the application
            try windowManager.activateApplication(app)
        }

        logger.success("Arranged \(windows.count) window(s) using \(selectedLayout.rawValue) layout")
    }

    // MARK: - Private Helpers

    private func mergeSettings(config: Config, appName: String) -> EffectiveSettings {
        let appConfig = config.apps[appName] ?? config.apps[appName.lowercased()]
        let globalConfig = config.global

        return EffectiveSettings(
            windowSize: size ?? appConfig?.windowSize ?? globalConfig.windowSize ?? WindowSize.default,
            overlap: overlap ?? appConfig?.overlap ?? globalConfig.overlap ?? 30,
            margin: margin ?? appConfig?.margin ?? globalConfig.margin ?? 20,
            displayNumber: display ?? appConfig?.display ?? globalConfig.display,
            includeMinimized: includeMinimized || (appConfig?.includeMinimized ?? globalConfig.includeMinimized ?? false)
        )
    }

    private func createLayoutEngine(for layout: LayoutMode) -> LayoutEngine {
        switch layout {
        case .cascade:
            return CascadeLayout()
        case .grid:
            return GridLayout()
        case .leftHalf:
            return LeftHalfLayout()
        case .rightHalf:
            return RightHalfLayout()
        case .topHalf:
            return TopHalfLayout()
        case .bottomHalf:
            return BottomHalfLayout()
        case .quarters:
            return QuartersLayout()
        case .reset:
            fatalError("Reset should be handled separately")
        }
    }
}

/// Effective settings after merging CLI, per-app, global, and defaults
struct EffectiveSettings {
    let windowSize: WindowSize
    let overlap: Int
    let margin: Int
    let displayNumber: Int?
    let includeMinimized: Bool
}
