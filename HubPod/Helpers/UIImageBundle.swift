//
//  UIImageBundle.swift
//  Core
//
//  Created by Jonas de Castro Leitão on 18/09/19.
//  Copyright © 2019 Itau. All rights reserved.
//

import UIKit

public extension UIImage {
    
    convenience init?<C: AnyObject>(name: String, bundleOf object: C) {
        self.init(named: name, in: Bundle(for: type(of: object)), compatibleWith: nil)
    }
}
