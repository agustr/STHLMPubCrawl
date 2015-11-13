//
//  BarRadar.swift
//  PubCrawl
//
//  Created by Agust Rafnsson on 18/09/15.
//  Copyright (c) 2015 Agust Rafnsson. All rights reserved.
//

import Foundation
import MapKit


class GPSearchRadar:NSObject, CLLocationManagerDelegate, GooglePlacesDelegate {
    
    static let sharedInstance = GPSearchRadar()
    
    var sizeImagePrefetch:CGSize?
    
    /// The desired accuracy
    var desiredAccuracy:Double = 10
    
    /// How many results does the radar want from the GPPlacesSearchQuery at maximum.
    var maxNumberOfResults:Int = 50
    
    /// This is the locationmanager for the service. It uses the standard location service, which allows you to specify the desired accuracy of the location data and receive updates as the location changes.
    private let locationManager:CLLocationManager! = CLLocationManager()
    
    /// These are the places that have been retreived from google.
    var places:[GPPlace]! = []{
        didSet{
            NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: kGPSearchRadarNewResultsNotifier, object: self))
        }
    }
    
    /// currentPlace is the place currently being focused on.
    var currentPlace:GPPlace? = nil{
        didSet{
            NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: kGPSearchRadarNewSelectedPlaceNotifier, object: self))
            if currentPlace != nil{
                self.preHeat(currentPlace!)
            }
        }
    }
    
    func setQuery(query:GPPlacesSearchQuery!){
        self.searchQuery = query
    }
    // SearchRadar has a search query and a delta distance
    // the delta distance tells the radar after how many meters it shoudl update the query.
    
    /// The Google Places Search Query that the radar is looking for. See GPPlacesSearchQuery for documentation on how to set up a search query.
    private var searchQuery:GPPlacesSearchQuery? = nil {
        didSet{
            self.searchQuery?.delegate = self
        }
    }
    
    func preHeat(place:GPPlace){
        let placeAfter = self.placeAfterPlace(place)
        let placeBefore = self.placeBeforePlace(place)
        if self.sizeImagePrefetch != nil{
            placeAfter?.preHeat(self.sizeImagePrefetch!)
            placeBefore?.preHeat(self.sizeImagePrefetch!)
        }
    }
    
    func placeAfterPlace(place:GPPlace!)->GPPlace?{
        let index = self.indexOfPlace(place)
        if index != nil{
            let nextIndex =  index! + 1
            if nextIndex < places.endIndex{
                return places[nextIndex]
            }
        }
        return nil
    }

    func placeBeforePlace(place:GPPlace!)->GPPlace?{
        let index = self.indexOfPlace(place)
        if index != nil{
            let nextIndex =  index! - 1
            if nextIndex > places.startIndex{
                return places[nextIndex]
            }
        }
        return nil
    }
    
    func indexOfPlace(place:GPPlace!)->Int?{
        let indexCP = self.places.indexOf(place)
        return indexCP
    }
    
    /// The maximum distance allowed from the last search query result to the devices current location.
    var distanceFilter:CLLocationDistance{
        set(newDistanceFilter){
            self.locationManager.distanceFilter = newDistanceFilter
        }
        get{
            return self.locationManager.distanceFilter
        }
    }
    
    override init(){
        // Always check authorisation before creating a CLLocationManger
        // print("initialising search radar")
        super.init()
        
        self.configureLocationManager()
    }
    
    deinit{
        // print("search radar deinint")
    }
    
    private func configureLocationManager(){
       //  print("configured location manager for the GPSearchRadar")
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.delegate = self
        self.locationManager.distanceFilter = 2000
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        self.locationManager.activityType = CLActivityType.Other
        self.locationManager.startUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // The most recent location is at the end of the array. Lets use that one.
        let lastUserLocation = locations.last! // locationManager docs say locations always contain at least one location.
        // print("GPSearchRadar received location")
        
        if self.searchQuery != nil {
            // print("we have a searchQuery")
            
            if searchQuery?.searchLocation != nil{
                // print("we have a search location")
                let distance = self.distanceBetween(lastUserLocation, secondLocation: self.searchQuery!.searchLocation!)
                // print("the distance between the current query and current location is \(distance)")
                
                if (distance > self.distanceFilter){
                    // print("the delta distance requriements are fullfilled")
                    Beeper.sharedBeeper?.playBeep()
                    self.searchQuery?.searchWith(lastUserLocation.coordinate)
                }
            }
            else{
                // print("the search location is nil we need an initial search")
                self.searchQuery?.searchWith(lastUserLocation.coordinate)
            }
        }
    }
    
    func googlePlacesSearchResult(searchResult: [GPPlace]?, error: String?, sender: GPPlacesSearchQuery!) {
        
        if self.places.count == 0 {
            self.currentPlace = sender.searchResults.first
            self.places = sender.searchResults

        }
        
        if sender.hasMoreResultsAvailable {
            if (sender.searchResults.count < self.maxNumberOfResults){
                
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64( 5000 * Double(NSEC_PER_MSEC)))
                // print("delayTime: \(delayTime)")
                
                NSLog("before dispatching")
                dispatch_after(delayTime, dispatch_get_main_queue()) {
                    // print("delayed getting results")
                    self.searchQuery?.getNextTwentyResults()
                }
                return
            }
        }
        
        self.places = self.searchQuery?.searchResults
//        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "kGPSearchRadarNewResultsNotifier", object: self))
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        // print("\(error.localizedDescription)")
    }
        
    func locationManager(manager: CLLocationManager, didFinishDeferredUpdatesWithError error: NSError?) {
        // print("\(error?.localizedDescription)")
    }
        
    func distanceBetween2DLocations(firstLocation:CLLocationCoordinate2D, secondLocation:CLLocationCoordinate2D)->CLLocationDistance {
        let loc1 = CLLocation(latitude: firstLocation.latitude, longitude: firstLocation.longitude)
        let loc2 = CLLocation(latitude: secondLocation.latitude, longitude: secondLocation.longitude)
        return loc1.distanceFromLocation(loc2)
    }
        
    func distanceBetween(firstLocation:CLLocation, secondLocation:CLLocationCoordinate2D)->CLLocationDistance {
        let loc2 = CLLocation(latitude: secondLocation.latitude, longitude: secondLocation.longitude)
        return firstLocation.distanceFromLocation(loc2)
    }
}

let kGPSearchRadarNewResultsNotifier = "kGPSearchRadarNewResultsNotifier"
let kGPSearchRadarNewSelectedPlaceNotifier = "kGPSearchRadarNewSelectedPlaceNotifier"
