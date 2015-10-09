//
//  GPPlace.swift
//  SthlmBarCrawl
//
//  Created by Agust Rafnsson on 11/09/15.
//  Copyright (c) 2015 Agust Rafnsson. All rights reserved.
//

import SDWebImage
import Foundation
import MapKit

func == (left: GPPlace, right: GPPlace) -> Bool {
    return (left.placeID == right.placeID)
}

class GPPlace:NSObject, MKAnnotation {
    var dictionary:NSDictionary = NSDictionary()
    var latitude:Double = 0
    var longitude:Double = 0
    var name:String = ""
    var types:[String] = ["no type"]
    var vicinity:String? = ""
    var rating:Double? {
        let rate = self.dictionary["rating"] as? Double
        print("the rating for \(self.name) is \(rate)")
        return rate
    }
    
    var hasGottenDetails:Bool! = false
    
    //--------------------------------
    // MKAnnotation Protocol Start
    // Note: set coordinate not available since this is data dictated by google and thus not mutable.
    //--------------------------------
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var title: String? { return name }
    
    var subtitle: String? { return vicinity }
    
    var placeID:String { return (self.dictionary["place_id"] as? String)!}
    
    var photos:[GPPhoto]! = [GPPhoto]()
    
    func getDetails(completionHandler:()->Void){
        
        let gpKey = NSBundle.mainBundle().infoDictionary?["places-key"] as! String
        var requestURLStr = "https://maps.googleapis.com/maps/api/place/details/json?placeid=\(self.placeID)&key=\(gpKey)"
        requestURLStr = requestURLStr.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        
        let url = NSURL(string: requestURLStr)
        
        if (url != nil) {
            let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
            session.dataTaskWithURL(url!, completionHandler: { (data : NSData?, response : NSURLResponse?, error : NSError?) -> Void in
                
                if error != nil {
                  //  print("not able to get further information on the place:\n \(error!.localizedDescription)")
                }
                
                if let statusCode = response as? NSHTTPURLResponse {
                    if statusCode.statusCode != 200 {
                       // print("Could not continue statuscode was \(statusCode)")
                    }
                }
                
                //var error:NSError? = NSError()
                if data != nil {
                    
                    let responseDictionary = (try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)) as! NSDictionary
                    if let dict = responseDictionary["result"] as? NSDictionary{
                        self.dictionary = dict
                    }
                    let photosDictionaries = self.dictionary["photos"] as? [NSDictionary]
                    
                    if photosDictionaries != nil{
                        for photoDictionary in photosDictionaries!{
                            let photo = GPPhoto()
                            photo.dictionary = photoDictionary
                            self.photos.append(photo)
                        }
                    }
                    self.hasGottenDetails = true
                }
                completionHandler()
            }).resume()
        }
    }
    
    // Fetches the first available photo for the place
    // 
    func preHeat(size:CGSize){
        print("the place \(self.name) is preheating an image with the size \(size)")
        if self.photos.count > 0 {
            // preheat the photo
            let photo = self.photos.first
            let url = photo!.getImageRequestUrlThatFitsContainerOfSize(size)
            if url != nil{
                print("preheating \(self.name) : \(url)")
                SDWebImagePrefetcher.sharedImagePrefetcher().prefetchURLs([url!])
            }
        }
        else{
            self.getDetails({ () -> Void in
                if self.photos.count > 0 {
                    // preheat the photo
                    let photo = self.photos.first
                    let url = photo!.getImageRequestUrlThatFitsContainerOfSize(size)
                    if url != nil{
                        print("preheating \(self.name) : \(url)")
                        SDWebImagePrefetcher.sharedImagePrefetcher().prefetchURLs([url!])
                    }
                }
            })
        }
    }

    
    //--------------------------------
    // MKAnnotation Protocol End
    //--------------------------------
    
    init?(dict:NSDictionary){
        
        self.dictionary = dict
        
        if let geometry = dict["geometry"] as? NSDictionary{
            if let location = geometry["location"] as? NSDictionary{
                if let lat = location["lat"] as? Double{
                    latitude = lat
                }
                
                if let lng = location["lng"] as? Double{
                    longitude = lng
                }
            }
        }
        
        if let vicin = dict["vicinity"] as? String{
            vicinity = vicin
        }
        
        if let nom = dict["name"] as? String{
            name = nom
        }else{
            name = ""
        }
        
        super.init()
        
        if let typ = dict["types"] as? [String]{
            types = typ
        }else{
            return nil
        }
        
        if (name=="")||( (latitude==0)&&(longitude==0) ){
            return nil
        }
    }
    
    func describe(){
        print("\(self.name)")
    }
}
