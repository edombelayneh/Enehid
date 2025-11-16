//
//  TextField+Theme.swift
//  Enehid
//
//  Created by Edom Belayneh on 11/13/25.
//

import UIKit

extension UITextField {
    func applyEnehidTFStyle() {
        self.backgroundColor = UIColor(named: "CreamBackground")
        self.textColor = UIColor(named: "TextPrimary")
        self.layer.cornerRadius = 10
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor(named: "TextButton")?.cgColor
        self.setLeftPaddingPoints(12)
        self.setRightPaddingPoints(12)
        self.font = UIFont.systemFont(ofSize: 16, weight: .regular)
    }

    // Add padding (optional but improves UX)
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }

    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}

