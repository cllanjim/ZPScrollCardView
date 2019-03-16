//
//  ZPScrollCardCell.swift
//  EnnewLaikang
//
//  Created by xinzhipeng on 2019/3/13.
//  Copyright © 2019 Enn. All rights reserved.
//

import UIKit

class ZPScrollCardCell: UICollectionViewCell {
    fileprivate var iconImgView: UIImageView!
    fileprivate var titleLab: UILabel!
    override init(frame: CGRect) {
        super.init(frame: frame)
        titleLab = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: bounds.width, height: 20))
        titleLab.textColor = UIColor.blue
        titleLab.textAlignment = .center
        titleLab.font = UIFont.systemFont(ofSize: 16)
        self.addSubview(titleLab)
//        titleLab.snp.makeConstraints { (make) in
//            make.top.equalTo(self).offset(20)
//            make.centerX.equalTo(self)
//        }
        
        iconImgView = UIImageView.init(frame: CGRect.init(x: 0, y: 20, width: bounds.width, height: bounds.height - 20))
        self.addSubview(iconImgView)
        iconImgView.image = UIImage.init(named: "3DHealth_biomedical")
    }
    
    func setImageAndTitle(_ imageName: String?, titleName: String?) {
        if let imageName = imageName, let titleName = titleName {
            iconImgView.image = UIImage.init(named: imageName)
            titleLab.text = titleName
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
