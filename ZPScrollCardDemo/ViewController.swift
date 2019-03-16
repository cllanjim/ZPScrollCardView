//
//  ViewController.swift
//  ZPScrollCardDemo
//
//  Created by xinzhipeng on 2019/3/14.
//  Copyright © 2019 xinzhipeng. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let imageArr: [String] = ["image01", "image02", "image03"]
        let titleArr: [String] = ["孙允珠", "林允儿", "李秀彬"]
        let collectionView1 = ZPScrollCardView.init(frame: CGRect(x: 0, y: 100, width: view.bounds.size.width, height: 120))
        self.view.addSubview(collectionView1)
        collectionView1.setImagAndTitle(imageArr, titleArr: titleArr)
        collectionView1.itemSize = CGSize.init(width: view.bounds.width / 3, height: 100)
        collectionView1.itemSpacing = 0
        collectionView1.itemCornerRadius = 5
        collectionView1.scrollDirection = .horizontal
        collectionView1.delegate = self
        collectionView1.itemZoomScale = 1.2
        collectionView1.isBottomAlign = true
        collectionView1.collectionViewBackgrouColor = UIColor.red
        
        
        let collectionView2 = ZPScrollCardView.init(frame: CGRect(x: 0, y: 260, width: view.bounds.size.width, height: 120))
        self.view.addSubview(collectionView2)
        collectionView2.setImagAndTitle(imageArr, titleArr: titleArr)
        collectionView2.itemSize = CGSize.init(width: view.bounds.width / 3, height: 100)
        collectionView2.itemSpacing = 0
        collectionView2.itemCornerRadius = 5
        collectionView2.scrollDirection = .horizontal
        collectionView2.delegate = self
        collectionView2.itemZoomScale = 1.2
        collectionView2.isBottomAlign = true
        collectionView2.isAutoScroll = true
        collectionView2.timeInterval = 1.0
        collectionView2.collectionViewBackgrouColor = UIColor.orange
        
        let collectionView3 = ZPScrollCardView.init(frame: CGRect(x: 0, y: 410, width: view.bounds.size.width, height: 120))
        self.view.addSubview(collectionView3)
        collectionView3.setImagAndTitle(imageArr, titleArr: titleArr)
        collectionView3.itemSize = CGSize.init(width: view.bounds.width / 3, height: 100)
        collectionView3.itemSpacing = 0
        collectionView3.itemCornerRadius = 5
        collectionView3.scrollDirection = .horizontal
        collectionView3.delegate = self
        collectionView3.itemZoomScale = 1.2
        collectionView3.isBottomAlign = true
        collectionView3.isAutoScroll = true
//        collectionView3.timeInterval = 1.2
        collectionView3.isBottomAlign = false
        collectionView3.collectionViewBackgrouColor = UIColor.purple
    }
}

extension ViewController: ZPScrollCardViewDelegate {
    func cycleViewDidSelectedIndex(_ index: Int) {
        print("点击了: \(index)")
    }
}

