//
//  ViewController.swift
//  LCLScrollViewInScrollView
//
//  Created by linchl on 2018/11/6.
//  Copyright © 2018年 linchl. All rights reserved.
//

import UIKit
import SnapKit

class ViewController: UIViewController {

    private let clickButton: UIButton = {
        let button = UIButton()
        button.setTitle("click me", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .yellow
        button.addTarget(self, action: #selector(ViewController.clickAction), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(clickButton)
        clickButton.snp.makeConstraints { (make) in
            make.width.equalTo(100)
            make.height.equalTo(50)
            make.center.equalToSuperview()
        }
        // Do any additional setup after loading the view, typically from a nib.
    }

    @objc private func clickAction() {
        navigationController?.pushViewController(MainScrollViewController(), animated: true)
    }
}

