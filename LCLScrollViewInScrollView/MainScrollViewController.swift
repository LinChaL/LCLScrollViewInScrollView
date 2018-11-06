//
//  MainScrollVIewController.swift
//  LCLScrollViewInScrollView
//
//  Created by linchl on 2018/11/6.
//  Copyright © 2018年 linchl. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import MJRefresh

public let ScreenWidth  = UIScreen.main.bounds.size.width
public let ScreenHeight = UIScreen.main.bounds.size.height
public let ScreenScale  = UIScreen.main.scale

class MainScrollVIewController: UIViewController, UIGestureRecognizerDelegate {
    var itemNum: Int = 3
    var menuHeight: CGFloat = 50
    var topCellHeight: CGFloat = 400
    var navigationBarHeight: CGFloat {
        return navigationController?.navigationBar.frame.size.height ?? 0
    }
    var statusBarHeight: CGFloat {
        return UIApplication.shared.statusBarFrame.height
    }
    
    
    var childVCScrollView: UIScrollView?
    
    var dynamicItem = MyDynamicItem()
    var animator: UIDynamicAnimator?
    var lastCenter: CGPoint = .zero
    var decelerateBehavior: UIDynamicItemBehavior?
    var bounceBehavior: UIAttachmentBehavior?
    
    var tableViewHeight: CGFloat {
        return ScreenHeight - statusBarHeight - navigationBarHeight
    }
    var fixHeight: CGFloat = 100
    
    private lazy var mainTableView: MyTableView = {
        let tableView = MyTableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = .gray
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        let navigationBarHeight: CGFloat = navigationController?.navigationBar.frame.size.height ?? 0
        scrollView.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: tableViewHeight - fixHeight - menuHeight)
        scrollView.contentSize = CGSize(width: ScreenWidth * CGFloat(4), height: 0)
        scrollView.backgroundColor = .gray
        return scrollView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addMJRefresh()
        mainTableView.mj_header.mj_h = 100
        self.animator = UIDynamicAnimator(referenceView: view)
        view.addSubview(mainTableView)
        mainTableView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(topLayoutGuide.snp.bottom)
        }
        
        let firstVC = FirstViewController()
        firstVC.addLifeCycle(to: self)
        firstVC.delegate = self
        
        let secondVC = SecondViewController()
        secondVC.addLifeCycle(to: self)
        secondVC.delegate = self
        
        let thirdVC = ThirdViewController()
        thirdVC.addLifeCycle(to: self)
        thirdVC.delegate = self
        
        let fourthVC = FourViewController()
        fourthVC.addLifeCycle(to: self)
        fourthVC.delegate = self
        
        for i in 0..<childViewControllers.count {
            let subController = childViewControllers[i]
            scrollView.addSubview(subController.view)
            subController.view.frame = CGRect(x: scrollView.frame.size.width * CGFloat(i), y: 0, width: scrollView.frame.size.width, height: scrollView.frame.size.height)
        }
    }
    
    private func addMJRefresh() {
        let header = MJRefreshNormalHeader {
            self.mainTableView.mj_header.beginRefreshing()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
                self.mainTableView.mj_header.endRefreshing()
                self.mainTableView.reloadData()
            })
        }
        header?.setTitle("松手刷新", for: .pulling)
        header?.setTitle("正在刷新", for: .refreshing)
        header?.setTitle("下拉刷新", for: .idle)
        
        self.mainTableView.mj_header = header
    }
    
}
