//
//  Utils.swift
//  PubCrawl
//
//  Created by Agust Rafnsson on 18/09/15.
//  Copyright (c) 2015 Agust Rafnsson. All rights reserved.
//

import Foundation
import AVFoundation

///// Photo Credit: Devin Begley, http://www.devinbegley.com/
//let OverlyAttachedGirlfriendURLString = "http://i.imgur.com/UvqEgCv.png"
//let SuccessKidURLString = "http://i.imgur.com/dZ5wRtb.png"
//let LotsOfFacesURLString = "http://i.imgur.com/tPzTg7A.jpg"

class Utilities {
    
    var GlobalMainQueue: dispatch_queue_t {
        return dispatch_get_main_queue()
    }
    
    var GlobalUserInteractiveQueue: dispatch_queue_t {
        return dispatch_get_global_queue(Int(QOS_CLASS_USER_INTERACTIVE.rawValue), 0)
    }
    
    var GlobalUserInitiatedQueue: dispatch_queue_t {
        return dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0)
    }
    
    var GlobalUtilityQueue: dispatch_queue_t {
        return dispatch_get_global_queue(Int(QOS_CLASS_UTILITY.rawValue), 0)
    }
    
    var GlobalBackgroundQueue: dispatch_queue_t {
        return dispatch_get_global_queue(Int(QOS_CLASS_BACKGROUND.rawValue), 0)
    }
    
}