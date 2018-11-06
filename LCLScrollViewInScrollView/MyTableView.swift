//
//  MyTableView.swift
//  refreshTest
//
//  Created by linchl on 2018/10/26.
//  Copyright © 2018年 linchl. All rights reserved.
//

import Foundation
import UIKit

class MyTableView: UITableView, UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer.isKind(of: UIPanGestureRecognizer.self) && otherGestureRecognizer.isKind(of: UIPanGestureRecognizer.self)
    }
}
