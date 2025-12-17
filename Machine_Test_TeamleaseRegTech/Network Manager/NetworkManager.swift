//
//  NetworkManager.swift
//  Machine_Test_TeamleaseRegTech
//
//  Created by Prajakta Prakash Jadhav on 17/12/25.
//

import Foundation
import UIKit
import Network

class NetworkGuard {

    static let shared = NetworkGuard()

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue.global(qos: .background)

    private(set) var isConnected: Bool = true
    private(set) var isMonitoringStarted = false

    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = (path.status == .satisfied)
            self?.isMonitoringStarted = true
        }
        monitor.start(queue: queue)
    }
}


class NetworkHelper {

    private static var isAlertShown = false

    static func performIfConnected(
        _ viewController: UIViewController,
        action: @escaping () -> Void
    ) {

        // Wait until monitor gives first status
        guard NetworkGuard.shared.isMonitoringStarted else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                performIfConnected(viewController, action: action)
            }
            return
        }

        if !NetworkGuard.shared.isConnected {
            DispatchQueue.main.async {
                guard !isAlertShown else { return }
                isAlertShown = true

                let alert = UIAlertController(
                    title: "No Internet",
                    message: "Please check your mobile data or Wi-Fi settings.",
                    preferredStyle: .alert
                )

                alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                    isAlertShown = false
                })

                viewController.present(alert, animated: true)
            }
            return
        }

        action()
    }
}

