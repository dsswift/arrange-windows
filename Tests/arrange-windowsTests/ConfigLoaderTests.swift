import XCTest
@testable import arrange_windows

final class ConfigLoaderTests: XCTestCase {
    func testEmptyConfig() {
        let config = Config()

        XCTAssertNil(config.global.windowSize)
        XCTAssertNil(config.global.overlap)
        XCTAssertNil(config.global.margin)
        XCTAssertNil(config.global.display)
        XCTAssertNil(config.global.includeMinimized)
        XCTAssertTrue(config.apps.isEmpty)
    }

    func testEffectiveSettingsDefaults() {
        let settings = EffectiveSettings(
            windowSize: WindowSize.default,
            overlap: 30,
            margin: 20,
            displayNumber: nil,
            includeMinimized: false
        )

        XCTAssertEqual(settings.windowSize.width, 1280)
        XCTAssertEqual(settings.windowSize.height, 1000)
        XCTAssertEqual(settings.overlap, 30)
        XCTAssertEqual(settings.margin, 20)
        XCTAssertNil(settings.displayNumber)
        XCTAssertFalse(settings.includeMinimized)
    }

    func testEffectiveSettingsCustomValues() {
        let customSize = WindowSize(argument: "1400x900")!
        let settings = EffectiveSettings(
            windowSize: customSize,
            overlap: 50,
            margin: 10,
            displayNumber: 2,
            includeMinimized: true
        )

        XCTAssertEqual(settings.windowSize.width, 1400)
        XCTAssertEqual(settings.windowSize.height, 900)
        XCTAssertEqual(settings.overlap, 50)
        XCTAssertEqual(settings.margin, 10)
        XCTAssertEqual(settings.displayNumber, 2)
        XCTAssertTrue(settings.includeMinimized)
    }

    func testConfigLoaderPath() {
        let loader = ConfigLoader()
        let path = loader.path

        XCTAssertTrue(path.contains(".config/arrange-windows/config.toml"))
    }

    func testWindowStateEncodeDecode() throws {
        let original = WindowState(
            title: "Test Window",
            position: CGPointCodable(CGPoint(x: 100, y: 200)),
            size: CGSizeCodable(CGSize(width: 800, height: 600))
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(WindowState.self, from: data)

        XCTAssertEqual(decoded.title, original.title)
        XCTAssertEqual(decoded.position.x, original.position.x)
        XCTAssertEqual(decoded.position.y, original.position.y)
        XCTAssertEqual(decoded.size.width, original.size.width)
        XCTAssertEqual(decoded.size.height, original.size.height)
    }

    func testAppStateEncodeDecode() throws {
        let windowState = WindowState(
            title: "Test Window",
            position: CGPointCodable(CGPoint(x: 100, y: 200)),
            size: CGSizeCodable(CGSize(width: 800, height: 600))
        )

        let original = AppState(
            appName: "TestApp",
            timestamp: Date(),
            windows: [windowState]
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(AppState.self, from: data)

        XCTAssertEqual(decoded.appName, original.appName)
        XCTAssertEqual(decoded.windows.count, 1)
        XCTAssertEqual(decoded.windows[0].title, windowState.title)
    }

    func testCGPointCodable() {
        let point = CGPoint(x: 123.5, y: 456.7)
        let codable = CGPointCodable(point)

        XCTAssertEqual(codable.x, 123.5)
        XCTAssertEqual(codable.y, 456.7)
        XCTAssertEqual(codable.cgPoint.x, 123.5)
        XCTAssertEqual(codable.cgPoint.y, 456.7)
    }

    func testCGSizeCodable() {
        let size = CGSize(width: 800.5, height: 600.5)
        let codable = CGSizeCodable(size)

        XCTAssertEqual(codable.width, 800.5)
        XCTAssertEqual(codable.height, 600.5)
        XCTAssertEqual(codable.cgSize.width, 800.5)
        XCTAssertEqual(codable.cgSize.height, 600.5)
    }
}
