import Foundation

/// Simple logging utility for console output
struct Logger {
    let verbose: Bool
    let dryRun: Bool

    /// Log an informational message
    func info(_ message: String) {
        print(message)
    }

    /// Log a debug message (only in verbose mode)
    func debug(_ message: String) {
        if verbose {
            print("[DEBUG] \(message)")
        }
    }

    /// Log a success message
    func success(_ message: String) {
        print("✓ \(message)")
    }

    /// Log an error message
    func error(_ message: String) {
        fputs("Error: \(message)\n", stderr)
    }

    /// Log a dry-run action (prefixed to indicate no actual change)
    func dryRun(_ message: String) {
        print("[DRY-RUN] \(message)")
    }

    /// Log a warning message
    func warning(_ message: String) {
        print("[WARNING] \(message)")
    }
}
