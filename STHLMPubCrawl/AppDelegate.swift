//
//  AppDelegate.swift
//  SthlmBarCrawl
//
//  Created by Agust Rafnsson on 26/08/15.
//  Copyright (c) 2015 Agust Rafnsson. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let googleMapsApiKey = "AIzaSyB3kmbHXmOsIbZNyG4VCUc3R48Err5pEB4"
    

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        // do some task
        //let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_main_queue()) {
            GPSearchRadar.sharedInstance
            let gpQuery = GPPlacesSearchQuery (key: nil, rankByDistance: true, keyword: nil, language: nil, minPrice: nil, maxPrice: nil, name: nil, openNow: nil, types: [kGPTypeBar, kGPTypeNightClub])
            
            if gpQuery != nil{
                GPSearchRadar.sharedInstance.setQuery(gpQuery)
            }
        }
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

