//
//  ContentView.swift
//  macMonitor
//
//  Created by Luis Amorim on 19/02/25.
//

import SwiftUI
import Charts
import AppKit

/**
 Opens a new window displaying a detailed chart for the selected metric.

 The window is configured with rounded corners, a hidden title bar, and can be moved by dragging the content area.

 - Parameters:
    - title: The title for the chart window.
    - data: The historical data to be displayed in the chart.
    - color: The color used in the chart.
 */
func openChartDetailWindow(title: String, data: [Double], color: Color) {
    let window = NSWindow(
        contentRect: NSRect(x: 0, y: 0, width: 500, height: 300),
        styleMask: [.closable, .miniaturizable],
        backing: .buffered,
        defer: false
    )
    window.center()
    
    // Allow transparency for rounded corners
    window.isOpaque = false
    window.backgroundColor = NSColor.clear
    
    // Hide the title and make the title bar transparent
    window.titleVisibility = .hidden
    window.titlebarAppearsTransparent = true
    
    // Allow moving the window by dragging its content area
    window.isMovableByWindowBackground = true
    
    // Inject the window reference into the ChartCell view.
    let chartCellView = ChartCell(title: title, color: color)
        .environment(\.nsWindow, window)
    let hostingView = NSHostingView(rootView: chartCellView)
    
    // Enable layer-backed view for corner rounding
    hostingView.wantsLayer = true
    // Set a solid background color for the content so the rounding is visible.
    hostingView.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
    hostingView.layer?.cornerRadius = 10
    hostingView.layer?.masksToBounds = true
    
    window.contentView = hostingView
    window.makeKeyAndOrderFront(nil)
}
/// A view that displays an elegant dashboard for live system monitoring data.
///
/// The dashboard includes gauge indicators for current metrics, a system information card, and animated trend charts
/// for CPU, RAM, Disk, and Battery usage. A gradient background, refined typography, and soft shadows help create
/// a modern and polished appearance. The window size is fixed.
struct ContentView: View {
    @StateObject var viewModel = SystemInfoViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 10) {
                // System details card with fixed width
                SystemDetailsView()
                    .frame(width: 250)
                    .layoutPriority(1)
                
                // Container for metric gauges that expands to occupy remaining space
                HStack(spacing: 20) {
                    VStack(spacing: 10) {
                        UsageGauge(title: "CPU",
                                   value: viewModel.cpuHistory.last ?? 0,
                                   color: .blue,
                                   symbol: "cpu")
                            .contentShape(Rectangle())
                            .onTapGesture {
                                print("CPU gauge tapped")
                                openChartDetailWindow(title: "CPU", data: viewModel.cpuHistory, color: .blue)
                            }
                        
                        UsageGauge(title: "RAM",
                                   value: viewModel.ramHistory.last ?? 0,
                                   color: .red,
                                   symbol: "memorychip")
                            .contentShape(Rectangle())
                            .onTapGesture {
                                print("RAM gauge tapped")
                                openChartDetailWindow(title: "RAM", data: viewModel.ramHistory, color: .red)
                            }
                    }
                    
                    VStack(spacing: 10) {
                        UsageGauge(title: "Disk",
                                   value: viewModel.diskUsage,
                                   color: .yellow,
                                   symbol: "internaldrive")
                            .contentShape(Rectangle())
                            .onTapGesture {
                                print("Disk gauge tapped")
                                // Se possível, forneça um histórico de valores para Disk
                                let diskData = viewModel.diskHistory.isEmpty ? [viewModel.diskUsage] : viewModel.diskHistory
                                openChartDetailWindow(title: "Disk", data: diskData, color: .yellow)
                            }
                        
                        UsageGauge(title: "Battery",
                                   value: viewModel.batteryPercentage,
                                   color: .green,
                                   symbol: viewModel.batteryIsCharging ? "battery.100.bolt" : "battery.100")
                            .contentShape(Rectangle())
                            .onTapGesture {
                                print("Battery gauge tapped")
                                // Se possível, forneça um histórico de valores para Battery
                                let batteryData = viewModel.batteryHistory.isEmpty ? [viewModel.batteryPercentage] : viewModel.batteryHistory
                                openChartDetailWindow(title: "Battery", data: batteryData, color: .green)
                            }
                    }
                }
                .frame(maxWidth: .infinity)
                .layoutPriority(2)
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical)
        .background(
            LinearGradient(gradient: Gradient(colors: [Color("BackgroundStart"), Color("BackgroundEnd")]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
        )
    }
}

#Preview {
    ContentView()
}
