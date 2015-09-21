//
//  BarsPageViewController.swift
//  STHLMPubCrawl
//
//  Created by Agust Rafnsson on 21/09/15.
//  Copyright © 2015 Agust Rafnsson. All rights reserved.
//

import UIKit
import Foundation

class BarsPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    var places:[GPPlace]?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print("setting up listener for \(kGPSearchRadarNewResultsNotifier)")
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "newSonarResultsAvailable", name: "kGPSearchRadarNewResultsNotifier", object: nil)
        self.delegate = self
        self.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func newSonarResultsAvailable(){
        
        print("receiving notification!")
        
        var nextPresentedViewController:GPPlaceViewController?
        let currentVC = self.viewControllers?.first as? GPPlaceViewController
        
        if currentVC?.place != nil {
            let currentPlaceIndex = self.isPlace(currentVC!.place!, Places: GPSearchRadar.sharedInstance.searchQuery!.searchResults)
            if currentPlaceIndex != nil{
                 nextPresentedViewController = self.getViewControllerFor(currentPlaceIndex!)
            }
        }
        if nextPresentedViewController == nil {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            nextPresentedViewController = storyboard.instantiateViewControllerWithIdentifier("GPPlaceViewController") as? GPPlaceViewController
            if nextPresentedViewController != nil{
                nextPresentedViewController!.place = GPSearchRadar.sharedInstance.searchQuery?.searchResults.first
            }
        }
        if nextPresentedViewController != nil{
            self.setViewControllers([nextPresentedViewController!], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
        }
    }
    
    ///
    func isPlace(Place:GPPlace, Places: [GPPlace])-> Int?{
        for arrPlace in Places{
            if arrPlace.placeID == Place.placeID{
                return Places.indexOf(arrPlace)
            }
        }
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        print("viewControllerAfterViewController")
        let currentIndex = self.indexOfCurrentPlace()
        if currentIndex != nil{
            let nextIndex = currentIndex! + 1
            if ((0 <= nextIndex) && (nextIndex <= (GPSearchRadar.sharedInstance.searchQuery?.searchResults.count)!-1)){
                return self.getViewControllerFor(nextIndex)
            }
        }
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        print("viewControllerBeforeViewController")
        let currentIndex = self.indexOfCurrentPlace()
        if currentIndex != nil{
            let nextIndex = currentIndex! - 1
            if ((0 <= nextIndex) && (nextIndex <= (GPSearchRadar.sharedInstance.searchQuery?.searchResults.count)!-1) ){
                return self.getViewControllerFor(nextIndex)
            }
        }
        return nil
    }
    
    func getViewControllerFor(index:Int)->GPPlaceViewController?{
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let barViewController = storyboard.instantiateViewControllerWithIdentifier("GPPlaceViewController") as! GPPlaceViewController
        barViewController.place = GPSearchRadar.sharedInstance.searchQuery?.searchResults[index]
        return barViewController
    
    }
    
    func indexOfCurrentPlace()->Int?{
        let currentVC = self.viewControllers?.first as? GPPlaceViewController
        if currentVC != nil{
            if currentVC!.place != nil{
                let indexCP = GPSearchRadar.sharedInstance.searchQuery?.searchResults.indexOf(currentVC!.place!)
                return indexCP
            }
        }
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if (finished) {
            if let currentVC = previousViewControllers.first as? GPPlaceViewController{
                GPSearchRadar.sharedInstance.currentPlace = currentVC.place
            }
        }
    }
    
    


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
