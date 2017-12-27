//
//  ViewController.swift
//  ATMfinderV3
//
//  Created by Francis Jemuel Bergonia on 24/12/2017.
//  Copyright © 2017 Francis Jemuel Bergonia. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import GooglePlacePicker
import CoreLocation
import MapKit

class MapViewController: UIViewController, newLocationsDelegate {

    var currentLocation: CLLocation!
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var locationLabel: UILabel!
    
    
    var locationManager = CLLocationManager()
    
    // Store the location coordinates of the nearby locations
    var locationCoordinates = NSMutableArray()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.title = "ATM Finder"
        self.tabBarItem.image = UIImage(named: "icn_30_map.png")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        mapView.delegate = self as? GMSMapViewDelegate;
        
        //self.mapView.isMyLocationEnabled = true

        //showMarker(position: (locationManager.location?.coordinate)!)
        self.updateLocationLabel(text: "")
        
        //mapView.delegate = self as? GMSMapViewDelegate
        // 1.
        SearchNearbyManager.sharedInstance.delegate = self as newLocationsDelegate
    
    }
    
    // This is a delegate method for returning new locations from the NearbyMapsManager
    func returnNewLocations(locations: NSArray) {
        
        // Clear our arrays and reset the map
        locationCoordinates.removeAllObjects()
        mapView.clear()
        
        // We loop through the results in our array then plot each one on the map
        for i in 0 ... locations.count - 1 {
            
            let dict = locations[i] as! NSDictionary;
            
            let geometry = dict["geometry"] as! NSDictionary
            let coordinates = geometry["location"] as! NSDictionary
            
            let longitude = coordinates["lng"] as! CLLocationDegrees
            let latitude = coordinates["lat"] as! CLLocationDegrees
            
            let itemLocation = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            locationCoordinates.addObjects(from: [itemLocation])
            
            let marker = GMSMarker(position: itemLocation)
            marker.title = dict["name"] as? String
            marker.map = mapView
        }
    }
    
    // 2.
    func updateNearbyLocations(currentLocation: CLLocation) {
    SearchNearbyManager.sharedInstance.getNearbyLocationsWithLocation(location: currentLocation)
    }
    
    
//    func initializeTheLocationManager() {
//        locationManager.delegate = self
//        locationManager.requestWhenInUseAuthorization()
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        locationManager.startUpdatingLocation()
//    }
    
    func updateLocationLabel(text: String) {
        
        self.locationLabel.text = text
        
        UIView.animate(withDuration: 0.2, animations: {
            self.locationLabel.alpha = self.locationLabel.text?.count == 0 ? 0.0 : 0.7
        })
    }
    
    //Show a Marker on the map
//    func showMarker(position: CLLocationCoordinate2D){
//        let marker = GMSMarker()
//        marker.position = position
//        marker.title = "You are here"
//        marker.snippet = " "
//        marker.map = mapView
//    }
    
    
    @IBAction func pickPlace(_ sender: UIBarButtonItem) {
        let config = GMSPlacePickerConfig(viewport: nil)
        let placePicker = GMSPlacePickerViewController(config: config)
        placePicker.delegate = self
        present(placePicker, animated: true, completion: nil)
    }

}

extension MapViewController: GMSPlacePickerViewControllerDelegate
{
    // GMSPlacePickerViewControllerDelegate and implement this code.
    func placePicker(_ viewController: GMSPlacePickerViewController, didPick place: GMSPlace) {
        mapView.isHidden = false
        
    }
    
    func placePickerDidCancel(_ viewController: GMSPlacePickerViewController) {
        
        viewController.dismiss(animated: true, completion: nil)
        
        mapView.isHidden = true
    }
    
    // Use this to set the address at the bottom of the screen
    func reverseGeocodeCoordinate(coordinate: CLLocationCoordinate2D) {
        
        let geocoder = GMSGeocoder()
        
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            
            if let address = response?.firstResult() {
                
                var addressString = String()
                
                // Concatinate the lines of the address into a single string
                for String in address.lines! {
                    addressString = addressString + " " + String
                }
                
                self.updateLocationLabel(text: addressString)
            }
        }
    }
    
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedWhenInUse {
            
            locationManager.startUpdatingLocation()
            
            mapView.isMyLocationEnabled = true
            mapView.settings.myLocationButton = true
        }
        else {
            
            // This occurs if the user presses the button before our locations have been retreived
            let alert = UIAlertController(title: "Oh no", message: "We can't show you nearby locations if we don't know where you are! Go into settings to change your location services to get the most out of this app", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.first {
            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            mapView.animate(toLocation: location.coordinate)
            self.updateNearbyLocations(currentLocation: location)
            }
        }
}

extension MapViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        
        reverseGeocodeCoordinate(coordinate: position.target)
    }
}


