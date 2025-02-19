//
//  Model.swift
//  macMonitor
//
//  Created by Luis Amorim on 19/02/25.
//

import Cocoa
import IOKit.ps
import IOKit

/// A structure that provides system information metrics including CPU, RAM, disk usage, and battery status.
///
/// This structure contains static functions that retrieve current system statistics on macOS.
/// The functions use low-level system APIs such as `host_statistics`, `vm_statistics64`, and IOKit power sources.
struct SystemInfo {
    
    /// Retrieves the current CPU usage as a percentage.
    ///
    /// The function obtains CPU tick counts for user, system, and idle times using the `host_cpu_load_info` API.
    /// The CPU usage is calculated by summing the user and system ticks and dividing by the total ticks.
    ///
    /// - Returns: A `Double` representing the CPU usage percentage, rounded to one decimal place.
    static func getCPUUsage() -> Double {
        var usage: Double = 0.0
        var cpuLoad = host_cpu_load_info()
        var count = mach_msg_type_number_t(MemoryLayout.size(ofValue: cpuLoad) / MemoryLayout<integer_t>.size)
        
        let result = withUnsafeMutablePointer(to: &cpuLoad) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, $0, &count)
            }
        }
        
        if result == KERN_SUCCESS {
            let user = Double(cpuLoad.cpu_ticks.0)
            let system = Double(cpuLoad.cpu_ticks.1)
            let idle = Double(cpuLoad.cpu_ticks.2)
            let total = user + system + idle
            usage = ((user + system) / total) * 100.0
        }
        
        return round(usage * 10) / 10.0
    }
    
    /// Retrieves the current RAM usage as a percentage.
    ///
    /// This function uses the `host_statistics64` API to fetch memory statistics. It calculates the used memory by summing
    /// the active, inactive, and wired memory pages (multiplied by the page size) and compares it to the total memory available.
    ///
    /// - Returns: A `Double` representing the RAM usage percentage, rounded to one decimal place.
    static func getRAMUsage() -> Double {
        var stats = vm_statistics64()
        var size = mach_msg_type_number_t(MemoryLayout<vm_statistics64_data_t>.size / MemoryLayout<integer_t>.size)
        let result = withUnsafeMutablePointer(to: &stats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(size)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &size)
            }
        }
        
        if result == KERN_SUCCESS {
            let used = Double(stats.active_count + stats.inactive_count + stats.wire_count) * Double(vm_page_size)
            let total = Double(stats.free_count + stats.active_count + stats.inactive_count + stats.wire_count) * Double(vm_page_size)
            return round((used / total) * 1000.0) / 10.0
        }
        
        return 0.0
    }
    
    /// Retrieves the current disk usage as a percentage of used space.
    ///
    /// The function uses the `FileManager` to get file system attributes for the user's home directory.
    /// It calculates the used disk space by subtracting the free space from the total space and then computes the percentage.
    ///
    /// - Returns: A `Double` representing the disk usage percentage, rounded to one decimal place.
    static func getDiskUsage() -> Double {
        do {
            let attributes = try FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory())
            if let freeSize = attributes[.systemFreeSize] as? NSNumber,
               let totalSize = attributes[.systemSize] as? NSNumber {
                let usedSize = totalSize.doubleValue - freeSize.doubleValue
                let usagePercentage = (usedSize / totalSize.doubleValue) * 100.0
                return round(usagePercentage * 10) / 10.0
            }
        } catch {
            return 0.0
        }
        return 0.0
    }
    
    /// Retrieves battery information including the current battery percentage and charging status.
    ///
    /// This function uses IOKit's power source APIs (`IOPSCopyPowerSourcesInfo` and `IOPSCopyPowerSourcesList`)
    /// to access detailed battery information. It computes the battery percentage using the current capacity and maximum capacity.
    ///
    /// - Returns: A tuple containing:
    ///   - `percentage`: A `Double` representing the battery percentage, rounded to one decimal place.
    ///   - `isCharging`: A `Bool` indicating whether the battery is currently charging.
    static func getBatteryInfo() -> (percentage: Double, isCharging: Bool) {
        guard let blob = IOPSCopyPowerSourcesInfo()?.takeRetainedValue() else {
            return (0.0, false)
        }
        guard let sources = IOPSCopyPowerSourcesList(blob)?.takeRetainedValue() as? [CFTypeRef] else {
            return (0.0, false)
        }
        for ps in sources {
            if let info = IOPSGetPowerSourceDescription(blob, ps)?.takeUnretainedValue() as? [String: Any] {
                if let capacity = info[kIOPSCurrentCapacityKey] as? Double,
                   let max = info[kIOPSMaxCapacityKey] as? Double,
                   let isCharging = info[kIOPSIsChargingKey] as? Bool {
                    let percentage = (capacity / max) * 100.0
                    return (round(percentage * 10) / 10.0, isCharging)
                }
            }
        }
        return (0.0, false)
    }
}
