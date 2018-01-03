//
//  MainMapVC.swift
//  ATMFinder-GoogleMaps
//
//

import UIKit
import MapKit
import CoreLocation
import GoogleMaps
import GooglePlacePicker

struct AtmDetailsStruct {
    
    private(set) public var atmName : String = ""
    private(set) public var atmLocation : String = ""
    private(set) public var atmDistance : String = ""
    //
    
    init(atmName: String, atmLocation: String, atmDistance: String) {
        self.atmName = atmName
        self.atmLocation = atmLocation
        self.atmDistance = atmDistance
    }
}

struct AtmCoordinatesStruct {
    var atmLatitude : CLLocationDegrees
    var atmLongitude : CLLocationDegrees
    
    init(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        self.atmLatitude = latitude
        self.atmLongitude = longitude
    }
}

    /***************************************************************/

class MainMapVC: UIViewController, newLocationsDelegate {
    
    var currentLocation: CLLocation! // This is our current location
    var locationManager = CLLocationManager() // Manage our location
    
    var atmLocationCoordinates: [AtmCoordinatesStruct] = [AtmCoordinatesStruct]()
    var atmCoordinates2D = CLLocationCoordinate2D()
    
    // Store the location coordinates of the nearby locations
    var locationCoordinates = NSMutableArray()
    var atmDetailsArray: [AtmDetailsStruct] = [AtmDetailsStruct]()
    
    
    //Props
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var atmTableView: UITableView!
    @IBOutlet weak var locationLabel: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        atmTableView.delegate = self
        atmTableView.dataSource = self
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        mapView.delegate = self
        SearchNearbyManager.sharedInstance.delegate = self;
        // Only show the location label if we know our current location and address
        self.updateLocationLabel(text: "")
        self.atmDetailsArray.removeAll()
        print("**** ViewDidLoad ****")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.atmTableView.reloadData()
        print("**** ViewWillAppear ****")
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
            //print(locations.count)
            
            
            // for atmDetailsArray
            let atmName = dict["name"] as! String
            let atmAddress = dict["vicinity"] as! String
            
            // to compute distance from current location and atm coordinates
            
            let atmLocation = CLLocation(latitude: latitude, longitude: longitude)
            let userLocation = CLLocation(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
            let distanceMeters = userLocation.distance(from: atmLocation)
            let distanceKilometers = distanceMeters / 1000.00
            let atmCoordinatesDistance = String(Double(round(100 * distanceKilometers) / 100)) + " KM :  " + atmName
            
            
            let atmInfo = AtmDetailsStruct(atmName: atmName, atmLocation: atmAddress, atmDistance: atmCoordinatesDistance)
            let atmCoordinateInfo = AtmCoordinatesStruct(latitude: latitude, longitude: longitude)
            print(atmInfo) //*un/comment to/not test feed
            
            self.appendAtmCoordinatesArray(atmStruct: atmCoordinateInfo)
            self.appendAtmDetailsArray(atmStruct: atmInfo)
            locationCoordinates.addObjects(from: [itemLocation])
            let marker = GMSMarker(position: itemLocation)
            marker.title = dict["name"] as? String
            marker.icon = GMSMarker.markerImage(with: .orange)
            marker.map = mapView
        }
    }
    
    func updateNearbyLocations(currentLocation: CLLocation) {
        SearchNearbyManager.sharedInstance.getNearbyLocationsWithLocation(location: currentLocation)
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
   
    /***************************************************************/
    
//    func updateAtmDetailsArray(name: String, address: String, distance: String) {
//        self.atmDetailsArray.removeAll()
//        let atmInfo = AtmDetailsStruct(atmName: name, atmLocation: address, atmDistance: distance)
//        self.appendAtmDetailsArray(atmStruct: atmInfo)
//    }
    
    func appendAtmCoordinatesArray(atmStruct: AtmCoordinatesStruct) {
        let atmStructInfo = atmStruct
        self.atmLocationCoordinates.append(atmStructInfo)
        print(atmLocationCoordinates.count)
        self.atmTableView.reloadData()
    }
    
    func appendAtmDetailsArray(atmStruct: AtmDetailsStruct) {
        //self.atmDetailsArray.removeAll()
        let atmStructInfo = atmStruct
        self.atmDetailsArray.append(atmStructInfo)
        print(atmDetailsArray.count)
        self.atmTableView.reloadData()
        
        // TODO Remove this check
        if self.atmDetailsArray.count <= 20 {
            print("***************************** RECEIVED 1 API Locations for ATM Details Array **********************************")
        } else {
            print("***************************** RECEIVED >20 API Locations for ATM Details Array **********************************")
        }
    }
        
}


    /***************************************************************/

extension MainMapVC: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
            mapView.isMyLocationEnabled = false
            mapView.settings.myLocationButton = false
        }
        else {
            
            // This occurs if the user presses the button before our locations have been retreived
            let alert = UIAlertController(title: "Current Location Needed", message: "We need your current location to provide more accurate information and for you to get the most out of this app", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.first {
            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            mapView.animate(toLocation: location.coordinate)
            self.updateNearbyLocations(currentLocation: location)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let atmDetailsInfo = atmDetailsArray[indexPath.row]
        cell.textLabel?.text = atmDetailsInfo.atmName
        cell.detailTextLabel?.text = atmDetailsInfo.atmLocation
        cell.textLabel?.text = atmDetailsInfo.atmDistance
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let atmLocationDetails = atmLocationCoordinates[indexPath.row]
        let atmDetailsInfo = atmDetailsArray[indexPath.row]
        let atmMapLocation = CLLocationCoordinate2DMake(atmLocationDetails.atmLatitude, atmLocationDetails.atmLongitude)
        //let atmCurrentLocation = CLLocation(latitude: atmLocationDetails.atmLatitude, longitude: atmLocationDetails.atmLongitude)
        //self.updateNearbyLocations(currentLocation: atmCurrentLocation)
        mapView.camera = GMSCameraPosition(target: atmMapLocation, zoom: 15, bearing: 0, viewingAngle: 0)
        //self.currentLocation = atmCurrentLocation
        let marker = GMSMarker(position: atmMapLocation)
        marker.icon = GMSMarker.markerImage(with: .green)
        marker.map = mapView
        marker.title = atmDetailsInfo.atmName
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return atmDetailsArray.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
}

    /**************************EXPERIMENTAL AUTOCOMPLETE SEARCH*************************************/

extension MainMapVC: GMSAutocompleteViewControllerDelegate {
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        let newCurrentLocation = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        self.updateNearbyLocations(currentLocation: newCurrentLocation)
                mapView.camera = GMSCameraPosition(target: newCurrentLocation.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
        self.currentLocation = CLLocation(latitude: newCurrentLocation.coordinate.latitude, longitude: newCurrentLocation.coordinate.longitude)
        self.atmDetailsArray.removeAll()
        self.atmLocationCoordinates.removeAll()
        dismiss(animated: true, completion: nil)
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        //UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        //UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}

    /***************************************************************/
    /*******************CODE ENDS HERE **********************/

