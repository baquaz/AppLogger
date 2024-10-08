# AppLogger
Logging system, providing useful debug information for each print log.

<img src=".resources/applogger-demo.png" width="600"/>

#### Pros
- easy to use across the app
- easy type filtering
  
  <img src=".resources/applogger-select-filter-demo.png" height="245"/>

  <img src=".resources/applogger-selector-filter-demo.png"/>

- easy custom filtering
  
  <img src=".resources/applogger-easy-filter-demo.png" width="500"/> 
  
- logs are printed only for debug mode, so in the production compiler stripes out the logger code
- plain arguments can be passed without being forced to use string interpolation such as `"\(myObject)"`
- supports interactive metadata
  
  <img src=".resources/applogger-metadata.gif" width="600"/>

#### Cons
- _Location info_ (such as: line number, function and file) are passed to the system `Logger` as `category`, so it requires
  that each log creates new instance of the Logger. Potentially this could be a problem, however any performance issues were not encountered yet.
  
  For now _location info_ as category, brings interactivity to show/hide it at any point of time.
  Anyway, this can be easily refactored if a true purpose for categorization is needed (i.e., by moving _location info_ directly to the tag value and set optionally switchable via an extra environment variable).

# Installation SPM
Add Package Dependency... and paste the URL of this repo: `https://github.com/baquaz/AppLogger.git`

# Requirements
Platform | Minimum version
---------| --------------| 
iOS      |   **14**      | 
macOS    |   **11**      | 

Add Xcode Environment Variable: `ENABLE_APP_LOGGER` and set value `true` or `false` to handle the logs.

<img src=".resources/xc-var.png" width="600"/>

By default, if the variable is missing, the logs are disabled and there is a warning printed in the console.

# Usage
To make life easier start with defining global type alias.

```swift 
// AppDelegate.swift

import AppLogger

typealias Applog = AppLogger
```
This way we can add logs across entire project without having to import AppLogger for each file in which we are going to use them.

### Examples:
```swift
// simple log with default tag
Applog.print("Systems check completed.")

// simple log with explicit tag
Applog.print(tag: .debug, "The Jedi Temple remains secure. All is calm 📡")

struct Mission {
  let planet: String
  let daysETA: Int
  let commander: String
}

let mission = Mission(planet: "Dagobah", daysETA: 3, commander: "Master Yoda")

// log with multiple parameters and custom separator
Applog.print(tag: .network, 
             mission,
             "Waiting for approval...",
             separator: "\n")
```

# Customization
<img src=".resources/applogger-custom-demo.png" width="600"/>

In case there is a need to use custom tags there are `LogType` and `LogStrategy` protocols to be used.

LogType defines custom log tags.

```swift
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
```
Log Strategy defines how to print each log tag
```swift
import os

struct MyCustomLogStrategy: LogStrategy {
  var defaultLogType: LogType = MyLogType.info
  
  func log(message: String, tag: any LogType, category: String) {
    let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "--", category: category)
    switch tag {
      case let tag as MyLogType:
        switch tag {
          case .info: logger.info("\(message)")
          case .critical: logger.critical("\(message)")
        }
      case let tag as DefaultLogType:
        // remap default logs
        switch tag {
          case .error: logger.fault("\(message)")
          case .warning: logger.warning("\(message)")
          case .success: logger.info("\(message)")
          case .debug: logger.debug("\(message)")
          case .network: logger.info("\(message)")
          case .simOnly: logger.info("\(message)")
        }
      default:
        logger.log("\(message)")
    }
  }
}
```

### Usage
```swift
// set custom log strategy first
Applog.setLogStrategy(MyCustomLogStrategy())

Applog.printCustom("my custom default log")
Applog.printCustom(tag: MyLogType.critical, "my custom critical message")
```
#### Further customization
`Applog.printCustom(tag: (any LogType)? = nil, ...)` is a universal method to handle any type of custom log,
so it always requires providing specified type of tag.

There is a way to target single type of custom `LogType`, by wrapping the `printCustom` function.
```swift
extension Applog {
  
  public static func printC(
    tag: MyLogType = .info,
    _ items: Any...,
    separator: String = " ",
    file: String = #file,
    function: String = #function,
    line: Int = #line)
  {
    Applog.printCustom(
      tag: .some(tag),
      items,
      separator: separator,
      file: file,
      function: function,
      line: line
    )
  }
} 

// now instead of using `Applog.printCustom(tag: MyLogType.critical, "my custom critical message")`
// just use wrapped function with short case value.
Applog.printC(tag: .critical, "my custom critical message")
```

# References
Many claps 👏 to the author of this post:

https://medium.com/@alessandromanilii/custom-swift-logger-in-xcode15-19da40a058a5
