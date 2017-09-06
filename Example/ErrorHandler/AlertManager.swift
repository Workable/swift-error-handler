//
//  AlertManager.swift
//  Example-iOS
//
//  Created by Eleni Papanikolopoulou on 05/08/2017.
//  Copyright © 2017 Workable. All rights reserved.
//

import UIKit

extension UIApplication {
    class func topVC() -> UIViewController {
        // cheating, I know
        // Normally if you want the handler to have state you should subclass it.
        return UIApplication.shared.keyWindow!.rootViewController!
    }
}

extension UIAlertController {
    func show() {
        DispatchQueue.main.async {
            UIApplication.topVC().present(self, animated: true, completion: nil)
        }
    }
}

class AlertManager {
    class func showAlert(title: String = "", message: String = "") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(defaultAction)
        alert.show()
    }
}
