//
//  MainScrollViewController.swift
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

class MainScrollViewController: UIViewController {
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
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
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
        
        for i in 0..<children.count {
            let subController = children[i]
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

extension MainScrollViewController: UIGestureRecognizerDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard mainTableView == scrollView else {
            return
        }
        if (childVCScrollView != nil && childVCScrollView!.contentOffset.y > 0) || scrollView.contentOffset.y > topCellHeight - fixHeight {
            mainTableView.setContentOffset(CGPoint(x: 0, y: topCellHeight - fixHeight), animated: false)
        }
        
        if scrollView.contentOffset.y < topCellHeight - fixHeight {
            for subController in self.children {
                guard let vc = subController as? BaseViewController else {
                    return
                }
                vc.tableView.setContentOffset(.zero, animated: false)
            }
        }
    }
    
    func subViewDidScroll(_ scrollView: UIScrollView) {
        childVCScrollView = scrollView
        if mainTableView.contentOffset.y < topCellHeight - fixHeight {
            scrollView.setContentOffset(.zero, animated: false)
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.animator?.removeAllBehaviors()
        decelerateBehavior = nil
        bounceBehavior = nil
    }
    
    func subViewWillEndDragging(_ subScrollView: UIScrollView, velocity: CGFloat) {
        if (velocity < 0 && subScrollView.contentOffset.y > 0) || (velocity > 0 && mainTableView.contentOffset.y < self.topCellHeight - self.fixHeight) {
            DispatchQueue.main.async {
                subScrollView.setContentOffset(subScrollView.contentOffset, animated: false)
            }
            dynamicItem.center = CGPoint(x: 0, y: mainTableView.contentOffset.y)
            lastCenter = dynamicItem.center
            let behavior = UIDynamicItemBehavior(items: [dynamicItem])
            behavior.addLinearVelocity(CGPoint(x: 0, y: velocity), for: dynamicItem)
            behavior.resistance = 2
            behavior.action = { [weak self] in
                guard let `self` = self else { return }
                
                if velocity < 0 { // 向下滑
                    let mainOffset = self.mainTableView.contentOffset.y
                    let subOffset = subScrollView.contentOffset.y
                    let scrollDistance = (self.lastCenter.y - self.dynamicItem.center.y)
                    if subOffset - scrollDistance <= 0 { // subScrollView滑动到顶部，需要把惯性传递给mainScrollView
                        subScrollView.contentOffset.y = 0
                        self.mainTableView.contentOffset.y = mainOffset - (scrollDistance - subOffset)
                    } else if self.bounceBehavior != nil { // 在回弹过程中，scrollDistance为负数，保证mainScrollView的offset不超过0
                        subScrollView.contentOffset.y = 0
                        self.mainTableView.contentOffset.y = min(mainOffset - (scrollDistance - subOffset), 0)
                    } else { // subScrollView未滑动到顶部，正常减速
                        subScrollView.contentOffset.y = subOffset - scrollDistance
                        self.mainTableView.contentOffset.y = self.topCellHeight - self.fixHeight
                    }
                } else if velocity > 0 { // 向上滑
                    let mainOffset = self.mainTableView.contentOffset.y
                    let subOffset = subScrollView.contentOffset.y
                    let scrollDistance = (self.dynamicItem.center.y - self.lastCenter.y)
                    if mainOffset + scrollDistance >= self.topCellHeight - self.fixHeight { // mainScrollView滑动到极限值，需要把惯性传递给subScrollView
                        self.mainTableView.contentOffset.y = self.topCellHeight - self.fixHeight
                        subScrollView.contentOffset.y = min(subOffset + mainOffset + scrollDistance - (self.topCellHeight - self.fixHeight), subScrollView.contentSize.height - subScrollView.frame.height)
                    } else { // mainScrollView滑动未到极限值，正常减速
                        self.mainTableView.contentOffset.y = mainOffset + scrollDistance
                        subScrollView.contentOffset.y = 0
                    }
                }
                
                self.lastCenter = self.dynamicItem.center
                
                self.bounceAnimate()
            }
            
            decelerateBehavior = behavior
            animator?.addBehavior(behavior)
        }
    }
    
    private func bounceAnimate() {
        let outsideFrame = mainTableView.contentOffset.y < 0
        
        if outsideFrame, let animator = self.animator, let _ = decelerateBehavior, bounceBehavior == nil {
            var target: CGPoint = .zero
            if mainTableView.contentOffset.y < 0 {
                dynamicItem.center = mainTableView.contentOffset
                target = .zero
                mainTableView.bounces = false
                let behavior = UIAttachmentBehavior(item: dynamicItem, attachedToAnchor: target)
                behavior.length = 0
                behavior.damping = 1
                behavior.frequency = 2
                
                self.bounceBehavior = behavior
                animator.addBehavior(behavior)
            }
        }
    }
}

extension MainScrollViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section < 2 {
            return UITableViewCell(style: .default, reuseIdentifier: "cell")
        } else {
            let cell = UITableViewCell(style: .default, reuseIdentifier: "scrollviewCell")
            cell.contentView.addSubview(scrollView)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section < 2 {
            return 200
        } else {
            return tableViewHeight - fixHeight
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return itemNum
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 2 {
            return menuHeight
        } else {
            return 0.0001
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 2 {
            let view = UIView()
            view.backgroundColor = .red
            return view
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0001
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
}
