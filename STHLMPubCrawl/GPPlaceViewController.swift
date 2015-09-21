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
    
    @IBOutlet var typesLabel: UILabel!
    @IBOutlet var labelPlaceName: UILabel!
    @IBOutlet var barImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        // get place from file:
        self.view.layer.masksToBounds = true
        self.place?.describe()
        self.updateUI()
    }
    
    func updateUI(){
        if self.labelPlaceName != nil{
            self.labelPlaceName.text = place?.name
            self.showTypes()
            
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(3 * Double(NSEC_PER_SEC)))
            
            dispatch_after(time, dispatch_get_main_queue()) { () -> Void in
                self.showPhoto()
            }
        }
    }
    
    func showPhoto(){
        if self.place != nil {
            if self.place!.photos.count > 0 {
                let queue = dispatch_queue_create("ble", nil)
                dispatch_async(queue, { () -> Void in
                    let barImage = self.place?.photos[0].getImageFromWeb(nil ,maxHeight: 1000)
                    dispatch_async(dispatch_get_main_queue()) {
                        if barImage != nil{
                            self.barImageView.image = barImage
                        }
                    }
                })
            }
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
            //types = types.stringByReplacingOccurrencesOfString("\nestablishment", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            //types = types.stringByReplacingOccurrencesOfString("\nestablishment", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            
            self.typesLabel.numberOfLines = 0 //self.place!.types.count
            self.typesLabel.text = types
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
        print("ble ble ble3")
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
