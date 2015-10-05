//
//  GooglePlaces.swift
//  SthlmBarCrawl
//
//  Created by Agust Rafnsson on 12/09/15.
//  Copyright (c) 2015 Agust Rafnsson. All rights reserved.

// ------------------------------------------------------------------------------------------
// Ref: https://developers.google.com/places/documentation/search#PlaceSearchRequests
//
// Example search
//
// https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=-33.8670522,151.1957362&radius=500&types=food&name=cruise&key=AddYourOwnKeyHere
//
// required parameters: key, location, radius
// ------------------------------------------------------------------------------------------
// ------------------------------------------------------------------------------------------
// -------- Implementation Idea -------------------------------------------------------------
// GooglePlacesSearchObject should be immutable
// Create a GooglePlacesSearchObject with all the parameters wanted (some requred parameters, some optional)
// Invoke a search -> the delegate gets a response containing the search object
// if the search is successfull the object contains an array of map points and it 
// contains an indicator of wether there are more results to be found ie pageToken
// -----------------------------
// notes
// the parameter rankby=distance is incompatible with the parameter radius=1000 so we need to check that only either one is set.
//

import CoreLocation
import Foundation
import MapKit

protocol GooglePlacesDelegate {
    func googlePlacesSearchResult(searchResult: [GPPlace]?, error: String?, sender: GPPlacesSearchQuery!)
}

class GPPlacesSearchQuery{
    
    private let URL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
    private let LOCATION = "location="
    private let RADIUS = "radius="
    
    
    //variables needed for a query are all set at initialisation
    let key:String! // I see no reason for this key to change throughout the lifetime of the object.
    let radius:Int?
    let rankByDistance:Bool?
    let keyword:String?
    let language:String?
    let minPrice:Int?
    let maxPrice:Int?
    let name:String?
    let openNow:Bool?
    let types:[String]?
    var wantedNumberOfResults:Int = 0
    private(set) var searchResults:[GPPlace] = [GPPlace]()
    
    /// This is the last used search location for this search query. 
    var searchLocation:CLLocationCoordinate2D? = nil
    
    private var lastReceivedPageToken : String? = nil
    
    var delegate : GooglePlacesDelegate? = nil
    
    var hasMoreResultsAvailable:Bool{
        get{
            if lastReceivedPageToken != nil {
                return true
            }
            return false
        }
    }
    
    // ------------------------------------------------------------------------------------------
    // init requires google.plist with key "places-key" or it will return nil
    //
    // ------------------------------------------------------------------------------------------
    init?(key:String?, radius: Int!, keyword:String?, language:String?, minPrice:Int?, maxPrice:Int?, name:String?, openNow:Bool?, types:[String]?){
//        Required parameters
//        
//        key — Your application's API key. This key identifies
//        your application for purposes of quota management and
//        so that places added from your application are made
//        immediately available to your app. Visit the Google
//        Developers Console to create an API Project and
//        obtain your key.
//        
//        location — The latitude/longitude around which to
//        retrieve place information. This must be specified
//        as latitude,longitude.
//        
//        radius — Defines the distance (in meters) within which
//        to return place results. The maximum allowed radius is
//        50 000 meters. Note that radius must not be included if
//        rankby=distance (described under Optional parameters
//        below) is specified.
//        
//        If rankby=distance (described under Optional parameters below) is specified, then one or more of keyword, name, or types is required.
        if (key==nil) {
            let gpKey = NSBundle.mainBundle().infoDictionary?["places-key"] as! String
            self.key = gpKey
        }else{
            self.key = key
        }
        
        self.radius = radius
        self.keyword = keyword
        self.language = language
        self.minPrice = minPrice
        self.maxPrice = maxPrice
        self.name = name
        self.openNow = openNow
        self.types = types
        self.rankByDistance = false
    }
    
