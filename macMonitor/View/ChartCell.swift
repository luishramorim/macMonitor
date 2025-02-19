//
//  ChartCell.swift
//  macMonitor
//
//  Created by Luis Amorim on 19/02/25.
//

import SwiftUI
import Charts

/// A reusable view representing a single trend chart cell with a header and an animated area chart.
///
/// The view dynamically selects an icon based on the provided title. For example, if the title is "Battery",
/// it shows a dynamic battery icon based on the battery percentage from `SystemInfoViewModel` and, if the battery
/// is charging, a variant with o symbol bolt.
///
/// An "X" button is displayed in the top-right corner to close the current window.
///
/// The chart displays the historical data obtained from the view model.
///
/// - Parameters:
///   - title: The title displayed above the chart (e.g., "Battery", "Disk", "CPU", "RAM").
///   - color: The color used for the area fill and line.
struct ChartCell: View {
    var title: String
    var color: Color

    // Use the view model provided from the environment
    @StateObject var viewModel = SystemInfoViewModel()
    @Environment(\.nsWindow) var nsWindow: NSWindow?  // Reference to the current window

    /// Returns the historical data for the given metric based on the title.
    private var currentData: [Double] {
        switch title.lowercased() {
        case "battery": return viewModel.batteryHistory
        case "cpu": return viewModel.cpuHistory
        case "ram": return viewModel.ramHistory
        case "disk": return viewModel.diskHistory
        default: return []
        }
    }
    
    /// Computes the appropriate SF Symbol icon name based on the title and system info.
    private var iconName: String {
        if title.lowercased() == "battery" {
            let level = viewModel.batteryPercentage
            if viewModel.batteryIsCharging {
                // Use charging icon variant
                if level > 80 {
                    return "battery.100.bolt"
                } else if level > 60 {
                    return "battery.75.bolt"
                } else if level > 40 {
                    return "battery.50.bolt"
                } else if level > 20 {
                    return "battery.25.bolt"
                } else {
                    return "battery.0.bolt"
                }
            } else {
                if level > 80 {
                    return "battery.100"
                } else if level > 60 {
                    return "battery.75"
                } else if level > 40 {
                    return "battery.50"
                } else if level > 20 {
                    return "battery.25"
                } else {
                    return "battery.0"
                }
            }
        } else {
            switch title.lowercased() {
            case "disk":
                return "internaldrive"
            case "cpu":
                return "cpu"
            case "ram":
                return "memorychip"
            default:
                return "questionmark.circle"
            }
        }
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 8) {
                // Header com ícone dinâmico e título
                HStack {
                    Image(systemName: iconName)
                        .renderingMode(.original)
                    Text(title)
                }
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.leading, 8)
                .padding(.bottom, 10)
                
                // Chart exibindo os dados históricos
                Chart {
                    let dataPoints = currentData
                    let count = dataPoints.count
                    let baseTime = Date().addingTimeInterval(-Double(count))
                    
                    ForEach(Array(dataPoints.enumerated()), id: \.offset) { index, value in
                        let time = baseTime.addingTimeInterval(Double(index))
                        let clampedValue = min(max(value, 0), 100)
                        
                        AreaMark(
                            x: .value("Time", time),
                            y: .value(title, clampedValue)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(color.opacity(0.5))
                        
                        LineMark(
                            x: .value("Time", time),
                            y: .value(title, clampedValue)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(color)
                    }
                }
                .chartYScale(domain: 0...100)
                .chartXAxis {
                    AxisMarks(values: .automatic(desiredCount: 4)) { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let date = value.as(Date.self) {
                                Text(date, format: .dateTime.hour().minute().second())
                            }
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks { _ in
                        AxisGridLine()
                        AxisValueLabel()
                    }
                }
                .frame(height: 130)
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color(.windowBackgroundColor))
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 3)
                )
            }
            .padding(10)
            
            // Botão "X" no canto superior direito para fechar a janela atual.
            Button(action: {
                nsWindow?.close()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondary)
                    .font(.title3)
                    .padding(8)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

#Preview {
    ChartCell(
        title: "Battery",
        color: .red
    )
    .environmentObject(SystemInfoViewModel())
}
