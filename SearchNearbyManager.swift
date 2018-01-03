//
//  SearchNearbyManager.swift
//  ATMFinder-GoogleMaps
//
//

import UIKit
import CoreLocation
import Alamofire

protocol newLocationsDelegate {
    
    // We want to return locations which have been found
    func returnNewLocations(locations: NSArray);
}

    /***************************************************************/

//URL for tables to use and view assigned at ATMListVC
    var newTableURL = String()


    /***************************************************************/

class SearchNearbyManager: NSObject {
    
    var delegate: newLocationsDelegate? = nil
    var locations = NSMutableArray()
    var searchTask = URLSessionDataTask()
    // Decide how large a radius we want to look into
    let regionRadius: CLLocationDistance = 1000
    // We want to have access to the root search URL so we can add new pages onto it
    var rootSearchURL = String()
    

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
    
    /***************************************************************/
    
    // Google Web API received here
    public func getNearbyLocationsWithLocation(location: CLLocation) {
        //modification "insterted"
        let urlString : String = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?key=AIzaSyAKF_fZmL8QQFIjpuELxAsuqbJd7ChME48&location="
        let latitude:String = "\(location.coordinate.latitude)"
        let longitude:String = "\(location.coordinate.longitude)"
        let radius = String(regionRadius)
        let keyword = String("atm")
        let firstString = urlString + latitude + "," + longitude
        let secondString = "&radius=" + radius + "&keyword=" + keyword!
        let newString = firstString + secondString
        rootSearchURL = newString
        let url = URL(string: newString)
        newTableURL = newString
        self.getAllNearbyLocations(url: url!)
        //self.getNearbyLocationsOnce(url: url!)
        print("***************************** Google API Successfuly Received! **********************************")
    }
    
        /***************************************************************/
    
    // This function loops over the returned JSON until we have recevied all the info
    func getAllNearbyLocations(url: URL) {
        
        self.getJsonFromURL(url: url) { (dictionary) in
            
            let newLocations: NSArray = dictionary.value(forKey: "results") as! NSArray
            self.locations.addObjects(from: newLocations as! [Any])
            self.sendNewLocations(locations: self.locations)
            self.locations.removeAllObjects()
        
            // TODO Remove this check
            if self.locations.count == 20 {
                print("***************************** RECEIVED 20 API Locations **********************************")
            } else {
                    print("***************************** Google Maps Services Currently Unavailable, pls. contact customer support **********************************")
                }
            }
        }
    

    /***************************************************************/
    
    // This function returns the JSON from a specific URL
    func getJsonFromURL(url: URL, completionHandler: @escaping (NSDictionary) -> ()) {
        Alamofire.request(url).responseJSON { response in
            let json = response.result.value as! NSDictionary
            completionHandler(json)
        }
    }
    
}
    /***************************************************************/
    /***************************************************************/
