//
//  ViewController.swift
//  SthlmBarCrawl
//
//  Created by Agust Rafnsson on 26/08/15.
//  Copyright (c) 2015 Agust Rafnsson. All rights reserved.
//

import UIKit
import MapKit



class InitialViewController: UIViewController, CLLocationManagerDelegate, GooglePlacesDelegate, MKMapViewDelegate{
    
    let beeper = Beeper()

    @IBOutlet var map: MKMapView!
    var gpbarviewcontroller = GPPlaceViewController()
    
    @IBOutlet var GPPlaceView: UIView!
    
    lazy var locationManager:CLLocationManager = {
        print("initializing locationManager")
        var temoraryLocationManager = CLLocationManager()
        temoraryLocationManager.delegate = self
        return temoraryLocationManager
    }()
    
    let GPQuery = GPPlacesSearchQuery (key: nil, rankByDistance: true, keyword: nil, language: nil, minPrice: nil, maxPrice: nil, name: nil, openNow: nil, types: [kGPTypeBar, kGPTypeNightClub])
    
    var lastLocation:CLLocation!
    var shouldCenter:Bool = true

    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "newSonarResultsAvailable", name: kGPSearchRadarNewResultsNotifier, object: nil)
        // Do any additional setup after loading the view, typically from a nib.
        //var initialLocation = CLLocation(latitude: 21.282778, longitude: -157.829444)
        CLLocationManager.locationServicesEnabled()
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        print("location accuracy \(kCLLocationAccuracyBest)")
        locationManager.startUpdatingLocation()
        print("authorisation status: \( CLLocationManager.authorizationStatus().rawValue)")
        map.showsPointsOfInterest = false
        map.showsUserLocation = true
        GPQuery?.delegate = self
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        self.gpbarviewcontroller = storyboard.instantiateViewControllerWithIdentifier("GPPlaceViewController") as! GPPlaceViewController
        
         self.GPPlaceView.addSubview(self.gpbarviewcontroller.view)
        
        self.GPPlaceView.clipsToBounds = true
        self.gpbarviewcontroller.view.frame.size = self.GPPlaceView.frame.size
        
        self.GPPlaceView.bounds.size = CGSizeMake(self.GPPlaceView.bounds.size.height * 1.5, self.GPPlaceView.bounds.size.width)
    }
    
    func newSonarResultsAvailable(){
        print("newSonarResultsAvailable")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func search(){
        // This search function uses the bundeled apple search 
        // Apple search does not really return a whole lot and
        // they deliver just the most notable results in an area. 
        // The whole point is to find something new not
        // something that has been established... okay maybe not the point but at least that would be nice.
        let searchRequest = MKLocalSearchRequest()
        searchRequest.region = map.region
        searchRequest.naturalLanguageQuery = "bar"
        let search = MKLocalSearch(request: searchRequest)
        
        search.startWithCompletionHandler { (response, error) -> Void in
            
            if response != nil{
                for item in response!.mapItems {
                    print(item.description)
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = item.placemark.coordinate
                    annotation.title = item.name
                    self.map.addAnnotation(annotation)
                }
            }
        }
    }
    
    @IBAction func search(sender: AnyObject) {
        self.search()
        
    }
    
    @IBAction func googleSearch(sender: AnyObject) {
        googleSearch()
        
    }
    func googleSearch(){
        
        print("\(NSURLAddedToDirectoryDateKey)")
        self.GPQuery?.searchWith(self.lastLocation.coordinate)
    }
    
    @IBOutlet var button: UIButton!
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            1000, 1000)
        map.setRegion(coordinateRegion, animated: true)
    }
    
    
//---------------LocationManager delegation
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("received location")
        for location in locations{
           // println("going through the locations")
           // if location != nil{
                //println(mylocation.description)
                self.lastLocation = location
                if (shouldCenter) {
                    shouldCenter = false
                    centerMapOnLocation(location)
                }
                
            //}
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error.description)
    }
    
//-------------
    func mapView(_: MKMapView, didDeselectAnnotationView view: MKAnnotationView){
//        if let gpplace = view.annotation as? GPPlace{
//            
//        }
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        //check annotation is not user location
        if (annotation.isEqual(map.userLocation)) {
            //bail
            return nil;
        }
        
        var view = mapView.dequeueReusableAnnotationViewWithIdentifier("bech")
        
        if view == nil {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "bech")
            view!.canShowCallout = true
        } else {
            view!.annotation = annotation
        }
        
        view!.leftCalloutAccessoryView = nil
        view!.rightCalloutAccessoryView = nil
        
        if (annotation as? GPPlace != nil) {
            
            view!.image = UIImage(contentsOfFile: NSBundle.mainBundle().pathForResource("beer-glass-20", ofType: "png")!)
        }
        return view
    }
    
    @IBAction func showAnnotations(sender: AnyObject) {
//        var annotations = [AnyObject]()
//        for annot in map.annotations{
//            var annotat = annot 
//            annotations.append(annotat)
//        }
        self.map.showAnnotations(self.map.annotations, animated: true)
        }

    @IBAction func getMoreResults(sender: AnyObject) {
        GPQuery?.getNextTwentyResults()
        
    }
    
    
    func dropMapItems(mapItems:[GPPlace], seconds: Int){
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            // do some task
            let interval:Double = (Double(seconds) / Double(mapItems.count))
            print("The interval is:\(interval)")
            var x = 1
            for mItem in mapItems{
                
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(interval * Double( x++) * Double(NSEC_PER_SEC)))
                
                dispatch_after(delayTime, dispatch_get_main_queue()) {
                    self.map.addAnnotation(mItem as MKAnnotation)
                    self.map.showAnnotations(self.map.annotations, animated: false)
                    print("added annotation the count is now : \(self.map.annotations.count)")
                }
            }
        });
    }
    
    //googleplaces delegation
    func googlePlacesSearchResult(searchResult: [GPPlace]?, error: String?, sender: GPPlacesSearchQuery!) {
        
        if searchResult != nil{
            if let result = searchResult{
                for place in result{
                    //var annot = MKAnnotation
                }
            }
            
            print("sender.results?.count\(sender.searchResults.count)")
            if (sender.searchResults.count <= 20){
                // if we have 20 or less all in all then this is a new result.
                // remove all old results.
                map.removeAnnotations(map.annotations)
            }
            //there are actually mapitems returned.
            dropMapItems(searchResult!, seconds: 2)
        }
        else{
            //no mapitems found with that criteria.
        }
    }

}