    init?(key:String?, rankByDistance:Bool!, keyword:String?, language:String?, minPrice:Int?, maxPrice:Int?, name:String?, openNow:Bool?, types:[String]?){
        
        if (key==nil) {
            let gpKey = NSBundle.mainBundle().infoDictionary?["places-key"] as! String
            self.key = gpKey
        }else{
            self.key = key
        }
        
        self.radius = nil
        self.keyword = keyword
        self.language = language
        self.minPrice = minPrice
        self.maxPrice = maxPrice
        self.name = name
        self.openNow = openNow
        self.types = types
        self.rankByDistance = rankByDistance
        
       // print("\(self.keyword==nil)  \n \(self.name==nil)  \n \(self.types==nil) \(self.types?.count==0)")
        
        if (self.key==nil){ return nil }
        
        if((self.keyword==nil || self.keyword=="")&&(self.name==nil || self.name=="")&&(self.types==nil || self.types?.count==0)){
           // print("One of the parameters 'keyword', 'name', 'types' must be set")
            return nil
        }
        
        if(!rankByDistance) {
           // print("rankByDistance must be set to 'true'")
            return nil
        }
        
    }

    
    // ------------------------------------------------------------------------------------------
    // Google Places search with callback
    // ------------------------------------------------------------------------------------------
    private func search(
        location : CLLocationCoordinate2D,
        callback : (items : [GPPlace]?, errorDescription : String?) -> Void) {
            
            // var urlString = "\(URL)\(LOCATION)\(location.latitude),\(location.longitude)&\(RADIUS)\(radius)&\(KEY)"
            
            self.searchLocation = location // updating the location of the query
            self.searchResults = []             // since we are querying a new area remove the old results

            let url = self.createQueryUrl()
            
            if (url != nil) {
                let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
                session.dataTaskWithURL(url!, completionHandler: { (data : NSData?, response : NSURLResponse?, error : NSError?) -> Void in
                    
                    if error != nil {
                        
                        callback(items: nil, errorDescription: error!.localizedDescription)
                    }
                    
                    if let statusCode = response as? NSHTTPURLResponse {
                        if statusCode.statusCode != 200 {
                            callback(items: nil, errorDescription: "Could not continue.  HTTP Status Code was \(statusCode)")
                        }
                    }
                    
                    if data != nil{
                        let newResults = self.parseFromData(data!)
                        self.searchResults = self.searchResults + newResults
                        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                            callback(items: newResults, errorDescription: nil)
                        })
                    }
                }).resume()
            }
            
    }
    
    /// SearchWith location is the heart of this class.
    /// Call this function with a location to get the results for that 
    /// location. The location of the query changes when this is called.
    /// Old results are deleted since they are automatically invalid for a new location.
    func searchWith( location : CLLocationCoordinate2D ) {
            self.search(location) { (items, errorDescription) -> Void in
                if self.delegate != nil {
                    NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                        self.delegate!.googlePlacesSearchResult(items, error: errorDescription, sender: self)
                    })
                }
            }
            
    }
    
    /// Creates an url with the appropriate query.
    private func createQueryUrl()->NSURL?{
        
        var urlString = "\(URL)\(LOCATION)\(self.searchLocation!.latitude),\(self.searchLocation!.longitude)&key=\(self.key)"
        
        urlString = self.addRankBy(urlString, rankByDistance: self.rankByDistance)
        urlString = self.addNameToUrl(urlString, name: self.name)
        urlString = self.addTypesToUrl(urlString, types: self.types)
        urlString = self.addLanguageToUrl(urlString, lang: self.language)
        urlString = self.addMinMaxPrice(urlString, minPrice: self.minPrice, maxPrice: self.maxPrice)
        
        let urlEncodedString = urlString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        
        if urlEncodedString != nil {
            urlString = urlEncodedString!
        }
        else{
            urlString = ""
        }
        
       // print("the URL where we are getting the data from is \n \(urlEncodedString)")
        
        return NSURL(string: urlString)
    }
    
    // ------------------------------------------------------------------------------------------
    // Parse JSON into array of MKMapItem
    // ------------------------------------------------------------------------------------------
    /// Takes a json data response and returns an array containing the GPPlace's that the response produced.
    /// Always returns an array if no places were found the array is empty.
    private func parseFromData(data : NSData) -> [GPPlace] {
       // print("parsing json")
        var mapItems:[GPPlace]=[]
        let json = (try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers)) as? NSDictionary
        let results = json?["results"] as? Array<NSDictionary>
        
        if let token = json?["next_page_token"] as? String{
            self.lastReceivedPageToken = token
        }
        else{
            self.lastReceivedPageToken = nil
        }

        for result in results! {
            let place = GPPlace(dict: result)
            if (place != nil) {
                mapItems.append(place!)
            }
        }        
        return mapItems
    }

    /// pagetoken — Returns the next 20 results from a previously run search.
    /// Setting a pagetoken parameter will execute a search with the same
    /// parameters used previously — all parameters other than pagetoken will be ignored.
    func getNextTwentyResults(){

       // print("getNextTwentyResults now the \(self.searchResults.count)")
        if (self.lastReceivedPageToken != nil){
            var urlString:String? = "\(URL)key=\(self.key)&pagetoken=\(self.lastReceivedPageToken!)"
            urlString = urlString!.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            var url:NSURL?
            
           // print("getNextTwentyResults url: \(urlString)")
            
            if urlString != nil{
                url = NSURL(string: urlString!)
            }
            
            if (url != nil) {
                let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
                session.dataTaskWithURL(url!, completionHandler: { (data : NSData?, response : NSURLResponse?, error : NSError?) -> Void in
                    
                    if error != nil {
                        self.delegate?.googlePlacesSearchResult(nil, error: error!.localizedDescription, sender: self)
                    }
                    
                    if let statusCode = response as? NSHTTPURLResponse {
                        if statusCode.statusCode != 200 {
                            self.delegate?.googlePlacesSearchResult(nil, error: "Could not continue.  HTTP Status Code was \(statusCode)", sender: self)
                        }
                    }
                    if data != nil{
                        let newResults = self.parseFromData(data!)
                        self.searchResults.appendContentsOf(newResults)
                        
                        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                        self.delegate?.googlePlacesSearchResult(newResults, error: nil, sender: self)})
                    }
                    
                   // print("After: self.searchresults: \(self.searchResults.count)")
                }).resume()
            }
        }
        
    }

    /// zagatselected — Add this parameter (just the parameter name, with
    /// no associated value) to restrict your search to locations that are
    /// Zagat selected businesses. This parameter must not include
    /// a true or false value. The zagatselected parameter is experimental,
    /// and is only available to Google Places API for Work customers.
    //
    /// Maps API for Work customers should not include a client or signature
    /// parameter with their requests.
    private func addZagatSelected(url:String)->String{
        return url
    }
    
    /// keyword — A term to be matched against all content that Google
    /// has indexed for this place, including but not limited to name,
    /// type, and address, as well as customer reviews and other third-party content.
    private func addKeyword(url:String, keyword:String?)->String{
        return url
    }

    /// rankby — Specifies the order in which results are listed. Possible values are:
    ///
    /// prominence (default). This option sorts results based on their importance. Ranking
    /// will favor prominent places within the specified area. Prominence can be
    /// affected by a place's ranking in Google's index, global popularity, and other factors.
    ///
    /// distance. This option sorts results in ascending order by their distance from the
    /// specified location. When distance is specified, one or more of keyword, name, or types is required.
    private func addRankBy(url:String, rankByDistance:Bool?)->String{
        var urlString = url
        if (rankByDistance==true) {
            urlString = "\(urlString)&rankby=distance"
        }
        //rankby prominence is default if distance is not selected.
        
        return urlString
    }
    
    /// opennow — Returns only those places that are open for business at the
    /// time the query is sent. Places that do not specify opening hours in
    /// the Google Places database will not be returned if you include this
    /// parameter in your query.
    private func addOpenNow(url:String, isOpen:Bool?)->String{

        var urlString = url
        
        if (isOpen == true){
            urlString = "\(urlString)&opennow"
        }
        
        return urlString
    }

    /// minprice and maxprice (optional) — Restricts results to only those places
    /// within the specified range. Valid values range between 0 (most affordable) to 4 (most expensive),
    /// inclusive. The exact amount indicated by a specific value will vary from region to region.
    private func addMinMaxPrice(url:String, minPrice:Int?, maxPrice:Int?)->String{
        var urlString = url
        if ((minPrice <= 4) && (minPrice != nil)){
            urlString = "\(urlString)&minprice=\(minPrice)"
        }
        if ((maxPrice <= 4) && (maxPrice != nil)){
            urlString = "\(urlString)&maxprice=\(maxPrice)"
        }
        return url
    }
    
    /// language — The language code, indicating in which language the results
    /// should be returned, if possible. See the list of supported languages
    /// and their codes: https://developers.google.com/maps/faq#languagesupport
    /// Note that we often update supported languages so this list may not be exhaustive.
    private func addLanguageToUrl(url:String, lang:String?)->String{


        /// TODO: Implementation of language feature is not ready
        /// FIXME: Implement the addition of the language feature
        return url
    }
    
    /// name — One or more terms to be matched against the names of places,
    /// separated with a space character. Results will be restricted to those
    /// containing the passed name values. Note that a place may have
    /// additional names associated with it, beyond its listed name. The API
    /// will try to match the passed name value against all of these names.
    /// As a result, places may be returned in the results whose listed names do
    /// not match the search term, but whose associated names do.
    private func addNameToUrl(url:String, name:String?)->String{
        
        if let name = name as String! {
            if !name.isEmpty{
                // the string is not nil and not empty
                let urlString = "\(url)&name=\(name)"
                return urlString
            }
            else{
               // print("an empty name string has been passed")
            }
        }
        else{
           // print("we dont have a name string")
        }
        return url
    }
    
    /// types — Restricts the results to places matching at least one
    /// of the specified types. Types should be separated with a pipe symbol
    /// (type1|type2|etc). See the list of supported types:
    /// https://developers.google.com/maps/documentation/places/supported_types
    private func addTypesToUrl(url:String, types:[String]?)->String{

        if types == nil{
            return url
        }
        
        var newUrl = url
        var firstPass = true
        
        for type in types!{
            
            if firstPass {
                firstPass = false
                newUrl = "\(newUrl)&type=\(type)"
            }
            else{
                newUrl = "\(newUrl)|\(type)"
            }
            
            // print("\(type)")
        }
        
        return newUrl
    }
}



