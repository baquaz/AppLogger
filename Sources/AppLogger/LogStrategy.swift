//
//  LogStrategy.swift
//
//
//  Created by baquaz on 07/09/2024.
//

import Foundation
import os

public protocol LogStrategy {
    var defaultLogType: AppLogType { get set }
    func log(message: String, tag: any AppLogType, category: String)
}

// MARK: - Default LogStrategy
public struct DefaultLogStrategy: LogStrategy {
    
    public var defaultLogType: AppLogType = LogType.debug
    
    public func log(message: String, tag: any AppLogType, category: String) {
        let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "--", category: category)
        switch tag {
            case let tag as LogType:
                switch tag {
                    case .error:
                        logger.fault("\(message)")
                    case .warning:
                        logger.warning("\(message)")
                    case .success:
                        logger.info("\(message)")
                    case .debug:
                        logger.debug("\(message)")
                    case .network:
                        logger.info("\(message)")
                    case .simOnly:
                        logger.info("\(message)")
                }
            default:
                logger.log("\(message)")
        }
    }
}
