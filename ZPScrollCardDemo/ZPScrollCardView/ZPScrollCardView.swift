//
//  ZPScrollCardView.swift
//  EnnewLaikang
//
//  Created by xinzhipeng on 2019/3/13.
//  Copyright © 2019 Enn. All rights reserved.
//

import UIKit

@objc public protocol ZPScrollCardViewDelegate {
    //点击item的index回调
    func cycleViewDidSelectedIndex(_ index: Int)
}

enum ZPScrollDirection: Int {
    case Middle = 0   //滚动到最前和最后之间的组数据
    case First      //滚动到最前一组数据
    case Last         //滚动到最后一组数据
}

class ZPScrollCardView: UIView {
    
    public weak var delegate: ZPScrollCardViewDelegate?
    
    //滚动方向
    public var scrollDirection: UICollectionView.ScrollDirection = .horizontal {
        didSet { flowLayout.scrollDirection = scrollDirection }
    }
    
    //item之间相隔距离
    public var itemSpacing: CGFloat = 0 {
        didSet {
            flowLayout.minimumLineSpacing = itemSpacing
        }
    }
    
    //itemCornerRadius
    public var itemCornerRadius: CGFloat = 0
    
    //itemSize
    public var itemSize: CGSize? {
        didSet {
            if let itemSize = itemSize {
                let width = min(bounds.size.width, itemSize.width)
                let height = min(bounds.size.height, itemSize.height)
                flowLayout.itemSize = CGSize(width: width, height: height)
            }
        }
    }
    //item放大比例
    public var itemZoomScale: CGFloat = 1 {
        didSet {
            collectionView.isPagingEnabled = itemZoomScale == 1
            flowLayout.scale = itemZoomScale
        }
    }
    //item是否下对齐
    public var isBottomAlign: Bool = false {
        didSet {
            flowLayout.isBottomAlign = isBottomAlign
        }
    }
    
    public var collectionViewBackgrouColor: UIColor = .white {
        didSet {
            collectionView.backgroundColor = collectionViewBackgrouColor
        }
    }
    
    //是否自动轮播
    public var isAutoScroll: Bool = false
    
    public var timeInterval: CGFloat = 2.0
    
    //写入图片和title资源
    public func setImagAndTitle(_ imageNameArr: [String], titleArr: [String]) {
        if imageNameArr.count == 0 {
            return
        }
        imageNamesArr = imageNameArr
        titlesArr = titleArr
        realDataCount = imageNameArr.count
        //realDataCount为真实的item个数,乘以2的倍数加realDataCount为(2n + 1)倍假数据 最少为3组
        //正好满足 每组3个item, 滚动为下标 2 -> 0 -> 1 -> 2 - > 0
        itemCount = realDataCount <= 2 ? realDataCount : realDataCount * (2 * 50 + 1)
        collectionView.reloadData()
    }
    
    private var reuseIdentifier: String = "ZPScrollCardCell"
    
    fileprivate var flowLayout: ZPScrollCardFlowLayout!
    fileprivate var collectionView: UICollectionView!
    fileprivate var itemCount: Int = 0
    fileprivate var realDataCount: Int = 0
    fileprivate var imageNamesArr: [String] = []
    fileprivate var titlesArr: [String] = []
    fileprivate var timer: Timer?
    fileprivate var currentIndex: Int = 0  //当前的item的下标
    fileprivate var nextIndex: Int = 0 //将要移动的下标
    fileprivate var scrollDir: ZPScrollDirection = .Middle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addCollectionVew()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override public func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
    }
    override func layoutSubviews() {
        flowLayout.itemSize = itemSize != nil ? itemSize! : bounds.size
        collectionView.frame = bounds
        //布局完成后再调用滚动方法,不然会出现滚动错误
        collectionView.scrollToItem(at: IndexPath.init(item: (itemCount -  realDataCount) / 2, section: 0), at: .centeredHorizontally, animated: false)
        if isAutoScroll {
            startTimer()
        }
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if newSuperview != nil {
            self.startTimer()
        } else {
            self.cancelTimer()
        }
    }
    
    private func addCollectionVew() {
        flowLayout = ZPScrollCardFlowLayout()
        flowLayout.itemSize = itemSize != nil ? itemSize! : bounds.size
        flowLayout.scrollDirection = scrollDirection
        flowLayout.minimumLineSpacing = itemSpacing
        flowLayout.minimumInteritemSpacing = 0
        
        collectionView = UICollectionView(frame: bounds, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = collectionViewBackgrouColor
        collectionView.bounces = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ZPScrollCardCell.self, forCellWithReuseIdentifier: self.reuseIdentifier)
        collectionView.decelerationRate = UIScrollView.DecelerationRate(rawValue: 0.0)
        addSubview(collectionView)
    }
    
}


