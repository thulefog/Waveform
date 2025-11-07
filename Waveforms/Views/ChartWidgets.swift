//
// InteractiveFunctionPlot
//
// Reference Apple Sample Code here:
// https://developer.apple.com/documentation/Charts/creating-a-data-visualization-dashboard-with-swift-charts
//
// Abstract:
// A chart that supports dragging and displaying `LinePlot`'s value.
//
// Reference below for some 2021 experiments with the Charts framework
// LineGraph, LineView, ChartView


import SwiftUI
import Charts

struct InteractiveFunctionPlot: View {
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
            
            Chart {
                RuleMark(x: .value("Y axis", 0))
                    .foregroundStyle(Color.secondary)
                RuleMark(y: .value("X axis", 0))
                    .foregroundStyle(Color.secondary)

                let samplingDomainLowerBound = minX
                let samplingDomainUpperBound: Double = {
                    let elapsedTime = context.date.timeIntervalSince(onAppearDate)
                    let progress = max(0, min(1, elapsedTime / animationDuration))
                    let currentMaxX = minX.interpolated(towards: maxX, amount: progress)
                    return currentMaxX
                }()
 /*
                LinePlot(
                    timeSeries,
                    x: .value("Index", \.timeOffset),
                    y: .value("Value", \.yValue),
                    series: .value("Value", \.symbol)
                )
                .foregroundStyle(by: .value("Value", \.symbol))

                
                ForEach(timeSeries) { point in
                    LineMark(
                        x: .value("X-Value", point.timeOffset),
                        y: .value("Y-Value", point.yValue)
                    )
                }
  */
                
                LinePlot(
                    x: "x", y: "y",
                    domain: samplingDomainLowerBound...samplingDomainUpperBound
                ) { x in
                    sin(x)
                }
                .lineStyle(StrokeStyle(lineWidth: 2))
                
                if let selectedX, selectedX <= samplingDomainUpperBound {
                    let actualY = sin(selectedX)
                    PointMark(
                        x: .value("X", selectedX),
                        y: .value("Y", actualY)
                    )
                    .annotation {
                        Text("(\(selectedX, format: .number.precision(.fractionLength(2))), \(actualY, format: .number.precision(.fractionLength(2))))")
                            .monospaced()
                    }
                }
                
            }
            .chartXAxisLabel("X-Axis Label")
            .chartYAxisLabel("Y-Axis Label")
            .navigationTitle("Simple Line Plot")

            .chartXScale(domain: minX ... maxX)
            .chartYScale(domain: minY ... maxY)
            .chartXSelection(value: $selectedX)
            .chartPlotStyle { content in
                content
                    .aspectRatio(2, contentMode: .fit)
                    .clipped()
            }
        }
        .onAppear {
            onAppearDate = .now
        }
    }
}

/*
    InteractiveFunctionPlot(data: providerAdapter.data )


    LineView(data: [0.1, 2.0, 3.0, 4.0 ], title: "SERIES" )
        .padding()
 
    ChartView(xStepValue: 1, yStepValue: 8)
 

    LineGraph(dataPoints: sampleData)
      .trim(to: on ? 1 : 0)
      .stroke(Color.gray, lineWidth: 2)
      .aspectRatio(16/9, contentMode: .fit)
      .border(Color.gray, width: 1)
      .background(Color.black)
      .padding()
      .onTapGesture{
          self.update.toggle() //--> struct ContentView: View { @State private var update = false
      }
    Button("Animate") {
      withAnimation(.easeInOut(duration: 2)) {
          self.on.toggle() // --> struct ContentView: View { @State var on = true
      }
    }
*/

struct LineGraph: Shape {
    var dataPoints: [CGFloat]

    func path(in rect: CGRect) -> Path {
        func point(at ix: Int) -> CGPoint {
            let point = dataPoints[ix]
            let x = rect.width * CGFloat(ix) / CGFloat(dataPoints.count - 1)
            let y = (1-point) * rect.height
            return CGPoint(x: x, y: y)
        }

        return Path { p in
            guard dataPoints.count > 1 else { return }
            let start = dataPoints[0]
            p.move(to: CGPoint(x: 0, y: (1-start) * rect.height))
            for idx in dataPoints.indices {
                p.addLine(to: point(at: idx))
            }
        }
    }
}


struct LineView: View {
    var data: [(Double)]
    var title: String?

    public init(data: [Double],
                title: String? = nil) {
        
        self.data = data
        self.title = title
    }
    
    public var body: some View {
        GeometryReader{ geometry in
            VStack(alignment: .leading, spacing: 8) {
                Group{
                    if (self.title != nil){
                        Text(self.title!)
                            .font(.title)
                            .background(Color.gray)
                            .foregroundColor(.white)
                    }
                }.offset(x: 0, y: 0)
                ZStack{
                    GeometryReader{ reader in
                        Line(data: self.data,
                             frame: .constant(CGRect(x: 0, y: 0, width: reader.frame(in: .local).width , height: reader.frame(in: .local).height))
                        )
                            .offset(x: 0, y: 0)
                    }
                    .frame(width: geometry.frame(in: .local).size.width, height: 200)
                    .offset(x: 0, y: -100)

                }
                .frame(width: geometry.frame(in: .local).size.width, height: 200)
        
            }
        }
    }
}

struct LineView_Previews: PreviewProvider {
    static var previews: some View {
        LineView(data: [8,23,54,32,12,37,7,23,43], title: "Full chart")
    }
}

struct Line: View {
    var data: [(Double)]
    @Binding var frame: CGRect

    let padding:CGFloat = 30
    
    var stepWidth: CGFloat {
        if data.count < 2 {
            return 0
        }
        return frame.size.width / CGFloat(data.count-1)
    }
    var stepHeight: CGFloat {
        var min: Double?
        var max: Double?
        let points = self.data
        if let minPoint = points.min(), let maxPoint = points.max(), minPoint != maxPoint {
            min = minPoint
            max = maxPoint
        }else {
            return 0
        }
        if let min = min, let max = max, min != max {
            if (min <= 0){
                return (frame.size.height-padding) / CGFloat(max - min)
            }else{
                return (frame.size.height-padding) / CGFloat(max + min)
            }
        }
        
        return 0
    }
    var path: Path {
        let points = self.data
        return Path.lineChart(points: points, step: CGPoint(x: stepWidth, y: stepHeight))
    }
    
    public var body: some View {
        
        ZStack {

            self.path
                .stroke(Color.green ,style: StrokeStyle(lineWidth: 3, lineJoin: .round))
                .rotationEffect(.degrees(180), anchor: .center)
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                .drawingGroup()
        }
    }
}

extension Path {
    
    static func lineChart(points:[Double], step:CGPoint) -> Path {
        var path = Path()
        if (points.count < 2){
            return path
        }
        guard let offset = points.min() else { return path }
        let p1 = CGPoint(x: 0, y: CGFloat(points[0]-offset)*step.y)
        path.move(to: p1)
        for pointIndex in 1..<points.count {
            let p2 = CGPoint(x: step.x * CGFloat(pointIndex), y: step.y*CGFloat(points[pointIndex]-offset))
            path.addLine(to: p2)
        }
        return path
    }
}


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
