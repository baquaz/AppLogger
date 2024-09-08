// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import OSLog

public struct AppLogger: AppLogging {
    
    private static var logStrategy: LogStrategy = DefaultLogStrategy()
    
    private static let isLoggerEnabled: Bool = {
        if let logValue = ProcessInfo.processInfo.environment["ENABLE_APP_LOGGER"] {
            return logValue.lowercased() == "true"
        } else {
#if DEBUG
            Swift.print("[APP_LOGGER ⚠️]: Xcode Environment Variable `ENABLE_APP_LOGGER` is missing, logs are disabled")
#endif
            return false
        }
    }()
    
    // MARK: - Set Custom LogStrategy
    public static func setLogStrategy(_ strategy: LogStrategy) {
        logStrategy = strategy
    }
    
    // MARK: - Default Print
    public static func print(
        tag: LogType = .debug,
        _ items: Any...,
        separator: String = " ",
        file: String = #file,
        function: String = #function,
        line: Int = #line)
    {
#if DEBUG
        guard isLoggerEnabled else { return }
        
        let shortFileName = file.components(separatedBy: "/").last ?? "---"
        let locationInfo = "\(shortFileName) - \(function) - line \(line)"
        
        let output = items.map {
            if let item = $0 as? CustomStringConvertible {
                "\(item.description)"
            } else {
                "\($0)"
            }
        }
            .joined(separator: separator)
        
        let msg = "\(tag.label)\n\(output)"
        
        logStrategy.log(message: msg, tag: tag, category: locationInfo)
#endif
    }
    
    // MARK: - Print Custom Tags
    public static func printCustom(
        tag: (any AppLogType)? = nil,
        _ items: Any...,
        separator: String = " ",
        file: String = #file,
        function: String = #function,
        line: Int = #line)
    {
#if DEBUG
        guard isLoggerEnabled else { return }
        
        let shortFileName = file.components(separatedBy: "/").last ?? "---"
        let locationInfo = "\(shortFileName) - \(function) - line \(line)"
        
        let output = items.map {
            if let item = $0 as? CustomStringConvertible {
                "\(item.description)"
            } else {
                "\($0)"
            }
        }
            .joined(separator: separator)
        
        let logTag = tag ?? logStrategy.defaultLogType
        
        let msg = "\(logTag.label)\n\(output)"
        
        logStrategy.log(message: msg, tag: logTag, category: locationInfo)
#endif
    }
}
