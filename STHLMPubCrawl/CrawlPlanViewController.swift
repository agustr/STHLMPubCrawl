//
//  CrawlPlan.swift
//  STHLMPubCrawl
//
//  Created by Agust Rafnsson on 09/10/15.
//  Copyright © 2015 Agust Rafnsson. All rights reserved.
//

import UIKit
import MapKit
import Social

class CrawlPlanViewController: UIViewController, MKMapViewDelegate {

    private let sharingText:[String] = ["I'm going on an adventure", "Come and share in the beer", "I am a grown-up! I do what I want!", "FOR SCIENCE", "In the olden days drinking was so disorganised...", "I will conquer all the ale!", "EVERYONE FOLLOW ME!", "I think I will leave the car at home!"]
    
    @IBOutlet weak var mapView: MKMapView!
    
    var image:UIImage?
    
    override func viewDidLoad() {
        self.mapView.showsUserLocation = true
    }
    
    override func viewWillAppear(animated: Bool) {
        var places =  ARPlacesVisitPlan.sharedInstance.places
        mapView.addAnnotations(places)

        mapView.showAnnotations(mapView.annotations, animated: false)
        mapView.setVisibleMapRect(mapView.visibleMapRect, edgePadding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20), animated: true)
        
        //self.takeSnapshotOfTrack()

        
        for var x = 0 ; x < places.count - 1 ; x++  {
            showRouteBetween(places[x], destinationPlace: places[x+1])
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        mapView.showAnnotations(mapView.annotations, animated: false)
        mapView.setVisibleMapRect(mapView.visibleMapRect, edgePadding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20), animated: true)
        
    }
    
    @IBAction func shareOnFacebook(){
        self.takeSnapshotOfMapviewLarge()
        let shareToFacebook : SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
        
        let txt = sharingText[Int(arc4random_uniform(UInt32(sharingText.count)))]
        shareToFacebook.setInitialText(txt)
        shareToFacebook.addImage(self.image)
        self.presentViewController(shareToFacebook, animated: true) { () -> Void in
            // what would one do when one has shared?
        }
    }
    
    @IBAction func buttonShare(){
        let string: String = sharingText[Int(arc4random_uniform(UInt32(sharingText.count)))]
        let URL: NSURL = NSURL(fileURLWithPath: "http://www.google.com")
        
        let activityViewController = UIActivityViewController(activityItems: [string, URL], applicationActivities: nil)
        navigationController?.presentViewController(activityViewController, animated: true) {
            //...
        }
        
    }
    
    func takeSnapshotOfTrack(){
        let snapperOptions:MKMapSnapshotOptions = MKMapSnapshotOptions()
        snapperOptions.region = self.mapView.region
        snapperOptions.size = self.mapView.frame.size
        snapperOptions.scale = UIScreen.mainScreen().scale
        
        
        let snapper:MKMapSnapshotter = MKMapSnapshotter(options: snapperOptions)
        
        snapper.startWithCompletionHandler { (snapshot:MKMapSnapshot?, err:NSError?) -> Void in
            self.image = snapshot?.image
        }
    }
    
    func takeSnapshotOfTrackLarge(){
//        let map = MKMapView()
//        map.frame.size = CGSize(width: 1024, height: 1024)
//        map.addAnnotation(ARPlacesVisitPlan.sharedInstance.places as! MKAnnotation)
//        map.showAnnotations(mapView.annotations, animated: false)
//        map.setVisibleMapRect(mapView.visibleMapRect, edgePadding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20), animated: false)
        
        
        let snapperOptions:MKMapSnapshotOptions = MKMapSnapshotOptions()
        let region = self.regionForAnnotations(mapView.annotations)
        if region != nil{
            snapperOptions.region = region!  //self.mapView.region
        }
        snapperOptions.size = CGSize(width: 1024,height: 1024)
        snapperOptions.scale = UIScreen.mainScreen().scale
        
        
        let snapper:MKMapSnapshotter = MKMapSnapshotter(options: snapperOptions)
        
        snapper.startWithCompletionHandler { (snapshot:MKMapSnapshot?, err:NSError?) -> Void in
            self.image = snapshot?.image
        }
    }
    
    func takeSnapshotOfMapview(){
        UIGraphicsBeginImageContext(self.mapView.frame.size)
        self.mapView.showsUserLocation = false
        self.mapView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        self.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.mapView.showsUserLocation = true
    }
    
    func takeSnapshotOfMapviewLarge(){
        let size = self.mapView.frame.size
        defer{
//            self.mapView.frame.size = size
//            self.mapView.clipsToBounds = true
//            mapView.showAnnotations(mapView.annotations, animated: false)
//            mapView.setVisibleMapRect(mapView.visibleMapRect, edgePadding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20), animated: false)
        }
        let map = MKMapView()
        
        map.frame.size = CGSize(width: 512,height: 512)
        map.bounds.size = CGSize(width: 512,height: 512)
        map.clipsToBounds = true
        map.addAnnotations(ARPlacesVisitPlan.sharedInstance.places)
        
        let rect = self.MKMapRectForCoordinateRegion(self.regionForAnnotations(self.mapView.annotations)!)
//        mapView.setVisibleMapRect(region, edgePadding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20), animated: false)
        map.setVisibleMapRect(rect, animated: false)
        
        UIGraphicsBeginImageContext(self.mapView.frame.size)
        self.mapView.showsUserLocation = false
        self.mapView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        self.image = image
        UIGraphicsEndImageContext()
        self.mapView.showsUserLocation = true
    }
    
    func MKMapRectForCoordinateRegion(region:MKCoordinateRegion)-> MKMapRect
    {
        let a = MKMapPointForCoordinate(CLLocationCoordinate2DMake(region.center.latitude + region.span.latitudeDelta / 2,
        region.center.longitude - region.span.longitudeDelta / 2));
        let b = MKMapPointForCoordinate(CLLocationCoordinate2DMake(region.center.latitude - region.span.latitudeDelta / 2,
        region.center.longitude + region.span.longitudeDelta / 2));
        return MKMapRectMake( min(a.x, b.x), min(a.y, b.y), abs(a.x-b.x), abs(a.y-b.y));
    }
    
    func regionForAnnotations(annotations:[MKAnnotation]!) -> MKCoordinateRegion?{
        if(annotations.count == 0) {return nil}
    
        var topLeftCoord = CLLocationCoordinate2D()
        topLeftCoord.latitude = -90;
        topLeftCoord.longitude = 180;
    
        var bottomRightCoord = CLLocationCoordinate2D()
        bottomRightCoord.latitude = 90;
        bottomRightCoord.longitude = -180;
    
        for annotation in annotations
        {
            topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude)
            topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude)
        
            bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude)
            bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude)
        }
    
        var region = MKCoordinateRegion()
        region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
        region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
        region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.1
        region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.1
    
        return region
    }
    
    
    
    
    func showRouteBetween(sourcePlace:GPPlace, destinationPlace:GPPlace){
        
        let sourceItem = MKMapItem(placemark: MKPlacemark(coordinate: sourcePlace.coordinate, addressDictionary: nil))
        let destinationItem = MKMapItem(placemark: MKPlacemark(coordinate: destinationPlace.coordinate, addressDictionary: nil))
        
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
            
            
            for route in routes {
//                self.routes.append(route)
                print(" route.name: \(route.name) \n route.advisoryNotices: \(route.advisoryNotices) \n route.distance: \(route.distance) \n route.expectedTravelTime: \(route.expectedTravelTime)")
                self.mapView.addOverlay(route.polyline)
//                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
        }
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.blueColor()
        renderer.lineWidth = 5
        return renderer
    }
}


