// Custom controller to handle button behaviors, rest calls and chart plotting
import UIKit
import CoreMotion
import DGCharts

class ViewController: UIViewController {
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var chartView: LineChartView!
    
    let motionManager = CMMotionManager()
    var count = 0
    var accelerometerDataX: [Double] = []
    var accelerometerDataY: [Double] = []
    var accelerometerDataZ: [Double] = []
    var isCollectingData = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func startButtonPressed() {
        isCollectingData.toggle()
        if isCollectingData {
            startAccelerometerUpdates()
        } else {
            stopAccelerometerUpdates()
        }
    }
    
    func startAccelerometerUpdates() {
        if isCollectingData {
            if motionManager.isAccelerometerAvailable {
                motionManager.accelerometerUpdateInterval = 1.0 / 50.0 // 50 Hz
                motionManager.startAccelerometerUpdates(to: .main) { [weak self] (data, error) in
                    guard let accelerometerData = data else { return }
                    let acceleration = accelerometerData.acceleration
                    self?.accelerometerDataX.append(acceleration.x)
                    self?.accelerometerDataY.append(acceleration.y)
                    self?.accelerometerDataZ.append(acceleration.z)
                    // Upload data to Amplify every 5 seconds (it takes 5 seconds to receive 250 updates at a frequency of 50 Hz)
                    if self?.accelerometerDataX.count ?? 0 >= 250 {
                        self?.stopAccelerometerUpdates() // Stop updates temporarily
                        self?.uploadDataToAmplify()
                    }
                }
            }
        }
    }
    
    func stopAccelerometerUpdates() {
        motionManager.stopAccelerometerUpdates()
    }
    
    func plotData(accelerometerDataX: [Double], accelerometerDataY: [Double], accelerometerDataZ: [Double]) {
        motionManager.stopAccelerometerUpdates()
        UserDefaults.standard.set(accelerometerDataX, forKey: "accelerometerDataX")
        UserDefaults.standard.set(accelerometerDataY, forKey: "accelerometerDataY")
        UserDefaults.standard.set(accelerometerDataZ, forKey: "accelerometerDataZ")
        NotificationCenter.default.post(name: .updateChartData, object: nil)
    }
    
    func uploadDataToAmplify() {
        self.count+=1
        // Print the first element of each list with customized messages
        print("The first element of X: \(accelerometerDataX.first ?? 0)")
        print("The first element of Y: \(accelerometerDataY.first ?? 0)")
        print("The first element of Z: \(accelerometerDataZ.first ?? 0)")
        print("Upload count", count)
        // POST Call
        guard let url = URL(string: "https://jadjp86fqj.execute-api.us-east-1.amazonaws.com/staging/accelerometer") else {
            print("Invalid URL")
            return
        }
        let json: [String: Any] = [
            "accelerometerX": accelerometerDataX,
            "accelerometerY": accelerometerDataY,
            "accelerometerZ": accelerometerDataZ
        ]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error: \(error)")
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Invalid response")
                    return
                }
                if httpResponse.statusCode == 200 {
                    guard let responseData = data else {
                        print("No response data")
                        return
                    }
                    print("Data uploaded successfully")
                    // Reading the response
                    do {
                        let jsonResponse = try JSONSerialization.jsonObject(with: responseData, options: [])
                        if let data = jsonResponse as? [String: Any],
                           let accelerometerDataX = data["accelerometerX"] as? [Double],
                           let accelerometerDataY = data["accelerometerY"] as? [Double],
                           let accelerometerDataZ = data["accelerometerZ"] as? [Double] {
                            DispatchQueue.main.async {
                                // Call plotData with the returned accelerometer data (that are the same than being posted.
                                // The lambda is returning directly what has been sent.
                                self.plotData(accelerometerDataX: accelerometerDataX, accelerometerDataY: accelerometerDataY, accelerometerDataZ: accelerometerDataZ)
                            }
                        } else {
                            print("Error: Invalid response format")
                        }
                    } catch {
                        print("Error deserializing JSON response: \(error)")
                    }
                } else {
                    print("HTTP status code: \(httpResponse.statusCode)")
                }
            }
            task.resume()
        } catch {
            print("Error serializing JSON: \(error)")
        }
        // Clear after upload
        self.accelerometerDataX.removeAll()
        self.accelerometerDataY.removeAll()
        self.accelerometerDataZ.removeAll()
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
            self?.startAccelerometerUpdates() // Resume updates after 5 seconds
        }
    }
}
