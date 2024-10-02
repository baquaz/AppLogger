import XCTest
import os
@testable import AppLogger

final class AppLoggerStrategyTests: XCTestCase {
  
  // Sequential access to the resource
  static var setupTeardownLock = NSLock()
  
  var mockLogStrategy: MockLogStrategy!
  
  override func setUpWithError() throws {
    try super.setUpWithError()
    Self.setupTeardownLock.lock()
    mockLogStrategy = MockLogStrategy()
    AppLogger.setLogStrategy(mockLogStrategy)
    setEnvironmentVariable()
  }
  
  override func tearDownWithError() throws {
    // Clear shared state
    AppLogger.setLogStrategy(DefaultLogStrategy())
    mockLogStrategy = nil
    clearEnvironmentVariable()
    Self.setupTeardownLock.unlock()
    try super.tearDownWithError()
  }
  
  func setEnvironmentVariable() {
    setenv("ENABLE_APP_LOGGER", "true", 1)
  }
  
  func clearEnvironmentVariable() {
    unsetenv("ENABLE_APP_LOGGER")
  }
  
  // MARK: - Tests
  
  func testCustomLogTypeMessageFormat() throws {
    AppLogger.printCustom(tag: MyLogType.info, "Test custom info", separator: ",")
    guard let logged = mockLogStrategy.loggedMessages.first else {
      return XCTFail("No log message captured")
    }
    
    XCTAssertTrue(logged.message.contains("[MYCUSTOM_INFO ℹ️]"))
    XCTAssertTrue(logged.message.contains("Test custom info"))
  }
  
  // MARK: - Performance Tests
  
  func testPerformanceOfDefaultLoggingManyMessages() throws {
    let numberOfMessages = 100
    measure {
      for i in 0..<numberOfMessages {
        AppLogger.print(tag: .debug, "Test message number \(i)")
      }
    }
  }
  
  func testPerformanceOfCustomLoggingManyMessages() throws {
    let numberOfMessages = 100
    measure {
      AppLogger.setLogStrategy(CustomLogStrategy())
      
      for i in 0..<numberOfMessages {
        AppLogger.printCustom(tag: MyLogType.info, "Test message number \(i)")
      }
    }
  }
  
  func testPerformanceOfSwiftPrint() {
    let numberOfMessages = 100
    measure {
      for i in 0..<numberOfMessages {
        Swift.print("Swift.print - Test message number \(i)")
      }
    }
  }
  
  func testPerformanceOfOSLoggerNewInstanceEachTime() {
    let numberOfMessages = 100
    let subsystem = Bundle.main.bundleIdentifier ?? "com.example"
    let category = "PerformanceTest"
    
    measure {
      for i in 0..<numberOfMessages {
        let logger = Logger(subsystem: subsystem, category: category)
        logger.log("OS.Logger (new instance) - Test message number \(i)")
      }
    }
  }
  
  func testPerformanceOfSingleInstanceOSLogger() {
    let numberOfMessages = 100
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.example", category: "PerformanceTest")
    
    measure {
      for i in 0..<numberOfMessages {
        logger.log("OS.Logger (single instance) - Test message number \(i)")
      }
    }
  }
}

// MARK: - Custom Log
public enum MyLogType: LogType {
  case info, critical
  public var label: String {
    switch self {
      case .info:
        "[MYCUSTOM_INFO ℹ️]"
      case .critical:
        "[MYCUSTOM_CRITICAL 🔥]"
    }
  }
}

struct CustomLogStrategy: LogStrategy {
  var defaultLogType: LogType = MyLogType.info
  
  func log(message: String, tag: any LogType, category: String) {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "--", category: category)
    switch tag {
      case let tag as MyLogType:
        switch tag {
          case .info:
            logger.info("\(message)")
          case .critical:
            logger.critical("\(message)")
        }
      default:
        logger.log("\(message)")
    }
  }
}

// MARK: - Mock LogStrategy to capture Logs
class MockLogStrategy: LogStrategy {
  var defaultLogType: LogType = MyLogType.info
  var loggedMessages: [(message: String, tag: String, category: String)] = []
  
  func log(message: String, tag: any LogType, category: String) {
    loggedMessages.append((message, tag.label, category))
  }
}
