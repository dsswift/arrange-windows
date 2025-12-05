# Feature: arrange-windows — macOS CLI Window Arrangement Tool (Phase 1)

## Feature Description

A fast, lightweight, native macOS command-line tool that instantly targets all windows belonging to a specific running application, optionally resizes them to consistent dimensions, and arranges them on screen using one of several built-in layouts. The tool uses the Accessibility API and CoreGraphics for reliable window manipulation across all macOS applications including JetBrains IDEs, Chrome, and other apps that don't work well with AppleScript.

Key capabilities:
- Target windows by application name (as shown in Activity Monitor/Window menu) or bundle identifier
- Support 8 layout modes: cascade (default), grid, left-half, right-half, top-half, bottom-half, quarters, reset
- Configurable window sizing, margins, and overlap offsets
- Per-application configuration via TOML config file
- State caching for undo/reset functionality
- Sub-second execution even with 20-30 windows

## User Story

As a power user with many windows open across multiple applications
I want to quickly arrange windows belonging to a specific app into predictable layouts
So that I can organize my workspace efficiently without manual drag-and-drop operations

## Problem Statement

macOS provides limited built-in window management. Users with many windows open across applications (especially developers using JetBrains IDEs, VS Code, terminals, and browsers) spend significant time manually arranging windows. Existing solutions either require mouse interaction (Rectangle, Magnet), don't target specific applications, or rely on AppleScript which fails with certain applications.

## Solution Statement

Build a Swift-based CLI tool that uses the Accessibility API for reliable cross-application window manipulation. The tool will:
1. Accept an app name and layout command via CLI
2. Find all windows belonging to that application using AXUIElement APIs
3. Cache current window positions before any modification (for reset)
4. Apply the requested layout algorithm
5. Bring the application to the front

The tool will be distributed as a single static binary with no dependencies, installable via Homebrew or direct download.

## Relevant Files

This is a greenfield project. All files need to be created.

### New Files

**Project Structure:**
- `Package.swift` — Swift Package Manager manifest defining the CLI executable and dependencies
- `.gitignore` — Standard Swift/macOS gitignore

**Source Files:**
- `Sources/arrange-windows/main.swift` — Entry point, argument parsing, orchestration
- `Sources/arrange-windows/CLI/ArgumentParser.swift` — Command-line argument parsing using swift-argument-parser
- `Sources/arrange-windows/CLI/Commands.swift` — CLI command definitions and validation
- `Sources/arrange-windows/Config/ConfigLoader.swift` — TOML configuration file loading and merging
- `Sources/arrange-windows/Config/Settings.swift` — Configuration model (global + per-app settings)
- `Sources/arrange-windows/Accessibility/AccessibilityManager.swift` — Accessibility permission checks and setup
- `Sources/arrange-windows/Accessibility/WindowManager.swift` — AXUIElement-based window enumeration and manipulation
- `Sources/arrange-windows/Accessibility/ApplicationFinder.swift` — Find running app by name or bundle ID
- `Sources/arrange-windows/Display/DisplayManager.swift` — Screen/display enumeration using CoreGraphics
- `Sources/arrange-windows/Display/Geometry.swift` — CGRect/CGPoint/CGSize helpers and calculations
- `Sources/arrange-windows/Layouts/LayoutEngine.swift` — Protocol and base implementation for layouts
- `Sources/arrange-windows/Layouts/CascadeLayout.swift` — Cascade/stagger layout implementation
- `Sources/arrange-windows/Layouts/GridLayout.swift` — Auto-grid layout implementation
- `Sources/arrange-windows/Layouts/HalfScreenLayouts.swift` — Left/right/top/bottom half layouts
- `Sources/arrange-windows/Layouts/QuartersLayout.swift` — Corners layout with center cascade overflow
- `Sources/arrange-windows/State/StateManager.swift` — Window state caching and restoration for reset
- `Sources/arrange-windows/Utilities/Logger.swift` — Logging and dry-run output

**Test Files:**
- `Tests/arrange-windowsTests/ConfigLoaderTests.swift` — Configuration parsing tests
- `Tests/arrange-windowsTests/GeometryTests.swift` — Geometry calculation tests
- `Tests/arrange-windowsTests/LayoutEngineTests.swift` — Layout algorithm tests (unit tests with mock windows)
- `Tests/arrange-windowsTests/ArgumentParserTests.swift` — CLI argument parsing tests

## Implementation Plan

### Phase 1: Foundation

1. **Project Setup**
   - Initialize Swift Package with executable target
   - Add dependencies: swift-argument-parser (CLI), TOMLKit or similar (config parsing)
   - Configure for macOS 14+ deployment target
   - Set up basic project structure

