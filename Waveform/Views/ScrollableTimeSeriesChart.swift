//
//  ScrollableTimeSeriesChart.swift
//  Waveform
//
//  Created by John Matthew Weston on 11/7/25.
//

import SwiftUI
import Charts

struct DataPoint: Identifiable {
    let id = UUID()
    let timestamp: Date
    let yValue: Double
    let timeOffset: Double
}

struct ScrollableTimeSeriesChart: View {
    //..
    let data : [CGFloat]
    
    private let minX = -10.0
    private let maxX = 10.0
    private let minY = -4.0
    private let maxY = 4.0

    // Animating in
    @State private var onAppearDate: Date = .now

    // Selection
    @State private var selectedX: Double?

    //..
    private var timeSeries: [DataPoint] {

        let anchorTimeStamp = Date()
        return data.enumerated().map { index, value in
            let timeOffset = Double(index)
            let timestamp = anchorTimeStamp.addingTimeInterval(timeOffset)
            
            return DataPoint(
                timestamp: timestamp,
                yValue: value,
                timeOffset: timeOffset
            )
        }
    }

    var body: some View {
        TimelineView(.animation) { context in
            let animationDuration = 1.5

            VStack{
                ScrollView{

                    Chart(timeSeries) { dataPoint in
                        LineMark(
                            x: .value("Index", dataPoint.timeOffset),
                            y: .value("Value", dataPoint.yValue)
                        )
                        .foregroundStyle(Color.red)
                        .lineStyle(StrokeStyle(lineWidth: 1.5))
                    }
                    .frame(height: 300)
                    .chartXAxis {
                        AxisMarks(position: .bottom) { _ in
                            AxisGridLine()
                            AxisTick()
                            AxisValueLabel()
                        }
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading) { _ in
                            AxisGridLine()
                            AxisTick()
                            AxisValueLabel()
                        }
                    }
                    .chartXAxisLabel("Index")
                    .chartYAxisLabel("Value")
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal, 4)
                    //..
                    .chartScrollableAxes(.horizontal)
                    //NB: chartXVisibleDomain appears to truncate
                } // ScrollView
            }
            .preferredColorScheme(.dark)
            .navigationTitle("Time Series")
        }
        .onAppear {
            onAppearDate = .now
        }
    }
}
