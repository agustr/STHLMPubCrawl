//
//  GPPlaceViewController.swift
//  SthlmBarCrawl
//
//  Created by Agust Rafnsson on 11/09/15.
//  Copyright (c) 2015 Agust Rafnsson. All rights reserved.
//

import UIKit


class GPPlaceViewController: UIViewController {
    
    var place:GPPlace?{
        didSet{
            self.updateUI()
        }
    }
    
    @IBOutlet var labelNoPhoto: UILabel!
    @IBOutlet var typesLabel: UILabel!
    @IBOutlet var labelPlaceName: UILabel!
    @IBOutlet var barImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        // get place from file:
        self.view.layer.masksToBounds = true
        self.updateUI()
        self.barImageView.image = UIImage(named: "nonobarimage")
        self.labelNoPhoto.hidden = true
    }
    
    func updateUI(){
        if self.labelPlaceName != nil{
            self.labelPlaceName.text = place?.name
            //self.labelPlaceName.text = "stuffit"
            self.showTypes()
            
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(3 * Double(NSEC_PER_SEC)))
            
            dispatch_after(time, dispatch_get_main_queue()) { () -> Void in
                self.showPhoto()
            }
        }
    }
    
    func showPhoto(){
        print("show photo")
        if self.place != nil {
            let photo = self.place?.photos.first
            if photo != nil{
                let queue = dispatch_queue_create("ble", nil)
                dispatch_async(queue, { () -> Void in
                    let maxHeigt = Int(CGFloat(photo!.height) * (self.maxPhotoResizeFactor(photo!.size, containerSize: self.barImageView.frame.size)))
                    print("the max heigt is : \(maxHeigt)")
                    let barImage = photo!.getImageFromWeb(nil ,maxHeight: maxHeigt)
                    dispatch_async(dispatch_get_main_queue()) {
                        if barImage != nil{
                            self.barImageView.image = barImage
                        }else{
                            print("no photo available online for this place")
                            self.labelNoPhoto.hidden = false
                        }
                    }
                })
            }
            else{
                print("no photo in the photo array for this place")
                self.labelNoPhoto.hidden = false
            }
        }
    }
    
    /// Returns the resize factor needed to make the photo be able to fill the container 
    /// both horizontally and vertically. (the container is assumed to use resize to fill)
    func maxPhotoResizeFactor(photoSize:CGSize!, containerSize: CGSize!)->CGFloat{
        let widthToWidthFactor = (containerSize.width / photoSize.width)
        let heigtToHeigtFactor = (containerSize.height /  photoSize.height)
        let WidthToHeightFactor = (containerSize.width / photoSize.height)
        let HeigthToWidthFactor = (containerSize.height / photoSize.width)
        return max(max(widthToWidthFactor, heigtToHeigtFactor), max(WidthToHeightFactor,HeigthToWidthFactor))
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
                print("Change at keyPath = \(keyPath) for \(object)")
            }
    }
    
    override func viewDidLayoutSubviews() {
        self.view.layoutIfNeeded()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.place?.getDetails(false)
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
