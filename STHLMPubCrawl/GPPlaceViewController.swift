//
//  GPPlaceViewController.swift
//  SthlmBarCrawl
//
//  Created by Agust Rafnsson on 11/09/15.
//  Copyright (c) 2015 Agust Rafnsson. All rights reserved.
//

// import Kingfisher

import SDWebImage
import UIKit
import Cosmos


class GPPlaceViewController: UIViewController {

    var place:GPPlace?{
        didSet{
            if self.isViewLoaded(){
                self.updateUI()
            }
        }
    }

    @IBOutlet var labelNoPhoto: UILabel!
    @IBOutlet var typesLabel: UILabel!
    @IBOutlet var labelPlaceName: UILabel!
    @IBOutlet var barImageView: UIImageView!
    @IBOutlet weak var ratingStars: CosmosView!
    
    var isGeometryReady: Bool! = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.parentViewController != nil{
            self.view.frame.size = self.parentViewController!.view.frame.size
            self.view.layoutSubviews()
        }
        // print("viewDidLoad \(self.place?.name) \(self.view.frame.size)  self.parentViewController?.view.frame.size \(self.parentViewController?.view.frame.size)")
        // Do any additional setup after loading the view.
        // get place from file:
        self.view.layer.masksToBounds = true
        self.updateUI()
        self.barImageView.image = UIImage(named: "nonobarimage")
        self.labelNoPhoto.hidden = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if self.parentViewController != nil{
            self.view.frame.size = self.parentViewController!.view.frame.size
            self.view.layoutSubviews()
        }
        // print("viewWillAppear \(self.place?.name) \(self.view.frame.size)  self.parentViewController?.view.frame.size \(self.parentViewController?.view.frame.size)")

        isGeometryReady = true
        self.view.frame.size =  (self.parentViewController?.view.frame.size)!
        self.updateUI()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // print("viewDidAppear \(self.place?.name) \(self.view.frame.size) self.parentViewController?.view.frame.size \(self.parentViewController?.view.frame.size)")
        self.place?.getDetails({ () -> Void in
            self.updateUI()
        })
    }
    
    override func willMoveToParentViewController(parent: UIViewController?) {
        super.willMoveToParentViewController(parent)
        // print("willMoveToParentViewController \(self.place?.name) \(self.view.frame.size) self.parentViewController?.view.frame.size \(self.parentViewController?.view.frame.size)")
    }
    
    override func didMoveToParentViewController(parent: UIViewController?) {
        super.didMoveToParentViewController(parent)
        // print("didMoveToParentViewController \(self.place?.name) \(self.view.frame.size) self.parentViewController?.view.frame.size \(self.parentViewController?.view.frame.size)")
    }
    
    
    
    
    private func updateUI(){
        
        if let rate = self.place?.rating{
            self.ratingStars.hidden = false
            self.ratingStars.rating = rate
        }
    
        if self.labelPlaceName != nil{
            self.labelPlaceName.text = place?.name
            self.showTypes()
        }
        
        
        if let photo = self.place?.photos.first {
            if (self.isGeometryReady == true) {
                // print("has photo, geometry is ready \(self.place?.name)")
                self.sdSetPhoto(photo)
            }
            else{
                // print("gemetry not ready")
            }
        }
        else {
            if (self.place?.hasGottenDetails == false){
                // print("getting details for place with callback \(self.place?.name)")
                self.place?.getDetails({ () -> Void in
                    // print("in the callback for getting details \(self.place?.name)")
                    if self.isGeometryReady == true {
                        // print("in the callback for getting details and the geometry is set \(self.place?.name) ")
                        //self.showPhoto()
                        if let photo = self.place?.photos.first{
                            self.sdSetPhoto(photo)
                        }
                    }
                    else{
                        self.labelNoPhoto.hidden = false
                    }
                })
            }
            else{
                self.labelNoPhoto.hidden = false
            }
        }
    }
    
    func sdSetPhoto(photo:GPPhoto!){
        GPSearchRadar.sharedInstance.sizeImagePrefetch = self.barImageView.frame.size
        let url = photo.getImageRequestUrlThatFitsContainerOfSize(self.barImageView.frame.size)
        print("setting the image in GPPlaceViewController: \(url)")
        
        self.barImageView.sd_setImageWithURL(url!, placeholderImage: nil, options: SDWebImageOptions(rawValue: 0), progress: { (receivedSize, totalSize) -> Void in
            }) { (image, error, imageCacheType, url) -> Void in
                self.labelNoPhoto.hidden = true
                print("finished downloading photo for \(self.place?.name) using cachetype: \(imageCacheType.hashValue)")
        }
    }
    
    func showTypes(){
        if self.place != nil{
            var types = String()
            var firstPass = true
            for type in self.place!.types{
                if !((type == "establishment") || (type == "point_of_interest")){
                    if firstPass{
                        firstPass=false
                    }
                    else{
                        types = types + "\n"
                    }
                    types = types + type
                }
            }
            types = types.stringByReplacingOccurrencesOfString("meal_", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            types = types.stringByReplacingOccurrencesOfString("_", withString: " ", options: NSStringCompareOptions.LiteralSearch, range: nil)
            
            self.typesLabel.numberOfLines = 0 //self.place!.types.count
            self.typesLabel.text = types
        }
        else{
            self.typesLabel.text = nil
        }
    }
    
    override func observeValueForKeyPath(keyPath: String?,
        ofObject object: AnyObject?, change: [String : AnyObject]?,
        context: UnsafeMutablePointer<Void>) {
            if context == &self.place {
                // print("Change at keyPath = \(keyPath) for \(object)")
            }
    }
    

    
    func downloadImage(url:NSURL){
        //print("Started downloading \"\(url.lastPathComponent!.stringByDeletingPathExtension)\".")
        getDataFromUrl(url) { data in
            dispatch_async(dispatch_get_main_queue()) {
                //      print("Finished downloading \"\(url.lastPathComponent!.stringByDeletingPathExtension)\".")
                self.barImageView.image = UIImage(data: data!)
            }
        }
    }
    
    func getDataFromUrl(urL:NSURL, completion: ((data: NSData?) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(urL) { (data, response, error) in
            completion(data: data)
            }.resume()
    }
    
    func getPlaceFromFile(){
        var dict = NSDictionary()
        let filePathStr = NSBundle.mainBundle().URLForResource("place", withExtension: "txt")?.path
        if filePathStr != nil{
            let data = NSData(contentsOfFile: filePathStr!)
            
            do {
                
                let jdict = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary
                if jdict != nil {
                    dict = jdict!
                }
                // statements
                
            } catch let caught as NSError {
                print("could not serialise data, localizedDescription: \(caught.localizedDescription)")
                print("could not serialise data, localizedFailureReason: \(caught.localizedFailureReason)")
                //statements
                
            }
            catch{
                print("caught an exeption serialising json but it was not an nserror")
            }
            
        }
        
        var results = dict["results"] as? Array<NSDictionary>
        let tempdict = results![0]
        self.place = GPPlace(dict: tempdict)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
