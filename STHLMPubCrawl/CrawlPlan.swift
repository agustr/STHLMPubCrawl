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

class CrawlPlan: UIViewController, MKMapViewDelegate {

    let sharingText:[String] = ["I'm going on an adventure", "Come and share in the beer", "I am a grown-up! I do what I want!", "FOR SCIENCE", "In the olden days drinking was so disorganised...", "I will conquer all the ale!", "EVERYONE FOLLOW ME!", "I think I will leave the car at home!"]
    
    @IBOutlet weak var mapView: MKMapView!
    
    var image:UIImage?
    
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
        self.takeSnapshotOfMapview()
        let shareToFacebook : SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
        
        let txt = sharingText[Int(arc4random_uniform(UInt32(sharingText.count)))]
        shareToFacebook.setInitialText(txt)
        shareToFacebook.addImage(self.image)
        self.presentViewController(shareToFacebook, animated: true) { () -> Void in
            // what would one do when one has shared?
        }
    }
    
    func takeSnapshotOfTrack(){
        let snapperOptions:MKMapSnapshotOptions = MKMapSnapshotOptions()
        snapperOptions.region = self.mapView.region
        snapperOptions.size = self.mapView.frame.size
        snapperOptions.scale = UIScreen.mainScreen().scale // [[UIScreen mainScreen] scale]
        
        
        let snapper:MKMapSnapshotter = MKMapSnapshotter(options: snapperOptions)
        
        snapper.startWithCompletionHandler { (snapshot:MKMapSnapshot?, err:NSError?) -> Void in
            self.image = snapshot?.image
        }
    }
    
    func takeSnapshotOfMapview(){
        UIGraphicsBeginImageContext(self.mapView.frame.size)
        self.mapView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        self.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
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


