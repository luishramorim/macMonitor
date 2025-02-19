//
//   NSWindow+Environment.swift
//  macMonitor
//
//  Created by Luis Amorim on 19/02/25.
//

import SwiftUI

/// A custom environment key to pass the current NSWindow reference.
private struct NSWindowKey: EnvironmentKey {
    static let defaultValue: NSWindow? = nil
}

extension EnvironmentValues {
    var nsWindow: NSWindow? {
        get { self[NSWindowKey.self] }
        set { self[NSWindowKey.self] = newValue }
    }
}
