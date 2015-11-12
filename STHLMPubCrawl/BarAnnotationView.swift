//
//  BarAnnotationView.swift
//  STHLMPubCrawl
//
//  Created by Agust Rafnsson on 01/10/15.
//  Copyright © 2015 Agust Rafnsson. All rights reserved.
//

import UIKit
import MapKit

class BarAnnotationView: MKAnnotationView {
    
    
    
    var currentPlace:Bool = false{
        didSet{
            if currentPlace == false{
                self.image = UIImage(named: "beer-glass-20-BW")
                self.superview?.sendSubviewToBack(self)
            }
            else {
                self.image = UIImage(named: "beer-glass-20")
                self.superview?.bringSubviewToFront(self)
            }
        }
    }
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        //print("override init(annotation: MKAnnotation?, reuseIdentifier: String?)")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.image = UIImage(named: "beer-glass-20-BW")
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "newSelectedPlace", name: kGPSearchRadarNewSelectedPlaceNotifier, object: nil)
    }
    
    func newSelectedPlace (){
        if let place = self.annotation as? GPPlace{
            if place == GPSearchRadar.sharedInstance.currentPlace{
                self.currentPlace = true
            }
            else {
                self.currentPlace = false
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
