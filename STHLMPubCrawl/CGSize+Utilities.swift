//
//  CGSize+Utilities.swift
//  STHLMPubCrawl
//
//  Created by Agust Rafnsson on 02/10/15.
//  Copyright © 2015 Agust Rafnsson. All rights reserved.
//

import UIKit

extension CGSize{
    
    func scaledToFitContainerOfSize(size:CGSize)->CGSize{
        
        if (self.height == 0 ) || (self.width == 0){
            return CGSize(width: 0, height: 0)
        }
        
        let factor = self.resizeFactorToFit(size)
        return CGSize(width: (self.width * factor), height: (self.height * factor))
    }
    
    /// returns a size that would be large enough to fit the container 
    /// even if it were to rotate 90 deg.
    func scaledToFitRegardlessOfOrientationContainerOfSize(size:CGSize)->CGSize{
        let factor = self.resizeFactorToFitRegardlessOfOrientation(size)
        return CGSize(width: self.width * factor, height: self.height * factor)
    }
    
    func scaledToFillContainerOfSize(size:CGSize)->CGSize{
        let factor = self.resizeFactorToFill(size)
        return CGSize(width: (self.width * factor), height: (self.height * factor))
    }
    
    func scaledToFillRegardlessOfOrientationContainerOfSize(size:CGSize)->CGSize{
        let factor = resizeFactorToFillRegardlessOfOrientationContainerOfSize(size)
        return CGSize(width: self.width * factor, height: self.height * factor)
    }
    
    func resizeFactorToFillRegardlessOfOrientationContainerOfSize(size:CGSize)->CGFloat{
        let factor = resizeFactorToFill(size)
        let factor90 = resizeFactorToFill(CGSize(width: size.height, height: size.width))
        return max(factor, factor90)
    }
    
    func resizeFactorToFitRegardlessOfOrientation(size:CGSize)->CGFloat{
        let factor = resizeFactorToFit(size)
        let factor90 = resizeFactorToFit(CGSize(width: size.height, height: size.width))
        return max(factor, factor90)
    }
    
    func resizeFactorToFit(size:CGSize)->CGFloat{
        
        let widthFactor = size.width/self.width               // the smaller will fit the larger will fill
        let heightFactor = size.height/self.height
        
        return min(widthFactor, heightFactor)
    }
    
    func resizeFactorToFill(size:CGSize)->CGFloat{
        
        let widthFactor = size.width/self.width               // the smaller will fit the larger will fill
        let heightFactor = size.height/self.height
        
        return max(widthFactor, heightFactor)
    }
}