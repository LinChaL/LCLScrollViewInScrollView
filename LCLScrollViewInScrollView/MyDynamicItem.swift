//
//  MyDynamicItem.swift
//  refreshTest
//
//  Created by linchl on 2018/11/1.
//  Copyright © 2018年 linchl. All rights reserved.
//

import Foundation
import UIKit

class MyDynamicItem: NSObject, UIDynamicItem {
    var center: CGPoint = .zero
    
    var bounds: CGRect = CGRect(x: 0, y: 0, width: 1, height: 1)
    
    var transform: CGAffineTransform
    
    override init() {
        transform = CGAffineTransform()
        super.init()
    }
}