2. **Accessibility Foundation**
   - Implement permission check using AXIsProcessTrusted()
   - Create friendly permission request flow with System Settings deep link
   - Build basic AXUIElement wrapper for window enumeration

3. **Display Management**
   - Enumerate displays using CGGetActiveDisplayList
   - Get display bounds accounting for menu bar and dock
   - Support main/primary display and numbered display selection

### Phase 2: Core Implementation

4. **Application and Window Discovery**
   - Find running applications by name using NSWorkspace
   - Fallback to bundle identifier matching
   - Enumerate windows per application using AXUIElementCopyAttributeValue
   - Filter minimized windows (default: exclude)

5. **Window Manipulation**
   - Set window position using kAXPositionAttribute
   - Set window size using kAXSizeAttribute
   - Bring window to front using AXUIElementPerformAction with kAXRaiseAction
   - Activate application using NSRunningApplication.activate

6. **Layout Algorithms**
   - Implement LayoutEngine protocol with apply(windows:, bounds:, options:)
   - CascadeLayout: offset stacking from top-left
   - GridLayout: compute optimal rows/cols, distribute windows
   - HalfScreenLayouts: divide screen, stack/tile windows
   - QuartersLayout: corners + center cascade for overflow

7. **State Management**
   - Save window positions to JSON file in ~/Library/Application Support/arrange-windows/
   - Keyed by application name with timestamp
   - Reset command reads and applies cached state

### Phase 3: Integration

8. **Configuration System**
   - Parse ~/.config/arrange-windows/config.toml
   - Support global defaults and [AppName] sections
   - Merge: CLI flags > per-app config > global config > defaults

9. **CLI Interface**
   - Use swift-argument-parser for professional CLI experience
   - Subcommand-style: `arrange-windows <app-name> [--layout] [options]`
   - Implement --dry-run with detailed output
   - Validate inputs and provide helpful error messages

10. **Polish and Error Handling**
    - Comprehensive error messages for all failure modes
    - Graceful handling of missing apps, no windows, permission denied
    - Performance optimization for sub-second execution

## Step by Step Tasks

### Step 1: Initialize Swift Package

- Create `Package.swift` with executable target `arrange-windows`
- Add dependency on `swift-argument-parser` (version 1.3.0+)
- Add dependency on `TOMLDecoder` for config parsing
- Set platform to `.macOS(.v14)` for modern macOS support
- Create basic directory structure under `Sources/` and `Tests/`

### Step 2: Create Basic Entry Point and CLI Structure

- Implement `main.swift` with @main attribute using ArgumentParser
- Define `ArrangeWindows` as the root command
- Add required `appName` argument
- Add layout flags: `--cascade`, `--grid`, `--left-half`, `--right-half`, `--top-half`, `--bottom-half`, `--quarters`, `--reset`
- Add option flags: `--size`, `--overlap`, `--margin`, `--display`, `--exclude-minimized`, `--dry-run`
- Implement basic validation and help text

### Step 3: Implement Accessibility Permission Handling

- Create `AccessibilityManager.swift`
- Implement `checkPermission()` using `AXIsProcessTrusted()`
- Implement `requestPermission()` with options to prompt
- Create friendly error message with System Settings URL for manual enablement
- Test permission flow on fresh system

### Step 4: Implement Display Management

- Create `DisplayManager.swift`
- Implement `getDisplays()` using `CGGetActiveDisplayList`
- Implement `getMainDisplay()` for primary display
- Implement `getDisplayByIndex(index:)` for numbered displays
- Create `DisplayInfo` struct with bounds, visibleBounds (accounting for menu bar/dock)
- Create `Geometry.swift` with CGRect/CGSize helper extensions

### Step 5: Implement Application Finder

- Create `ApplicationFinder.swift`
- Implement `findApplication(byName:)` using `NSWorkspace.shared.runningApplications`
- Implement `findApplication(byBundleId:)` as fallback
- Handle case-insensitive matching for app names
- Return `NSRunningApplication` or throw descriptive error

### Step 6: Implement Window Manager

- Create `WindowManager.swift`
- Implement `getWindows(for app: NSRunningApplication)` using AXUIElement
- Create `AXUIElementCreateApplication(pid)` for app reference
- Get windows via `kAXWindowsAttribute`
- Create `WindowInfo` struct with: axElement, title, position, size, isMinimized
- Implement `setPosition(_:for:)` and `setSize(_:for:)` using AX attributes
- Implement `raise(window:)` using `kAXRaiseAction`
- Implement `activateApplication(_:)` using NSRunningApplication

