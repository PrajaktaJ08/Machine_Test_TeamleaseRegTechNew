//
//  Extensions.swift
//  Machine_Test_TeamleaseRegTech
//
//  Created by Prajakta Prakash Jadhav on 17/12/25.
//

import Foundation
import UIKit

extension UIView {

    func applyCornerRadius(_ radius: CGFloat,
                            borderWidth: CGFloat = 0,
                            borderColor: UIColor = .clear,
                            masksToBounds: Bool = true) {

        self.layer.cornerRadius = radius
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor.cgColor
        self.layer.masksToBounds = masksToBounds
    }
    
    func applyBorder(
        color: UIColor = .separator,
        width: CGFloat = 1,
        cornerRadius: CGFloat = 6
    ) {
        layer.borderColor = color.cgColor
        layer.borderWidth = width
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = true
    }
}
