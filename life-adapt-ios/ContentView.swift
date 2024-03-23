// Main view
import SwiftUI
import DGCharts

struct ContentView: View {
    @State private var accelerometerDataX: [Double] = []
    @State private var accelerometerDataY: [Double] = []
    @State private var accelerometerDataZ: [Double] = []
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Spacer()
            Text("Hello Life Adapt")
            Spacer().frame(height:100)
            ButtonView().padding()
            ChartView(accelerometerDataX: $accelerometerDataX,
                      accelerometerDataY: $accelerometerDataY,
                      accelerometerDataZ: $accelerometerDataZ)
            MyViewControllerRepresentable()
        }
        .padding()
        .onReceive(NotificationCenter.default.publisher(for: .updateChartData)) { _ in
            if let updatedDataX = UserDefaults.standard.array(forKey: "accelerometerDataX") as? [Double],
               let updatedDataY = UserDefaults.standard.array(forKey: "accelerometerDataY") as? [Double],
               let updatedDataZ = UserDefaults.standard.array(forKey: "accelerometerDataZ") as? [Double] {
                self.accelerometerDataX = updatedDataX
                self.accelerometerDataY = updatedDataY
                self.accelerometerDataZ = updatedDataZ
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct MyViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        return ViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    }
}

// ButtonView to control accelerometer data collection
struct ButtonView: View {
    @EnvironmentObject var coordinator: Coordinator
    @State private var isCollectingData = false // Track whether data collection is ongoing
    
    var body: some View {
        Button(action: {
            coordinator.startButtonPressed()
            self.isCollectingData.toggle()
        }) {
            Text(isCollectingData ? "Stop Data Collection" : "Start Data Collection")
                .padding()
                .foregroundColor(.white)
                .background(isCollectingData ? Color.red : Color.blue)
                .cornerRadius(10)
        }
    }
}

struct ChartView: UIViewRepresentable {
    @Binding var accelerometerDataX: [Double]
    @Binding var accelerometerDataY: [Double]
    @Binding var accelerometerDataZ: [Double]
    
    func makeUIView(context: Context) -> LineChartView {
        let chartView = LineChartView()
        // Customize chart appearance
        chartView.legend.enabled = true
        chartView.legend.textColor = .white
        
        // Customize x-axis
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelTextColor = .white
        xAxis.axisLineColor = .white
        
        // disable right axis
        chartView.rightAxis.enabled = false
        
        // Customize y-axis
        let leftAxis = chartView.leftAxis
        leftAxis.labelTextColor = .white
        leftAxis.axisLineColor = .white
        
        // Customize axis range
        leftAxis.axisMinimum = -1.0 // Set custom minimum value for y-axis
        leftAxis.axisMaximum = 1.0 // Set custom maximum value for y-axis
        xAxis.axisMinimum = 0 // Set minimum value for x-axis
        xAxis.axisMaximum = 250 // Set maximum value for x-axis
        xAxis.granularity = 1
        
        // Create line styles for each axis
        let xAxisStyle = createLineStyle(color: .orange, data:accelerometerDataX, label: "X Axis Data")
        let yAxisStyle = createLineStyle(color: .blue, data: accelerometerDataY,  label: "Y Axis Data")
        let zAxisStyle = createLineStyle(color: .green, data: accelerometerDataZ,  label: "Z Axis Data")
        
        chartView.data = LineChartData(dataSets: [xAxisStyle, yAxisStyle, zAxisStyle])
        
        return chartView
    }
    
    func updateUIView(_ uiView: LineChartView, context: Context) {
        // Create line styles for each axis
        let xAxisStyle = createLineStyle(color: .orange, data:accelerometerDataX, label: "X Axis Data")
        let yAxisStyle = createLineStyle(color: .blue, data: accelerometerDataY,  label: "Y Axis Data")
        let zAxisStyle = createLineStyle(color: .green, data: accelerometerDataZ,  label: "Z Axis Data")
        
        uiView.data = LineChartData(dataSets: [xAxisStyle, yAxisStyle, zAxisStyle])
    }
    
    private func createLineStyle(color: UIColor, data: [Double], label: String) -> LineChartDataSet {
        let entries = data.enumerated().map { ChartDataEntry(x: Double($0.offset), y: $0.element) }
        let dataSet = LineChartDataSet(entries: entries, label: label)
        dataSet.colors = [color]
        dataSet.circleColors = [color]
        dataSet.circleHoleColor = color
        dataSet.circleRadius = 4
        dataSet.mode = .cubicBezier
        dataSet.lineWidth = 2
        dataSet.drawValuesEnabled = false
        
        return dataSet
    }
}
