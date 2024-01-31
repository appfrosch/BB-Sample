//
//  BBLogger.swift
//  BB
//
//  Created by Andreas Seeger on 24.01.2024.
//

import OSLog

enum BBLogger {
  private static let subsystem = Bundle.main.bundleIdentifier ?? ""

  static let misc = Logger(subsystem: subsystem, category: "misc")
}
