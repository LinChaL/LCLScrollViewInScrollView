//
//  BaseViewController.swift
//  refreshTest
//
//  Created by linchl on 2018/10/26.
//  Copyright © 2018年 linchl. All rights reserved.
//

import Foundation
import UIKit
import MJRefresh

class BaseViewController: UIViewController {
    private var itemNum: Int = 30
    weak var delegate: MainScrollViewController?
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.bounces = false
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addMJRefresh()
        tableView.mj_footer.mj_h = 50
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    private func addMJRefresh() {
        
        let footer = MJRefreshBackNormalFooter {[weak self] in
            guard let `self` = self else { return }
            self.loadMore()
        }
        
//        let footer = MJRefreshAutoNormalFooter {[weak self] in
//            guard let `self` = self else { return }
//            self.loadMore()
//        }
        
        footer?.setTitle("松手加载更多", for: .pulling)
        footer?.setTitle("正在加载", for: .refreshing)
        footer?.setTitle("上拉加载更多", for: .idle)
        
        self.tableView.mj_footer = footer
    }
    
    private func loadMore() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
            self.tableView.mj_footer.endRefreshing()
            guard self.itemNum < 70 else {
                self.tableView.mj_footer.state = .noMoreData
                return
            }
            self.itemNum += 10
            self.tableView.reloadData()
        })
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let delegate = delegate else { return }
        delegate.subViewDidScroll(tableView)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard let delegate = delegate else { return }
        delegate.subViewWillEndDragging(scrollView, velocity: velocity.y * 500)
    }
}

extension BaseViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemNum
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "baseCell")
        cell.textLabel?.text = "第\(indexPath.row)行"
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0001
    }
    
}