### Step 7: Implement State Manager for Reset

- Create `StateManager.swift`
- Define `WindowState` struct: appName, windowTitle, position, size, timestamp
- Implement `saveState(windows:, appName:)` to JSON file
- Store in `~/Library/Application Support/arrange-windows/state.json`
- Implement `loadState(appName:)` to retrieve last saved state
- Implement `applyState(state:, windows:)` to restore positions

### Step 8: Implement Layout Engine Protocol

- Create `LayoutEngine.swift`
- Define `Layout` enum: cascade, grid, leftHalf, rightHalf, topHalf, bottomHalf, quarters
- Define `LayoutOptions` struct: windowSize, overlap, margin
- Define `LayoutEngine` protocol with `apply(windows:, displayBounds:, options:) -> [WindowPlacement]`
- Define `WindowPlacement` struct: window reference, targetPosition, targetSize

### Step 9: Implement Cascade Layout

- Create `CascadeLayout.swift`
- Implement cascade algorithm:
  - Start at top-left (+ margin)
  - Each window offset by `overlap` pixels in X and Y
  - Reset to top when approaching screen edge
- Handle window sizing (default 1280x1000 or --size)
- Ensure all title bars remain visible

### Step 10: Implement Grid Layout

- Create `GridLayout.swift`
- Calculate optimal grid dimensions for window count (prefer square)
- Divide display bounds into cells
- Place windows centered within each cell
- Handle remainder windows in last row

### Step 11: Implement Half-Screen Layouts

- Create `HalfScreenLayouts.swift`
- Implement `LeftHalfLayout`: divide screen vertically, tile windows in left half
- Implement `RightHalfLayout`: tile windows in right half
- Implement `TopHalfLayout`: divide screen horizontally, tile windows in top half
- Implement `BottomHalfLayout`: tile windows in bottom half
- Windows should stack vertically (left/right) or horizontally (top/bottom)

### Step 12: Implement Quarters Layout

- Create `QuartersLayout.swift`
- Place up to 4 windows in corners (top-left, top-right, bottom-left, bottom-right)
- Any additional windows cascade in center of screen
- Calculate quarter bounds accounting for margins

### Step 13: Implement Configuration Loader

- Create `ConfigLoader.swift` and `Settings.swift`
- Define `GlobalSettings` with all option fields as optionals
- Define `AppSettings` extending GlobalSettings with app-specific overrides
- Define `Config` with global settings and dictionary of app settings
- Implement `loadConfig()` reading from `~/.config/arrange-windows/config.toml`
- Implement settings merge logic: CLI > per-app > global > defaults

### Step 14: Integrate All Components in Main

- Wire up argument parsing to load config
- Find application by name or bundle ID
- Check accessibility permissions (exit with message if denied)
- Get target display
- Enumerate windows for application
- Save current state (for future reset)
- If reset: load and apply saved state
- Otherwise: apply selected layout
- Activate application and bring windows to front
- Handle --dry-run to print actions without executing

### Step 15: Implement Dry-Run Mode

- Create `Logger.swift` for structured output
- In dry-run mode, print:
  - Found application: name, PID, window count
  - Target display: bounds
  - For each window: current position → target position, current size → target size
- Use consistent formatting for easy parsing

### Step 16: Add Comprehensive Error Handling

- Create custom error types for each failure mode
- Implement user-friendly error messages:
  - "No application named 'X' is running"
  - "No windows found for 'X'"
  - "Accessibility permission required — open System Settings → Privacy & Security → Accessibility"
  - "Display 3 not found (available: 1, 2)"
  - "Invalid size format: use WxH (e.g., 1400x1100) or 'square'"
- Exit with appropriate status codes

### Step 17: Write Unit Tests

- Create `GeometryTests.swift` — test CGRect helpers, grid calculations
- Create `LayoutEngineTests.swift` — test each layout algorithm with mock window data
- Create `ConfigLoaderTests.swift` — test TOML parsing and config merging
- Create `ArgumentParserTests.swift` — test CLI argument parsing and validation
- Ensure 80%+ code coverage on layout logic

### Step 18: Performance Optimization

- Profile with 30+ windows
- Minimize AX API calls (batch where possible)
- Ensure total execution under 500ms for typical use cases
- Add timing output in verbose/debug mode

### Step 19: Build and Test Release Binary

- Build release binary: `swift build -c release`
- Test on macOS 14 Sonoma
- Test on macOS 15 Sequoia (if available)
- Verify single binary with no external dependencies
- Test with various applications: Finder, Safari, Chrome, VS Code, JetBrains IDEs, Terminal, iTerm2

