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

    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var buttonAllNone: UIButton!
    
    var shouldCenter:Bool = true
    var showSelectedPlaceOnly = false


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
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

    @IBAction func buttonAllNonePressed() {
        showSelectedPlaceOnly = !showSelectedPlaceOnly
        if showSelectedPlaceOnly{
            self.buttonAllNone.setTitle("All", forState: UIControlState.Normal)
            map.removeAnnotations(map.annotations)
            if let place = GPSearchRadar.sharedInstance.currentPlace as? MKAnnotation{
                map.addAnnotation(place)
            }

        }
        else{
            self.buttonAllNone.setTitle("One", forState: UIControlState.Normal)
            map.removeAnnotations(map.annotations)
            map.addAnnotations(GPSearchRadar.sharedInstance.places)
        }
         map.showAnnotations(map.annotations, animated: true)
    }
    
    func layoutView(){
        //
        if showSelectedPlaceOnly {
            if GPSearchRadar.sharedInstance.currentPlace != nil{
                self.map.removeAnnotations(self.map.annotations)
                self.map.addAnnotation(GPSearchRadar.sharedInstance.currentPlace!)
                self.map.showAnnotations(map.annotations, animated: true)
            }
        }
        
        if GPSearchRadar.sharedInstance.currentPlace != nil{
            let currentPlaceAnnotationView = self.map.viewForAnnotation(GPSearchRadar.sharedInstance.currentPlace!)
            if currentPlaceAnnotationView != nil{
                // print("bringing this place to front  \(currentPlaceAnnotationView?.annotation?.title)")
                self.map.bringSubviewToFront(currentPlaceAnnotationView!)
            }
        }
    }
    
    func newSelectedPlace(){
        // print("initial view controller got a new place selected call")
        // find the annotation that
        self.layoutView()
    }
    
    func newSonarResultsAvailable(){
        if showSelectedPlaceOnly {
            
        }
        else{
            if GPSearchRadar.sharedInstance.places.count > 0 {
                self.dropMapItems((GPSearchRadar.sharedInstance.places)! , seconds: 2)
            }
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
    
//-------------
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        // print("selected annotation")
        if let place = view.annotation as? GPPlace{
            // print("it was an gpplace annotation")
            GPSearchRadar.sharedInstance.currentPlace = place
        }
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        //check annotation is not user location
        if (annotation.isEqual(map.userLocation)) {
            //bail
            return nil;
        }
        
        var view = mapView.dequeueReusableAnnotationViewWithIdentifier("bech") as? BarAnnotationView
        
        if view == nil {
            view = BarAnnotationView(annotation: annotation, reuseIdentifier: "bech")
            view!.canShowCallout = true
        } else {
            view!.annotation = annotation
        }
        
        view!.leftCalloutAccessoryView = nil
        view!.rightCalloutAccessoryView = nil
        
        if (view?.annotation as? GPPlace) == GPSearchRadar.sharedInstance.currentPlace{
            view?.currentPlace = true
        }
        else{
            view?.currentPlace = false
        }
        return view
    }
    
    func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView]) {
        for annotationView in views{
            if let place = annotationView.annotation as? GPPlace{
                if place != GPSearchRadar.sharedInstance.currentPlace{
                    map.sendSubviewToBack(annotationView)
                    // print("To the back: \(annotationView.annotation?.title)")
                }
                else{
                    map.bringSubviewToFront(annotationView)
                    // print("To the front: \(annotationView.annotation?.title)")
                }
            }
        }
    }
        
    /**
    This function drops mapitems on the map equally distributed over the time indicated.
    
    @mapItems An array of GPPlace objects to be dropped on the map
    
    @seconds How long the dropping is to take in seconds.
    */
    private func dropMapItems(mapItems:[GPPlace], seconds: Int){
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            // do some task
            let interval:Double = (Double(seconds) / Double(mapItems.count))
            // print("The interval is:\(interval)")
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

