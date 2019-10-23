//
//  Extensions.swift
//  HubPod
//
//  Created by Leonardo Saganski on 25/09/19.
//  Copyright © 2019 ItauBBA. All rights reserved.
//

import Foundation

//
// MARK: - UIView -
extension UIView {
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
}

//
// MARK: - UIColor -
extension UIColor {
    static let itauOrange = UIColor(hex: "#F7A128FF") ?? .orange
    static let itauLightGray = UIColor(hex: "#E5E5E5FF") ?? .lightGray
    static let itauGray = UIColor(hex: "#ACACACFF") ?? .gray
    static let itauDarkGray = UIColor(hex: "#6E6E6EFF") ?? .gray
    static let itauBlue = UIColor(hex: "#004A79FF") ?? .blue
    
    public convenience init?(hex: String) {
        let red, green, blue, alpha: CGFloat
        
        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])
            
            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    red = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    green = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    blue = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    alpha = CGFloat(hexNumber & 0x000000ff) / 255
                    
                    self.init(red: red, green: green, blue: blue, alpha: alpha)
                    return
                }
            }
        }
        
        return nil
    }
}
