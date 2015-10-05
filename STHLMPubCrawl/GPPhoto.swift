//
//  GPImage.swift
//  SthlmBarCrawl
//
//  Created by Agust Rafnsson on 12/09/15.
//  Copyright (c) 2015 Agust Rafnsson. All rights reserved.
//

import Foundation
import UIKit

class GPPhoto: NSObject {
    
    var dictionary:NSDictionary?
    
    var height:Int{
        if let height = self.dictionary!["height"] as? Int {
            return height
        }
        return -1
    }
    
    var width:Int{
        if let width = self.dictionary!["width"] as? Int {
            return width
        }
        return -1
    }
    
    var size:CGSize{
        get{
            if (self.width<0) || (self.height<0){
                return CGSize(width: 0, height: 0)
            }
            return CGSize(width: self.width,height: self.height)
        }
    }
    
    var aspectRatio:Double{
        return Double(self.width)/Double(self.height)
    }
    
    func getImageRequestUrl(maxWidth:CGFloat?, maxHeight:CGFloat?)->NSURL?{
        var urlStr:String! = "https://maps.googleapis.com/maps/api/place/photo?"
        
        if maxWidth != nil{
            urlStr = urlStr + "maxwidth=\(Int(maxWidth!))&"
        }
        if maxHeight != nil{
            urlStr = urlStr + "maxheight=\(Int(maxHeight!))&"
        }
        if let photoreferenceid = self.dictionary?["photo_reference"] as? String {
            urlStr = urlStr + "photoreference=\(photoreferenceid)&"
        }
        if let gpKey = NSBundle.mainBundle().infoDictionary?["places-key"] as? String{
            urlStr = urlStr + "key=\(gpKey)"
        }
        
        let url = NSURL(string: urlStr.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)
        
        return url
    }
    
    func getImageFromWeb(maxWidth: CGFloat?, maxHeight:CGFloat?) -> UIImage? {
        
        let requestURL = self.getImageRequestUrl(maxWidth, maxHeight: maxHeight)
        //print("the photo request is: \(requestURL)")
        if requestURL != nil{
            // print("trying to fech image")
            let imageData = NSData(contentsOfURL: requestURL!)
           // print("finished fetching image")
            if imageData != nil{
                let imageBar = UIImage(data: imageData!)
                return imageBar
            }
        }
        return nil
    }
    
    func getImageRequestUrlThatFitsContainerOfSize(size:CGSize)->NSURL?{
        let requestSize = self.size.scaledToFitRegardlessOfOrientationContainerOfSize(size)
        return getImageRequestUrl(requestSize.width, maxHeight: nil)
    }
    
    
    
    //    func getImageThatFitsContainerOfSize(size:CGSize){
    //
    //    }
    //
    //    func getImageThatFillsContainerOfSize(size:CGSize){
    //
    //    }
    //
    //    func maxPhotoResizeFactor(photoSize:CGSize!, containerSize: CGSize!)->CGFloat{
    //        let widthToWidthFactor = (containerSize.width / photoSize.width)
    //        let heigtToHeigtFactor = (containerSize.height /  photoSize.height)
    //        let WidthToHeightFactor = (containerSize.width / photoSize.height)
    //        let HeigthToWidthFactor = (containerSize.height / photoSize.width)
    //        return max(max(widthToWidthFactor, heigtToHeigtFactor), max(WidthToHeightFactor,HeigthToWidthFactor))
    //    }
}