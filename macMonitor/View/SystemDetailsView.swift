//
//  SystemDetailsView.swift
//  macMonitor
//
//  Created by Luis Amorim on 19/02/25.
//

import SwiftUI

/// A view that displays key system details such as OS version, model, storage, and memory.
struct SystemDetailsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("System Information")
                .font(.headline)
                .padding(.bottom, 4)
            
            HStack {
                Text("OS:")
                    .fontWeight(.semibold)
                Text(ProcessInfo.processInfo.operatingSystemVersionString)
            }
            
            HStack {
                Text("Model:")
                    .fontWeight(.semibold)
                Text("Coming soon") 
            }
            
            HStack {
                Text("Storage:")
                    .fontWeight(.semibold)
                Text(getTotalStorageInfo())
            }
            
            HStack {
                Text("Memory:")
                    .fontWeight(.semibold)
                Text(getMemoryInfo())
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.windowBackgroundColor))
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 3)
        )
    }
    
    /// Retrieves the total storage size as a formatted string.
    func getTotalStorageInfo() -> String {
        do {
            let attributes = try FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory())
            if let totalSize = attributes[.systemSize] as? NSNumber {
                let totalGB = Double(truncating: totalSize) / 1_000_000_000.0
                return String(format: "%.1f GB", totalGB)
            }
        } catch {
            return "N/A"
        }
        return "N/A"
    }
    
    /// Retrieves the physical memory size as a formatted string.
    func getMemoryInfo() -> String {
        let memoryBytes = ProcessInfo.processInfo.physicalMemory
        let memoryGB = Double(memoryBytes) / 1_000_000_000.0
        return String(format: "%.1f GB", memoryGB)
    }
}
