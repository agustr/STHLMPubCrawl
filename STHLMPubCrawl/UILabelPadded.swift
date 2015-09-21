//
//  UILabelPadded.swift
//  PubCrawl
//
//  Created by Agust Rafnsson on 15/09/15.
//  Copyright (c) 2015 Agust Rafnsson. All rights reserved.
//

import UIKit


class UILabelPadded: UILabel {
    let topInset = CGFloat(0), bottomInset = CGFloat(0), leftInset = CGFloat(4), rightInset = CGFloat(4)
    
    override func drawTextInRect(rect: CGRect) {
        let insets: UIEdgeInsets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawTextInRect(UIEdgeInsetsInsetRect(rect, insets))
    }
    
    override func intrinsicContentSize() -> CGSize {
        var intrinsicSuperViewContentSize = super.intrinsicContentSize()
        intrinsicSuperViewContentSize.height += topInset + bottomInset
        intrinsicSuperViewContentSize.width += leftInset + rightInset
        return intrinsicSuperViewContentSize
    }
}
