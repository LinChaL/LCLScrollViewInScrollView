//
//  UIViewController+.swift
//  refreshTest
//
//  Created by linchl on 2018/10/26.
//  Copyright © 2018年 linchl. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func addLifeCycle(to parent: UIViewController, addSubviewBlock: ((UIViewController) -> Void)? = nil) {
        parent.addChild(self)
        self.beginAppearanceTransition(true, animated: false)
        if let block = addSubviewBlock {
            block(self)
        } else {
            parent.view.addSubview(self.view)
        }
        self.didMove(toParent: parent)
        self.endAppearanceTransition()
    }
}
