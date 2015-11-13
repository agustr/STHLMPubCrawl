//
//  ARPlaceVisitPlan.swift
//  STHLMPubCrawl
//
//  Created by Agust Rafnsson on 09/10/15.
//  Copyright © 2015 Agust Rafnsson. All rights reserved.
//

import Foundation
import MapKit

protocol ARPlacesVisitPlanDelegate {
    func placeOrderChanged(sender:ARPlacesVisitPlan)
    func routeAdded(route:MKRoute,sender:ARPlacesVisitPlan)
    func routesRemoved(routes:[MKRoute], sender:ARPlacesVisitPlan)
}

class ARPlacesVisitPlan:NSObject, ARRouteBetweenPlacesDelegate{
    
    static let sharedInstance = ARPlacesVisitPlan()
    var delegate:ARPlacesVisitPlanDelegate? {
        didSet{
            print("Delegate Set")
        }
    }
    
    var name:String?
    private (set) var places:[GPPlace]! = []
    private (set) var routes:[ARRouteBetweenPlaces]! = [] {
        didSet(oldValue){
            print("SETTED THE ARRAY \(routes.count)\n oldVaue: \(oldValue)")
        }
    }
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
    
    func addPlace(place:GPPlace!){
        if place == nil {
            return
        }
        places.append(place!)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            self.addRoutesForPlace(place!)
        }
    }
    
    private func addRoutesForPlace(place:GPPlace!){
        for otherPlace in places{
            if place != otherPlace{
                let route = ARRouteBetweenPlaces(placeOne: place, placeTwo: otherPlace)
                route.delegate = self
                routes.append(route)
            }
        }
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
    
    private func removeRoutesForPlace(place:GPPlace){
        routes = routes.filter({ !($0.containsPlace(place))})
    }
    
    func routeReady(route:MKRoute, sender:ARRouteBetweenPlaces){
        self.delegate?.routeAdded(route, sender: self)
    }
}

protocol ARRouteBetweenPlacesDelegate{
    func routeReady(route:MKRoute, sender:ARRouteBetweenPlaces)
}

class ARRouteBetweenPlaces: CustomStringConvertible {
    let firstPlace:GPPlace!
    let secondPlace:GPPlace!
    var route: MKRoute?
    var delegate:ARRouteBetweenPlacesDelegate?{
        didSet{
            print("ARRouteBetweenPlacesDelegate delegate set")
        }
    }
    
    init(placeOne:GPPlace!, placeTwo:GPPlace!){
        self.firstPlace = placeOne
        self.secondPlace = placeTwo
        
        dispatch_after(DISPATCH_TIME_NOW, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            self.generateRoute()
        }
        return
    }
    
    func generateRoute(){
        let sourceItem = MKMapItem(placemark: MKPlacemark(coordinate: firstPlace.coordinate, addressDictionary: nil))
        let destinationItem = MKMapItem(placemark: MKPlacemark(coordinate: secondPlace.coordinate, addressDictionary: nil))
        
        let directionRequest = MKDirectionsRequest()
        directionRequest.requestsAlternateRoutes = false
        directionRequest.source = sourceItem
        directionRequest.destination = destinationItem
        directionRequest.transportType = MKDirectionsTransportType.Walking
        
        let directions = MKDirections(request: directionRequest)
        
        directions.calculateDirectionsWithCompletionHandler { (directionResponse, error) -> Void in
            guard let routes = directionResponse?.routes else {
                print("no routes ")
                return
            }
            self.route = routes.first
            if self.route != nil {
                self.delegate?.routeReady(self.route!, sender: self)
            }
        }
    }
    
    func containsPlace(place:GPPlace)->Bool{
        return (place == firstPlace) || (place == secondPlace)
    }
    
    func containsPlaces(place1:GPPlace, place2:GPPlace)->Bool{
        return self.containsPlace(place1) && self.containsPlace(place2)
    }
    
    var description:String{
        get{
            return "ARRouteBetween \(self.firstPlace.name) & \(self.secondPlace.name)"
        }
    }
}