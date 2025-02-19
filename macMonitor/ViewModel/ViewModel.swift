//
//  ViewModel.swift
//  macMonitor
//
//  Created by Luis Amorim on 19/02/25.
//

import Cocoa
import IOKit.ps
import IOKit

/// A view model responsible for retrieving system information metrics from the model.
///
/// This view model fetches CPU usage, RAM usage, Disk usage, and Battery information at regular intervals.
/// The data is stored in published properties so that SwiftUI views are automatically updated.
///
/// - Note: The data is updated every second. CPU, RAM, Disk, and Battery histories are maintained with a maximum of 60 data points.
class SystemInfoViewModel: ObservableObject {
    /// A history of CPU usage percentages over time.
    @Published var cpuHistory: [Double] = []
    /// A history of RAM usage percentages over time.
    @Published var ramHistory: [Double] = []
    /// The current disk usage percentage.
    @Published var diskUsage: Double = 0.0
    /// A history of Disk usage percentages over time.
    @Published var diskHistory: [Double] = []
    /// The current battery percentage.
    @Published var batteryPercentage: Double = 0.0
    /// A history of Battery percentages over time.
    @Published var batteryHistory: [Double] = []
    /// Indicates whether the battery is currently charging.
    @Published var batteryIsCharging: Bool = false

    private var timer: Timer?

    /// Initializes the view model and starts updating system information.
    init() {
        startUpdating()
    }
    
    /// Starts the timer that updates system information every second.
    func startUpdating() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateSystemInfo()
        }
    }
    
    /// Stops the timer from updating system information.
    func stopUpdating() {
        timer?.invalidate()
    }
    
    /// Fetches system metrics from the `SystemInfo` model and updates the published properties.
    ///
    /// The function obtains:
    /// - CPU usage via `SystemInfo.getCPUUsage()`
    /// - RAM usage via `SystemInfo.getRAMUsage()`
    /// - Disk usage via `SystemInfo.getDiskUsage()`
    /// - Battery information via `SystemInfo.getBatteryInfo()`
    ///
    /// The CPU, RAM, Disk, and Battery histories are kept to a maximum of 60 data points.
    func updateSystemInfo() {
        DispatchQueue.global(qos: .background).async {
            let cpu = SystemInfo.getCPUUsage()
            let ram = SystemInfo.getRAMUsage()
            let disk = SystemInfo.getDiskUsage()
            let batteryInfo = SystemInfo.getBatteryInfo()
            
            DispatchQueue.main.async {
                // Update CPU history
                if self.cpuHistory.count >= 60 {
                    self.cpuHistory.removeFirst()
                }
                self.cpuHistory.append(cpu)
                
                // Update RAM history
                if self.ramHistory.count >= 60 {
                    self.ramHistory.removeFirst()
                }
                self.ramHistory.append(ram)
                
                // Update Disk usage and history
                self.diskUsage = disk
                if self.diskHistory.count >= 60 {
                    self.diskHistory.removeFirst()
                }
                self.diskHistory.append(disk)
                
                // Update Battery information and history
                self.batteryPercentage = batteryInfo.percentage
                if self.batteryHistory.count >= 60 {
                    self.batteryHistory.removeFirst()
                }
                self.batteryHistory.append(batteryInfo.percentage)
                self.batteryIsCharging = batteryInfo.isCharging
            }
        }
    }
}
