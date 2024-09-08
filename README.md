# AppLogger
Universal logging system, providing useful debug information for each print log.

<img src=".resources/applogger-demo.png" width="600"/>

#### Pros
- logs are printed only for debug mode, so in the production, compiler stripes out the logger code
- easy to use across the app
- customizable
- supports metadata
  
  <img src=".resources/applogger-metadata.gif" width="600"/>

#### Cons
- Location info such as line number, function and file, are passed to the system `Logger` as `category`, so it requires
  that each log creates new instance of the Logger. This could probably be a problem, however any performance issues were not encountered yet.

# Installation SPM
Add Package Dependency... and paste the URL of this repo: `https://github.com/baquaz/AppLogger.git`

# Requirements
Add Xcode Environment Variable: `ENABLE_APP_LOGGER` and set value `true` or `false` to handle the logs.

<img src=".resources/xc-var.png" width="600"/>

By default, if the variable is missing, the logs are disabled and there is a warning printed in the console.

# Usage
To make life easier we should start with defining global type alias.

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

In case there is a need to use custom tags there are `AppLogType` and `LogStrategy` protocols to be used.

AppLogType defines custom log types.

```swift
enum MyLogType: AppLogType {
    case info, critical

    var label: String {
        switch self {
            case .info:
                "[MYCUSTOM_INFO ℹ️]"
            case .critical:
                "[MYCUSTOM_CRITICAL 🔥]"
        }
    }
}
```
Log Strategy defines how to print each log type
```swift
import os

struct CustomLogStrategy: LogStrategy {
    var defaultLogType: AppLogType = MyLogType.info
    
    func log(message: String, tag: any AppLogType, category: String) {
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
```

### Usage
```swift
// set custom log strategy first
Applog.setLogStrategy(CustomLogStrategy())

Applog.printCustom("my custom default log")
Applog.printCustom(tag: MyLogType.critical, "my custom critical message")
```