// MARK: - UICollectionViewDataSource / UICollectionViewDelegate
extension ZPScrollCardView: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.reuseIdentifier, for: indexPath) as! ZPScrollCardCell
        let index = indexPath.item % realDataCount
        cell.setImageAndTitle(imageNamesArr[index], titleName: titlesArr[index])
        if itemCornerRadius != 0 {
            cell.layer.cornerRadius = itemCornerRadius
            cell.layer.masksToBounds = true
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isAutoScroll {
            return
        }
        let centerPoint = convert(collectionView.center, to: collectionView)
        if let centerIndex = collectionView.indexPathForItem(at: centerPoint) {
            //图片在中心点响应点击事件,反之滚动到中间点
            if indexPath.item == centerIndex.item {
                let index = indexPath.item % realDataCount
                if delegate != nil {
                    delegate?.cycleViewDidSelectedIndex(index)
                }
                scrollDir = .Middle
            } else if indexPath.item > centerIndex.item && (indexPath.item / realDataCount) == realDataCount - 1 {
                //点击中心之后的item,如果是点击的最后一组数据,则滚动结束 复位
                scrollDir = .Last
            } else if indexPath.item < centerIndex.item && (indexPath.item / realDataCount) == 0 {
                //点击中心之前的item,如果点击的第一组数据,则滚动结束 复位
                scrollDir = .First
            } else {
                scrollDir = .Middle
            }
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
}

//MARK:UIScrollViewDelegate
extension ZPScrollCardView {
    //当开始滚动视图时，执行该方法,一次有效滑动（开始滑动，滑动一小段距离，只要手指不松开，只算一次滑动），只执行一次。
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if isAutoScroll {
            cancelTimer()
        }
    }
    // 滑动视图，当手指离开屏幕那一霎那，调用该方法。一次有效滑动，只执行一次
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
    }
    // 滚动视图减速完成，滚动将停止时，调用该方法。一次有效滑动，只执行一次
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pointInView = self.convert(collectionView.center, to: collectionView)
        let indexPath = collectionView.indexPathForItem(at: pointInView)
        //滚动到第几张
        let index = (indexPath?.item ?? 0) % realDataCount
        //重新定位,这时滚动停止,所以nextIndex就是index
        nextIndex = index
        if index == realDataCount - 1 {
            scrollToItem((itemCount - realDataCount) / 2 - 1, animated: false)
        } else {
            scrollToItem((itemCount - realDataCount) / 2 + index, animated: false)
        }
        scrollViewDidEndScrollingAnimation(scrollView)
        if isAutoScroll {
            startTimer()
        }
    }
    // 当滚动视图动画完成后，调用该方法，如果没有动画，那么该方法将不被调用
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        //手指点击item导致的滚动,处理最后和最前一组数据,复位到相应下标的中间组
        if scrollDir == .Last || scrollDir == .First {
            scrollToItem()
            return
        }
        //自动时,滚动结束后,若nextIndex为realDataCount - 1,则需要立马滚动到0下标的前一位
        if isAutoScroll && nextIndex == realDataCount - 1 {
            scrollToItem((itemCount - realDataCount) / 2 - 1, animated: false)
        }
    }
}
//MARK:timer
extension ZPScrollCardView {
    fileprivate func startTimer() {
        if !isAutoScroll { return }
        if itemCount <= 1 { return }
        cancelTimer()
        timer = Timer.init(timeInterval: Double(timeInterval), target: self, selector: #selector(timeRepeat), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: RunLoop.Mode.common)
    }
    fileprivate func cancelTimer() {
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
    }
    @objc func timeRepeat() {
        let pointInView = self.convert(collectionView.center, to: collectionView)
        let indexPath = collectionView.indexPathForItem(at: pointInView)
        //滚动到第几张
        let index = (indexPath?.item ?? 0) % realDataCount
        currentIndex = index
        //滚动开始之前,nextIndex为index+1
        nextIndex = index + 1
        //假如有3个item,滚动下标应该是 0 -> 1 -> 2 (滚动结束会立马跳到0下标之前个那个item),所以在到达第一个下标2的滚动过程结束,应该立即无动画滚动到0下标之前那个2
        if nextIndex == realDataCount {
            //判断滚动一轮后,往0下标位置滚动,其他情况往下一位开始滚动
            scrollToItem((itemCount - realDataCount) / 2, animated: true)
        } else {
            //往下一位滚动
            scrollToItem((itemCount - realDataCount) / 2 + index + 1, animated: true)
        }
    }

    //复位
    func scrollToItem() {
        let pointInView = self.convert(collectionView.center, to: collectionView)
        let indexPath = collectionView.indexPathForItem(at: pointInView)
        //滚动到第几张
        let index = (indexPath?.item ?? 0) % realDataCount
        if index == realDataCount - 1 { //遵循一个原则:复位后当index一组d中最后的intem,就跳到这组的前一个item
            scrollToItem((itemCount - realDataCount) / 2 - 1, animated: false)
        } else {
            scrollToItem((itemCount - realDataCount) / 2 + index, animated: false)
        }
    }
    
    func scrollToItem(_ item: Int, animated: Bool) {
        let scrollPosition: UICollectionView.ScrollPosition = scrollDirection == .horizontal ? .centeredHorizontally : .centeredVertically
        collectionView.scrollToItem(at: IndexPath(item: item, section: 0), at: scrollPosition, animated: animated)
    }
}
