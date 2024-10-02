// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import OSLog

public struct AppLogger: AppLogging {
  
  private static var logStrategy: LogStrategy = DefaultLogStrategy()
  
  private static let isLoggerEnabled: Bool = {
    guard let logValue = ProcessInfo.processInfo.environment["ENABLE_APP_LOGGER"] else {
#if DEBUG
      Swift.print("[APP_LOGGER ⚠️]: Xcode Environment Variable `ENABLE_APP_LOGGER` is missing, logs are disabled")
#endif
      return false
    }
    
    return logValue.lowercased() == "true"
  }()
  
  // MARK: - Set Custom LogStrategy
  public static func setLogStrategy(_ strategy: LogStrategy) {
    logStrategy = strategy
  }
  
  // MARK: - Format Location Info
  private static func formatLocationInfo(
    file: String, function: String,
    line: Int) -> String
  {
    "\(file.components(separatedBy: "/").last ?? "---") - \(function) - line \(line)"
  }
  
  // MARK: - Print Tags
  public static func print(
    tag: (any LogType) = DefaultLogType.debug,
    _ items: Any...,
    separator: String = " ",
    file: String = #file,
    function: String = #function,
    line: Int = #line)
  {
#if DEBUG
    guard isLoggerEnabled else { return }

    let output = items.map { "\($0)" }.joined(separator: separator)
    
    logStrategy.log(message: "\(tag.label)\n\(output)",
                    tag: tag,
                    category: formatLocationInfo(file: file, function: function, line: line))
#endif
  }
}