### Step 20: Run Validation Commands

- Execute all unit tests
- Run manual integration tests with real applications
- Verify all layouts work correctly
- Verify reset functionality
- Verify config file loading
- Verify dry-run output

## Testing Strategy

### Unit Tests

- **Geometry Tests**: Grid dimension calculations, rect splitting, margin calculations
- **Layout Algorithm Tests**: Each layout with mock window arrays, verify correct placements
- **Config Parsing Tests**: Valid TOML parsing, invalid TOML handling, merge priority
- **Argument Parsing Tests**: All flag combinations, validation errors, help text

### Integration Tests

- **End-to-End Tests**: Manually test with real applications (Finder, Safari, Terminal)
- **Permission Flow**: Test on fresh system without accessibility permissions
- **Multi-Display**: Test display selection on multi-monitor setup
- **Config Loading**: Test with various config file scenarios

### Edge Cases

- Application not running
- Application running but no windows
- Application running but all windows minimized
- Zero windows after filtering
- Single window (should still work)
- More windows than screen can fit in grid
- Very large windows that exceed display bounds
- Multi-display with different resolutions
- Config file missing (use defaults)
- Config file malformed (error with helpful message)
- Permission denied mid-execution
- Application name with special characters or spaces

## Acceptance Criteria

1. **CLI Invocation**: `arrange-windows <app-name>` works with no layout flag (cascade default)
2. **All Layouts**: Each of the 8 layouts (cascade, grid, left-half, right-half, top-half, bottom-half, quarters, reset) functions correctly
3. **App Matching**: Applications can be found by display name or bundle identifier
4. **Window Manipulation**: Windows are correctly resized and positioned using Accessibility API
5. **Reset Works**: Running a layout then `--reset` restores original positions
6. **Config Loading**: TOML config at `~/.config/arrange-windows/config.toml` is respected
7. **Config Priority**: CLI flags override per-app config override global config
8. **Permission Handling**: Clear message shown when accessibility permission is missing
9. **Performance**: Execution completes in under 1 second with 20 windows
10. **Error Messages**: All error conditions produce helpful, actionable messages
11. **Dry-Run**: `--dry-run` outputs planned actions without making changes
12. **Single Binary**: Release build produces single executable with no external dependencies
13. **macOS Compatibility**: Works on macOS 14 Sonoma and macOS 15 Sequoia

## Validation Commands

Execute every command to validate the feature works correctly with zero regressions.

```bash
# Build the project
swift build

# Run all unit tests
swift test

# Build release binary
swift build -c release

# Verify binary exists and runs
.build/release/arrange-windows --help

# Test with Finder (safe test target)
.build/release/arrange-windows Finder --dry-run
.build/release/arrange-windows Finder --cascade --dry-run
.build/release/arrange-windows Finder --grid --dry-run
.build/release/arrange-windows Finder --left-half --dry-run
.build/release/arrange-windows Finder --right-half --dry-run
.build/release/arrange-windows Finder --quarters --dry-run

# Test actual arrangement (requires manual verification)
.build/release/arrange-windows Finder --cascade
.build/release/arrange-windows Finder --reset

# Test with custom options
.build/release/arrange-windows Finder --size 1400x1000 --margin 30 --dry-run

# Test error handling
.build/release/arrange-windows NonExistentApp 2>&1 | grep -q "No application"

# Verify no external dependencies
otool -L .build/release/arrange-windows | grep -v "/System\|/usr/lib"
```

## Notes

- **Swift Version**: Requires Swift 5.9+ for modern concurrency and macOS 14 deployment target
- **Dependencies**:
  - `swift-argument-parser` (1.3.0+) for CLI
  - `TOMLDecoder` or similar for config parsing
- **Accessibility API Considerations**:
  - AXUIElement APIs are synchronous and can be slow
  - Some apps (especially Electron-based) may have nested window hierarchies
  - JetBrains IDEs work well with AX API but not AppleScript
- **Future Phases**:
  - Phase 2: Keyboard shortcuts via global hotkey registration
  - Phase 2: Saved window arrangements (profiles)
  - Phase 2: Homebrew formula for distribution
- **Testing Challenges**: Accessibility API requires actual running applications; unit tests should mock window data, integration tests require manual execution
- **Bundle IDs for Common Apps**:
  - VS Code: `com.microsoft.VSCode`
  - Chrome: `com.google.Chrome`
  - Safari: `com.apple.Safari`
  - Finder: `com.apple.finder`
  - Terminal: `com.apple.Terminal`
  - iTerm2: `com.googlecode.iterm2`
