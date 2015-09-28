//
//  ViewController.swift
//  SthlmBarCrawl
//
//  Created by Agust Rafnsson on 26/08/15.
//  Copyright (c) 2015 Agust Rafnsson. All rights reserved.
//

import UIKit
import MapKit



class InitialViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate{

    @IBOutlet var map: MKMapView!
    
    var shouldCenter:Bool = true
    var showSelectedPlaceOnly = true

    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "newSonarResultsAvailable", name: kGPSearchRadarNewResultsNotifier, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "newSelectedPlace", name: kGPSearchRadarNewSelectedPlaceNotifier, object: nil)
        // Do any additional setup after loading the view, typically from a nib.
        
        map.showsPointsOfInterest = false
        map.showsUserLocation = true
        map.rotateEnabled = false
        map.showAnnotations(map.annotations, animated: true)
    }
    
    func newSelectedPlace(){
        print("initial view controller got a new place selected call")
        // find the annotation that
        for annotation in map.annotations{
            if let place = annotation as? GPPlace{
                let annotationview = map.viewForAnnotation(place)
                annotationview?.image = UIImage(named: "beer-glass-20-BW")
            }
        }
        if let currentPlace = GPSearchRadar.sharedInstance.currentPlace as? MKAnnotation{
            print("change the look of the annotation.")
            let annotView = map.viewForAnnotation(currentPlace)
            annotView?.superview?.bringSubviewToFront(annotView!)
            annotView?.image = UIImage(named: "beer-glass-20")
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("the segue name is: \(segue.identifier)")
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func newSonarResultsAvailable(){
        print("newSonarResultsAvailable")
        if GPSearchRadar.sharedInstance.searchQuery?.searchResults.count > 0 {
            self.dropMapItems((GPSearchRadar.sharedInstance.searchQuery?.searchResults)! , seconds: 2)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            1000, 1000)
        map.setRegion(coordinateRegion, animated: true)
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error.description)
    }
    
//-------------
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        print("selected annotation")
        if let place = view.annotation as? GPPlace{
            print("it was an gpplace annotation")
            GPSearchRadar.sharedInstance.currentPlace = place
        }
    }
    
    func mapView(_: MKMapView, didDeselectAnnotationView view: MKAnnotationView){
    
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        //check annotation is not user location
        if (annotation.isEqual(map.userLocation)) {
            //bail
            return nil;
        }
        
        var view = mapView.dequeueReusableAnnotationViewWithIdentifier("bech")
        
        if view == nil {
            view = MKAnnotationView(annotation: annotation, reuseIdentifier: "bech")
            view!.canShowCallout = true
        } else {
            view!.annotation = annotation
        }
        
        view!.leftCalloutAccessoryView = nil
        view!.rightCalloutAccessoryView = nil
        
        if (annotation as? GPPlace != nil) {
            let img = UIImage(named: "beer-glass-20-BW")
            view!.image = img
        }
        return view
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
                   // print("added annotation the count is now : \(self.map.annotations.count)")
                }
            }
        });
    }
}

