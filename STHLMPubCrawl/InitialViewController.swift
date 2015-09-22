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
    @IBOutlet var GPPlaceView: UIView!
//    
//    lazy var locationManager:CLLocationManager = {
//        print("initializing locationManager")
//        var temoraryLocationManager = CLLocationManager()
//        temoraryLocationManager.delegate = self
//        return temoraryLocationManager
//    }()
    
    var shouldCenter:Bool = true

    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "newSonarResultsAvailable", name: kGPSearchRadarNewResultsNotifier, object: nil)
        // Do any additional setup after loading the view, typically from a nib.
        //var initialLocation = CLLocation(latitude: 21.282778, longitude: -157.829444)
        
        map.showsPointsOfInterest = false
        map.showsUserLocation = true
        map.showAnnotations(map.annotations, animated: true)

        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("GPPlaceViewController") as? GPPlaceViewController
        if vc != nil{
            
            vc?.view.layer.borderWidth = 4
            vc?.view.layer.borderColor = UIColor.redColor().CGColor
            
            self.GPPlaceView.layer.borderColor = UIColor.yellowColor().CGColor
            self.GPPlaceView.layer.borderWidth = 2
            
            self.GPPlaceView.addSubview(vc!.view)
//            self.GPPlaceView.clipsToBounds = true
            print("current autoresizing mask: \(vc?.view.autoresizingMask))" )
            print("translate audto resizing mask\(vc?.view.translatesAutoresizingMaskIntoConstraints)")
            
//            self.GPPlaceView.addConstraint( NSLayoutConstraint(item: vc!,attribute: NSLayoutAttribute.Bottom,relatedBy: NSLayoutRelation.Equal,toItem: self.GPPlaceView,attribute: NSLayoutAttribute.Bottom,multiplier:nil,constant: nil))
            
            print("the frame of the pageing viewcontroller is: \(vc!.view.frame)")

            //vc!.view.bounds.size = self.GPPlaceView.bounds.size
            vc?.view.frame.size =  self.GPPlaceView.bounds.size
            

//            vc?.view.autoresizingMask = [.FlexibleWidth,.FlexibleHeight]

            
            print("Paging view controller frame : \(vc!.view.frame)")
            print("Paging view controller bounds : \(vc!.view.bounds)")
            
            //self.GPPlaceView.bounds.size = CGSizeMake(self.GPPlaceView.bounds.size.height * 1.5, self.GPPlaceView.bounds.size.width)
            //self.GPPlaceView.bringSubviewToFront(vc!.view)
        }
        else {
            print("could not load GPPlacePageViewController from storyboard")
        }
        
//        self.GPPlaceView.autoresizesSubviews = true
        
        //self.GPPlaceView.bounds.size = CGSizeMake(self.GPPlaceView.bounds.size.height * 1.5, self.GPPlaceView.bounds.size.width)
        
        
       
        //self.gpbarviewcontroller = storyboard.instantiateViewControllerWithIdentifier("GPPlaceViewController") as! GPPlaceViewController
        
        //self.GPPlaceView.addSubview(self.gpbarviewcontroller.view)
        
        //self.GPPlaceView.clipsToBounds = true
        //self.gpbarviewcontroller.view.frame.size = self.GPPlaceView.frame.size
        
        //self.GPPlaceView.bounds.size = CGSizeMake(self.GPPlaceView.bounds.size.height * 1.5, self.GPPlaceView.bounds.size.width)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.GPPlaceView.layoutSubviews()
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
    
    @IBOutlet var button: UIButton!
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            1000, 1000)
        map.setRegion(coordinateRegion, animated: true)
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error.description)
    }
    
//-------------
    func mapView(_: MKMapView, didDeselectAnnotationView view: MKAnnotationView){
    // deal with user selecting an annotation.
    
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

