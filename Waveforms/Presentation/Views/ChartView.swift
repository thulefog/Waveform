//
//  ChartView.swift
//  Waveforms
//
//  Created by John Matthew Weston on 11/14/21.
//

import Foundation
import SwiftUI

struct Point {
    let x: CGFloat
    let y: CGFloat
}


struct ChartView: View {
    let xStepValue: CGFloat
    let yStepValue: CGFloat
    //let data: [Point]
    let data: [Point] = [
        .init(x: 1, y: 5),
        .init(x: 2, y: 4),
        .init(x: 3, y: 15),
        .init(x: 4, y: 6),
        .init(x: 5, y: 9),
        .init(x: 6, y: 12),
        .init(x: 7, y: 14),
        .init(x: 8, y: 11)
    ]
    
    private var maxYValue: CGFloat {
        data.max { $0.y < $1.y }?.y ?? 0
    }
    
    private var maxXValue: CGFloat {
        data.max { $0.x < $1.x }?.x ?? 0
    }
    
    private var xStepsCount: Int {
        Int(self.maxXValue / self.xStepValue)
    }
    
    private var yStepsCount: Int {
        Int(self.maxYValue / self.yStepValue)
    }
    
    var body: some View {
        ZStack {
            gridBody
            chartBody
        }
    }
    private var gridBody: some View {
        GeometryReader { geometry in
            Path { path in
                let xStepWidth = geometry.size.width / CGFloat(self.xStepsCount)
                let yStepWidth = geometry.size.height / CGFloat(self.yStepsCount)
                
                // Y axis lines
                (1...self.yStepsCount).forEach { index in
                    let y = CGFloat(index) * yStepWidth
                    path.move(to: .init(x: 0, y: y))
                    path.addLine(to: .init(x: geometry.size.width, y: y))
                }
                
                // X axis lines
                (1...self.xStepsCount).forEach { index in
                    let x = CGFloat(index) * xStepWidth
                    path.move(to: .init(x: x, y: 0))
                    path.addLine(to: .init(x: x, y: geometry.size.height))
                }
            }
            .stroke(Color.gray)
        }
    }
    private var chartBody: some View {
        GeometryReader { geometry in
            Path { path in
                path.move(to: .init(x: 0, y: geometry.size.height))
                self.data.forEach { point in
                    let x = (point.x / self.maxXValue) * geometry.size.width
                    let y = geometry.size.height - (point.y / self.maxYValue) * geometry.size.height
                    
                    path.addLine(to: .init(x: x, y: y))
                }
            }
            .stroke(
                Color.green,
                style: StrokeStyle(lineWidth: 3)
            )
        }
    }
}
