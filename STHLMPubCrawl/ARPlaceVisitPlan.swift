//
//  ARPlaceVisitPlan.swift
//  STHLMPubCrawl
//
//  Created by Agust Rafnsson on 09/10/15.
//  Copyright © 2015 Agust Rafnsson. All rights reserved.
//

import Foundation


class ARPlacesVisitPlan:NSObject {
    
    static let sharedInstance = ARPlacesVisitPlan()
    
    var name:String?
    var places:[GPPlace]! = []
    var distance:Double! = 0
    var travelTime:Double! = 0
    
    func hasPlace(place:GPPlace?)->Bool{
        if place == nil{
            return false
        }
        if places.indexOf(place!) != nil{
            return true
        }
        return false
    }
    
    func addPlace(place:GPPlace?){
        if place == nil {
            return
        }
        places.append(place!)
    }
    
    func removePlace(place:GPPlace?){
        if place == nil {
            return
        }
        
        let index = places.indexOf(place!)
        if index != nil{
            places.removeAtIndex(index!)
        }
    }
}