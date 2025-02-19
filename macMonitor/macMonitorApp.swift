//
//  macMonitorApp.swift
//  macMonitor
//
//  Created by Luis Amorim on 19/02/25.
//

import SwiftUI

@main
struct MacMonitorApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(width: 600, height: 190) // Sets the fixed view size
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        .windowResizability(.contentSize)
    }
}

/// A custom AppDelegate to configure the main window.
///
/// This class sets a fixed window size and prevents resizing.
class AppDelegate: NSObject, NSApplicationDelegate {
    /// Called when the application has finished launching.
    ///
    /// This method schedules the window configuration on the main thread
    /// to ensure that the window has been created.
    func applicationDidFinishLaunching(_ notification: Notification) {
        DispatchQueue.main.async {
            self.configureWindow()
        }
    }

    /// Configures the main application window to have a fixed size and prevents resizing.
    ///
    /// - Note: The window's minimum and maximum sizes are both set to the fixed size.
    ///         Additionally, the resizable style is removed from the window.
    func configureWindow() {
        guard let window = NSApplication.shared.windows.first else {
            assertionFailure("No window available")
            return
        }
        
        // Define the fixed window size.
        let fixedSize = NSSize(width: 600, height: 190)
        
        // Set the window's content size.
        window.setContentSize(fixedSize)
        
        // Enforce a fixed window size by setting min and max sizes.
        window.minSize = fixedSize
        window.maxSize = fixedSize

        // Remove the resizable style from the window.
        window.styleMask.remove(.resizable)
        
        // Configure the window buttons.
        window.standardWindowButton(.closeButton)?.isHidden = false
        window.standardWindowButton(.miniaturizeButton)?.isHidden = false
        window.standardWindowButton(.zoomButton)?.isHidden = true
    }
}
