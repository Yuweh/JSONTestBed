//
//  TableViewController3.swift
//  ATMfinderV3
//
//  Created by Francis Jemuel Bergonia on 27/12/2017.
//  Copyright © 2017 Francis Jemuel Bergonia. All rights reserved.
//

import UIKit
import GoogleMaps

class TableViewController3: UITableViewController, newLocationsDelegate {
    
    func returnNewLocations(locations: NSArray) {
        // We loop through the results in our array then plot each one on the map
        for i in 0 ... locations.count - 1 {
            
            let dict = locations[i] as! NSDictionary;
            
            let geometry = dict["geometry"] as! NSDictionary
            let coordinates = geometry["location"] as! NSDictionary
            
            let longitude = coordinates["lng"] as! CLLocationDegrees
            let latitude = coordinates["lat"] as! CLLocationDegrees
            
            let itemLocation = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            
            locationCoordinates.addObjects(from: [itemLocation])
            print(dict)
            print(itemLocation)
            print(locations)
            
        }
    }
    

    // Store the location info of the nearby locations
    var atmCoordinates = NSMutableDictionary()
    var locationCoordinates = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SearchNearbyManager.sharedInstance.delegate = self;
    }
    
    func returnNewLocationInfo(atmInfo: NSDictionary) {
        for i in 0 ... atmInfo.count - 1 {
            
            let dict = atmInfo[i] as! NSDictionary;
            
            let name = dict["name"] as! NSDictionary
            let vicinity = dict["name"] as! NSDictionary
            
    }
        
    
    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

/*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        let atmResults = atmCoordinates[indexPath.row]
        cell.textLabel?.text = atmResul
        return cell
    }
*/
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
}
