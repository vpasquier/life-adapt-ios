import UIKit
import CoreMotion
import DGCharts

class ViewController: UIViewController {
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var chartView: LineChartView!
    
    let motionManager = CMMotionManager()
    var accelerometerData: [Double] = []
    var isCollectingData = false // Track whether data collection is ongoing
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func startButtonPressed() {
        if isCollectingData {
            stopAccelerometerUpdates()
        } else {
            startAccelerometerUpdates()
        }
        isCollectingData.toggle()
    }
    
    func startAccelerometerUpdates() {
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 1.0 / 50.0 // 50 Hz
            motionManager.startAccelerometerUpdates(to: .main) { [weak self] (data, error) in
                guard let accelerometerData = data else { return }
                let acceleration = accelerometerData.acceleration
                let magnitude = sqrt(pow(acceleration.x, 2) + pow(acceleration.y, 2) + pow(acceleration.z, 2))
                self?.accelerometerData.append(magnitude)
                
                // Upload data to Amplify every 5 seconds
                if self?.accelerometerData.count ?? 0 >= 250 {
                    self?.stopAccelerometerUpdates() // Stop updates temporarily
                    self?.uploadDataToAmplify()
                }
            }
        }
    }
    
    func stopAccelerometerUpdates() {
        motionManager.stopAccelerometerUpdates()
    }
    
    func uploadDataToAmplify() {
        // Code to upload accelerometerData to Amplify
        print("The data are self.accelerometerData", self.accelerometerData)
        self.accelerometerData.removeAll() // Clear data after upload
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
            self?.startAccelerometerUpdates() // Resume updates after 5 seconds
        }
    }
}
