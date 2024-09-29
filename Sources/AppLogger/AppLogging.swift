//
//  AppLogging.swift
//
//
//  Created by baquaz on 07/09/2024.
//

import Foundation

public protocol AppLogging {
  /// Prints pre-defined log
  /// - Parameters:
  ///   - tag: type of log
  ///   - items: list of params to print
  ///   - separator: custom separator for items
  ///   - file: source file of log
  ///   - function: source function of log
  ///   - line: file's line number of log
  static func print(
    tag: DefaultLogType,
    _ items: Any...,
    separator: String,
    file: String,
    function: String,
    line: Int)
  
  static func printCustom(tag: (any LogType)?,
                          _ items: Any...,
                          separator: String,
                          file: String,
                          function: String,
                          line: Int)
}

// MARK: - AppLoggingTag
public protocol LogType {
  var label: String { get }
}

// MARK: - Loging Tag
public enum DefaultLogType: LogType {
  case error
  case warning
  case success
  case debug
  case network
  case simOnly
  
  public var label: String {
    switch self {
      case .error   : "[APP_ERROR 🔴]"
      case .warning : "[APP_WARNING 🟠]"
      case .success : "[APP_SUCCESS 🟢]"
      case .debug   : "[APP_DEBUG 🔵]"
      case .network : "[APP_NETWORK 🌍]"
      case .simOnly : "[APP_SIMULATOR_ONLY 🤖]"
    }
  }
}
