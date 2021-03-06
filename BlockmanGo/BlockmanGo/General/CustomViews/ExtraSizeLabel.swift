//
//  ExtraSizeLabel.swift
//  BlockyModes
//
//  Created by KiBen on 2018/4/21.
//  Copyright © 2018年 SandboxOL. All rights reserved.
//

import UIKit

class ExtraSizeLabel: UILabel {

    public var extraWidth: CGFloat = 10.0
    
    public var extraHeight: CGFloat = 1.0
    
    public var contentInset: UIEdgeInsets = .zero
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: UIEdgeInsetsInsetRect(rect, contentInset))
    }

    override var intrinsicContentSize: CGSize {
        get {
            let originSize = super.intrinsicContentSize
            return CGSize(width: originSize.width + extraWidth, height: originSize.height + extraHeight)
        }
    }
}
