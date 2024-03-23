// Custom coordinator
import SwiftUI

class Coordinator: ObservableObject {
    func startButtonPressed() {
        guard let firstScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return
        }

        guard let firstWindow = firstScene.windows.first else {
            return
        }
        let viewController = firstWindow.rootViewController?.children[0] as? ViewController
        viewController?.startButtonPressed()
    }
}
