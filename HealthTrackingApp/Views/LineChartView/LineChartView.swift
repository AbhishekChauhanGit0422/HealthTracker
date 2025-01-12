//
//  LineChartView.swift
//  HealthTrackingApp
//
//  Created by Abhishek on 12/01/25.
//


import SwiftUI
import Charts

struct LineChartView: View {
    var metrics: [HealthTracking]
    var filterType: String?
    var markerDate: Date? = nil // Optional date for the vertical line
    
    var body: some View {
        Chart {
            if let filterType = filterType, filterType != "All" {
                // Single type selected
                ForEach(metrics.filter { $0.name == filterType }, id: \.timeStamp) { metric in
                    LineMark(
                        x: .value("Time", metric.timeStamp ?? Date(), unit: .hour),
                        y: .value("Value", metric.value)
                    )
                    .foregroundStyle(.blue.gradient)
                    .lineStyle(StrokeStyle(lineWidth: 3))
                    .symbol(Circle())
                    .symbolSize(50)
                    .interpolationMethod(.catmullRom)
                }
            } else {
                // All metrics
                let types = ["Steps", "Heart Rate", "Water Intake"]
                let colors: [Color] = [.red, .blue, .green]
                
                ForEach(types.indices, id: \.self) { index in
                    ForEach(metrics.filter { $0.name == types[index] }, id: \.timeStamp) { metric in
                        LineMark(
                            x: .value("Time", metric.timeStamp ?? Date(), unit: .hour),
                            y: .value("Value", metric.value)
                        )
                        .lineStyle(StrokeStyle(lineWidth: 2))
                        .foregroundStyle(colors[index].gradient)
                        .symbol(Circle())
                        .symbolSize(50)
                        .interpolationMethod(.catmullRom)
                    }
                }
            }
            
            // Add a vertical line
            if let markerDate = markerDate {
                RuleMark(x: .value("Marker", markerDate, unit: .hour))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5])) // Dashed line
            }
        }
        .frame(height: 150)
        .chartXAxis {
            AxisMarks(values: .stride(by: .hour)) { value in
                AxisGridLine() // Show grid lines for X-axis
                    .foregroundStyle(.gray.opacity(0.2))
                AxisTick()
                AxisValueLabel(format: .dateTime.hour(.defaultDigits(amPM: .abbreviated)))
            }
        }
        .chartYAxis {
            AxisMarks { value in
                AxisGridLine() // Show grid lines for Y-axis
                    .foregroundStyle(.gray.opacity(0.2))
                AxisTick()
                AxisValueLabel()
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(Color(UIColor.systemGray6)))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
        )
    }
}


