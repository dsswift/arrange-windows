# arrange-windows

A fast, native macOS command-line tool that arranges windows belonging to a specific application into organized layouts.

## Quick Start

### Install

```bash
# Clone and build
git clone <repo-url>
cd arrange-windows
swift build -c release

# Copy to PATH (optional)
mkdir -p ~/.local/bin
cp .build/release/arrange-windows ~/.local/bin/

# Add to PATH if not already (add to ~/.zshrc or ~/.bashrc)
export PATH="$HOME/.local/bin:$PATH"
```

### Grant Accessibility Permission

The first time you run the tool, macOS will require accessibility permissions:

1. Open **System Settings** → **Privacy & Security** → **Accessibility**
2. Click the **+** button and add the `arrange-windows` binary (or Terminal/iTerm if running from there)
3. Ensure the toggle is enabled

### Basic Usage

```bash
# Cascade all Finder windows (default layout)
arrange-windows Finder

# Arrange Safari windows in a grid
arrange-windows Safari --grid

# Tile VS Code windows in the left half of the screen
arrange-windows "Visual Studio Code" --left-half

# Preview changes without applying them
arrange-windows Finder --cascade --dry-run
```

## What It Does

`arrange-windows` targets all windows belonging to a specific running application and arranges them on screen using one of several built-in layouts. It uses the macOS Accessibility API for reliable window manipulation across all applications, including JetBrains IDEs, Chrome, Electron apps, and others that don't work well with AppleScript.

### Key Features

- **Target by app name or bundle ID** - Use the name shown in the menu bar or Activity Monitor
- **8 layout modes** - cascade, grid, left-half, right-half, top-half, bottom-half, quarters, reset
- **Configurable** - Window size, margins, overlap, and per-app settings via TOML config
- **State caching** - Undo arrangements with `--reset`
- **Fast** - Sub-second execution even with many windows
- **Single binary** - No external dependencies

## Layouts

| Layout | Description |
|--------|-------------|
| `--cascade` | Stack windows diagonally from top-left (default) |
| `--grid` | Auto-calculated grid based on window count |
| `--left-half` | Tile windows vertically in the left half |
| `--right-half` | Tile windows vertically in the right half |
| `--top-half` | Tile windows horizontally in the top half |
| `--bottom-half` | Tile windows horizontally in the bottom half |
| `--quarters` | Place up to 4 windows in corners, overflow cascades in center |
| `--reset` | Restore windows to positions before last arrangement |

## Options

```
--size <WxH>          Window size (e.g., 1400x1000 or 'square')
--overlap <pixels>    Pixel overlap for cascade (default: 30)
--margin <pixels>     Margin from screen edges (default: 20)
--display <number>    Target display (1 = primary, 2 = secondary, etc.)
--include-minimized   Include minimized windows
--dry-run             Preview changes without applying
--verbose             Show detailed output
```

## Configuration

Create a TOML config file at `~/.config/arrange-windows/config.toml`:

```toml
# Global defaults
[global]
window_size = "1400x1000"
overlap = 30
margin = 20
# display = 1
# include_minimized = false

# Per-application overrides
[Safari]
window_size = "1200x900"
margin = 10

[Finder]
window_size = "800x600"
overlap = 40

# Use bundle ID for apps with special characters
["com.microsoft.VSCode"]
window_size = "1600x1200"
display = 2
```

### Configuration Priority

Settings are merged in this order (highest priority first):

1. Command-line flags
2. Per-application config
3. Global config
4. Built-in defaults

## Examples

```bash
# Arrange Chrome windows in a 2x2 grid (or optimal grid for window count)
arrange-windows Chrome --grid

# Cascade Terminal windows with custom size and overlap
arrange-windows Terminal --cascade --size 1000x800 --overlap 40

# Put Slack in the right half, Finder in the left half
arrange-windows Slack --right-half
arrange-windows Finder --left-half

# Arrange windows on secondary display
arrange-windows Safari --grid --display 2

# Undo the last arrangement for an app
arrange-windows Safari --reset

# See what would happen without making changes
arrange-windows Finder --quarters --dry-run --verbose
```

## Building from Source

Requires Swift 5.9+ and macOS 14 (Sonoma) or later.

```bash
# Debug build
swift build

# Release build
swift build -c release

# Run tests
swift test

# Binary location
.build/release/arrange-windows
```

## Troubleshooting

### "Accessibility permission required"

The tool needs accessibility permissions to manipulate windows. Grant permission in:
**System Settings** → **Privacy & Security** → **Accessibility**

### "No application named 'X' is running"

- Check the exact app name in the menu bar or Activity Monitor
- Try using the bundle identifier (e.g., `com.apple.Safari`)
- App names are case-insensitive

### "No windows found for 'X'"

- The app is running but has no visible windows
- Use `--include-minimized` to include minimized windows

## License

MIT
