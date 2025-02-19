//
//  UsageGauge.swift
//  macMonitor
//
//  Created by Luis Amorim on 19/02/25.
//

import SwiftUI
import Charts
import AppKit

// MARK: - UsageGauge

/// A reusable gauge view that displays a metric as a compact circular gauge.
///
/// - Parameters:
///   - title: The title of the metric.
///   - value: The current value of the metric (0 to 100).
///   - color: The color used for the gauge.
///   - symbol: A system symbol name representing the metric.
struct UsageGauge: View {
    var title: String
    var value: Double
    var color: Color
    var symbol: String
    
    var body: some View {
        VStack(spacing: 8) {
            Gauge(value: value, in: 0...100) {
                Label("\(title) - \(Int(value))%", systemImage: symbol)
                    .font(.subheadline)
                    .bold()
            }
            .gaugeStyle(.accessoryLinearCapacity)
            .tint(color)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.windowBackgroundColor))
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 3)
        )
    }
}

// MARK: - MetricCard

/// A card view that displays a metric using `UsageGauge`. When tapped, it opens a detailed chart window.
///
/// - Parameters:
///   - title: The title of the metric.
///   - value: The current value of the metric.
///   - data: The historical data for the metric.
///   - color: The color for the gauge and chart.
///   - symbol: A system symbol representing the metric.
struct MetricCard: View {
    var title: String
    var value: Double
    var data: [Double]
    var color: Color
    var symbol: String
    
    var body: some View {
        UsageGauge(title: title, value: value, color: color, symbol: symbol)
            .onTapGesture {
                openChartDetailWindow(title: title, data: data, color: color)
            }
    }
}
