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
    
    var aspectRatio:Double{
        return Double(self.width)/Double(self.height)
    }
    
    func getImageRequestUrl(maxWidth:Int?, maxHeight:Int?)->NSURL?{
        var urlStr:String! = "https://maps.googleapis.com/maps/api/place/photo?"
        
        print("")
        
        if maxWidth != nil{
            urlStr = urlStr + "maxwidth=\(maxWidth!)&"
        }
        if maxHeight != nil{
                urlStr = urlStr + "maxheight=\(maxHeight!)&"
        }
        if let photoreferenceid = self.dictionary?["photo_reference"] as? String {
            urlStr = urlStr + "&photoreference=\(photoreferenceid)&"
        }
        if let gpKey = NSBundle.mainBundle().infoDictionary?["places-key"] as? String{
            urlStr = urlStr + "key=\(gpKey)"
        }
        
        let url = NSURL(string: urlStr.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)
        
        return url
    }
    
    func getImageFromWeb(maxWidth: Int?, maxHeight:Int?) -> UIImage? {
        
        let requestURL = self.getImageRequestUrl(maxWidth, maxHeight: maxHeight)
        
        if requestURL != nil{
            let imageData = NSData(contentsOfURL: requestURL!)
            if imageData != nil{
                let imageBar = UIImage(data: imageData!)
                return imageBar
            }
        }
        return nil
    }
}