let kGPTypeAccounting = "accounting"
let kGPTypeAirport = "airport"
let kGPTypeAmusmentPark = "amusement_park"
let kGPTypeAquarium = "aquarium"
let kGPTypeArt_Gallery = "art_gallery"
let kGPTypeAtm = "atm"
let kGPTypeBakery = "bakery"
let kGPTypeBank = "bank"
let kGPTypeBar = "bar"
let kGPTypeBeutySalon = "beauty_salon"
let kGPTypeBicycleStore = "bicycle_store"
let kGPTypeBookStore = "book_store"
let kGPTypeBowlingAlley = "bowling_alley"
let kGPTypeBusStation = "bus_station"
//cafe
//campground
//car_dealer
//car_rental
//car_repair
//car_wash
//casino
//cemetery
//church
//city_hall
//clothing_store
//convenience_store
//courthouse
//dentist
//department_store
//doctor
//electrician
//electronics_store
//embassy
//establishment
//finance
//fire_station
//florist
//food
//funeral_home
//furniture_store
//gas_station
//general_contractor
//grocery_or_supermarket
//gym
//hair_care
//hardware_store
//health
//hindu_temple
//home_goods_store
//hospital
//insurance_agency
//jewelry_store
//laundry
//lawyer
//library
//liquor_store
//local_government_office
//locksmith
//lodging
//meal_delivery
//meal_takeaway
//mosque
//movie_rental
//movie_theater
//moving_company
//museum
let kGPTypeNightClub = "night_club"
//painter
//park
//parking
//pet_store
//pharmacy
//physiotherapist
//place_of_worship
//plumber
//police
//post_office
//real_estate_agency
//restaurant
//roofing_contractor
//rv_park
//school
//shoe_store
//shopping_mall
//spa
//stadium
//storage
//store
//subway_station
//synagogue
//taxi_stand
//train_station
//travel_agency
//university
//veterinary_care
//zoo