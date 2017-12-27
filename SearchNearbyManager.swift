//
//  GoogleDataProvider.swift
//  ATMfinderV3
//
//  Created by Francis Jemuel Bergonia on 24/12/2017.
//  Copyright © 2017 Francis Jemuel Bergonia. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire

protocol newLocationsDelegate {
    
    // We want to return locations which have been found
    func returnNewLocations(locations: NSArray);
}


class SearchNearbyManager: NSObject {

    var delegate: newLocationsDelegate? = nil
    var locations = NSMutableArray()
    var searchTask = URLSessionDataTask()
    // Decide how large a radius we want to look into
    let regionRadius: CLLocationDistance = 5000
    // We want to have access to the root search URL so we can add new pages onto it
    var rootSearchURL = String()
    public var googleSearchURL = String()
    class var sharedInstance: SearchNearbyManager {
        struct singleton {
            static let instance = SearchNearbyManager()
        }
        return singleton.instance
    }
    
    func sendNewLocations(locations: NSArray) {
        if delegate != nil && locations.count > 0 {
            delegate?.returnNewLocations(locations: locations)
        }
    }
    
    // Google Web API received here
    public func getNearbyLocationsWithLocation(location: CLLocation) {
        //modification "insterted"
        let urlString : String = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?key=AIzaSyAdQsDZr6sNfbPBjvb6Mt8CzQSVk00FTLo&location="
        
        let latitude:String = "\(location.coordinate.latitude)"
        let longitude:String = "\(location.coordinate.longitude)"
        
        let radius = String(regionRadius)
        
        let keyword = String("atm")
        
        let newString = urlString + latitude + "," + longitude + "&radius=" + radius + "&keyword=" + keyword
        
        rootSearchURL = newString
        
        let url = URL(string: newString)
        
        googleSearchURL = newString
        
        self.getAllNearbyLocations(url: url!)
        
        print(rootSearchURL)
        
    }
    
    // This function loops over the returned JSON until we have recevied all the info
    func getAllNearbyLocations(url: URL) {
        
        self.getJsonFromURL(url: url) { (dictionary) in
            
            let newLocations: NSArray = dictionary.value(forKey: "results") as! NSArray
            self.locations.addObjects(from: newLocations as! [Any])
            
            // TODO Remove this check
            if self.locations.count >= 30 {
                self.sendNewLocations(locations: self.locations)
            }
            else {
                
                // We want to now update the URL we are using and search again
                if let newPageToken = dictionary["next_page_token"] {
                    
                    let newURL = self.rootSearchURL + "&pagetoken=" + (newPageToken as! String)
                    let url = URL(string: newURL)
                    
                    // There is a delay between making a request and the next page URL being available - we need to wait for this request
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                        // We want to get our current URL and remove the last characters from it
                        self.getAllNearbyLocations(url: url!)
                    }
                }
                else {
                    
                    // If we have no more pages then we return what we have
                    self.sendNewLocations(locations: self.locations)
                }
            }
        }
    }
    
    // This function returns the JSON from a specific URL
    func getJsonFromURL(url: URL, completionHandler: @escaping (NSDictionary) -> ()) {
        
        Alamofire.request(url).responseJSON { response in
            
            let json = response.result.value as! NSDictionary
            
            completionHandler(json)
        }
    }
    
}

