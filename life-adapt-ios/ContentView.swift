import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello Life Adapt")
            Spacer().frame(height:300)
            HStack {
                ButtonView().padding()
            }
            MyViewControllerRepresentable()
        }
        .padding()
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
