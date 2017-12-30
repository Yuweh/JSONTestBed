//
//  MainMapVC.swift
//  ATMFinder-GoogleMaps
//

import UIKit
import MapKit
import CoreLocation
import GoogleMaps
import GooglePlacePicker

struct AtmDetailsStruct {
    
    private(set) public var atmName : String
    private(set) public var atmLocation : String
    private(set) public var atmDistance : String
    //
    
    init(atmName: String, atmLocation: String, atmDistance: String) {
        self.atmName = atmName
        self.atmLocation = atmLocation
        self.atmDistance = atmDistance
    }
}

    /***************************************************************/

class MainMapVC: UIViewController, newLocationsDelegate {
    
    var currentLocation: CLLocation! // This is our current location
    let locationManager = CLLocationManager() // Manage our location
    
    // Store the location coordinates of the nearby locations
    var locationCoordinates = NSMutableArray()
    var atmDetailsArray: [AtmDetailsStruct] = [AtmDetailsStruct]()
    
    //Props
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var atmTableView: UITableView!
    @IBOutlet weak var locationLabel: UILabel!
 

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        mapView.delegate = self
        SearchNearbyManager.sharedInstance.delegate = self;
        atmTableView.delegate = self as! UITableViewDelegate
        atmTableView.dataSource = self as! UITableViewDataSource
        // Only show the location label if we know our current location and address
        self.updateLocationLabel(text: "")
    }
        /***************************************************************/
    
    //AutocompletePicker methods
    
    @IBAction func getAutoCompletePicker(_ sender: UIBarButtonItem) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
        print("phase 2 - get AutoComplete")
    }
    
    @IBAction func refresh(sender: UIButton)
    {
        //self.getAutocompletePicker()
        print("phase 3 - refresh")
    }
    
    
        /***************************************************************/
    
    // This is a delegate method for returning new locations from the NearbyMapsManager
    func returnNewLocations(locations: NSArray) {
        
        // Clear our arrays and reset the map
        locationCoordinates.removeAllObjects()
        mapView.clear()
        
        // We loop through the results in our array then plot each one on the map
        for i in 0 ... locations.count - 1 {
            
            let dict = locations[i] as! NSDictionary;
            
            // for locationCoordinate NSArray
            let geometry = dict["geometry"] as! NSDictionary
            let coordinates = geometry["location"] as! NSDictionary
            
            let longitude = coordinates["lng"] as! CLLocationDegrees
            let latitude = coordinates["lat"] as! CLLocationDegrees
            
            let itemLocation = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            
            // to compute distance from current location and atm coordinates
            
            let atmLocation = CLLocation(latitude: latitude, longitude: longitude)
            let userLocation = CLLocation(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
            
            
            let distanceMeters = userLocation.distance(from: atmLocation)
            let distanceKilometers = distanceMeters / 1000.00
            let atmCoordinatesDistance = String(Double(round(100 * distanceKilometers) / 100)) + " KM"
            
            // for atmDetailsArray
            
            let atmName = dict["name"] as! String
            let atmAddress = dict["vicinity"] as! String
            //let atmDistance = atmCoordinatesDistance
            
            let atmInfo = AtmDetailsStruct(atmName: atmName, atmLocation: atmAddress, atmDistance: atmCoordinatesDistance)
            //print(atmInfo) //*un/comment to/not test feed
            
    
            // to populate variables above
            
            atmDetailsArray.append(atmInfo)
            locationCoordinates.addObjects(from: [itemLocation])
            
            let marker = GMSMarker(position: itemLocation)
            marker.title = dict["name"] as? String
            marker.map = mapView
        }
    }
    
    func updateNearbyLocations(currentLocation: CLLocation) {
        SearchNearbyManager.sharedInstance.getNearbyLocationsWithLocation(location: currentLocation)
        print("***************************** updateNearbyLocations from MainMapVC triggerred **********************************")
    }
    
    func updateLocationLabel(text: String) {
        
        self.locationLabel.text = text
        
        UIView.animate(withDuration: 0.2, animations: {
            //self.locationLabel.alpha = self.locationLabel.text?.count = 0 ? 0.0 : 0.7
        })
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


    /***************************************************************/


extension MainMapVC: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedWhenInUse {
            
            locationManager.startUpdatingLocation()
            mapView.isMyLocationEnabled = true
            mapView.settings.myLocationButton = true
        }
        else {
            
            // This occurs if the user presses the button before our locations have been retreived
            let alert = UIAlertController(title: "Current Location Needed", message: "We need your current location to provide more accurate information and for you to get the most out of this app", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.last {
            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            mapView.animate(toLocation: location.coordinate)
            self.updateNearbyLocations(currentLocation: location)
            print("***************************** updateNearbyLocations from locationManager did updateLocations trigerred **********************************")
            currentLocation = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
        }
    }
}

    /***************************************************************/

extension MainMapVC: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        
        reverseGeocodeCoordinate(coordinate: position.target)
    }
}

    /***************************************************************/

extension MainMapVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ATMCustomCell = tableView.dequeueReusableCell(withIdentifier: "ATMcell", for: indexPath) as! ATMCustomCell
        let atmDetailsInfo = atmDetailsArray[indexPath.row]
        cell.textLabel?.text = atmDetailsInfo.atmName
        cell.textLabel?.text = atmDetailsInfo.atmLocation
        cell.textLabel?.text = atmDetailsInfo.atmDistance
        print(atmDetailsInfo) //*un/comment to/not test feed
        
//        cell.textLabel?.text = atmDetailsInfo.atmName
//        cell.detailTextLabel?.text = atmDetailsInfo.atmLocation
        return cell
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return atmDetailsArray.count
    }
    
}

    /**************************EXPERIMENTAL AUTOCOMPLETE SEARCH*************************************/

extension MainMapVC: GMSAutocompleteViewControllerDelegate {
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        let newCurrentLocation = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        self.updateNearbyLocations(currentLocation: newCurrentLocation)
                mapView.camera = GMSCameraPosition(target: newCurrentLocation.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
        dismiss(animated: true, completion: nil)
        print("EXPERIMENTAL AUTOCOMPLETE  - didAutocompleteWith")
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("EXPERIMENTAL AUTOCOMPLETE - Error")
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
        print("EXPERIMENTAL AUTOCOMPLETE - wasCancelled")
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        //UIApplication.shared.isNetworkActivityIndicatorVisible = true
        print("phase 5.1 - didRequestAutocompletePredictions")
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        //UIApplication.shared.isNetworkActivityIndicatorVisible = false
        print("phase 5.2 - didUpdateAutocompletePredictions")
    }
    
}

    /***************************************************************/
    /***************************************************************/
    /***************************************************************/
