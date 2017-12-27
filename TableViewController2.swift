//
//  TableViewController2.swift
//  ATMfinderV3
//
//  Created by Francis Jemuel Bergonia on 27/12/2017.
//  Copyright © 2017 Francis Jemuel Bergonia. All rights reserved.
//

import UIKit


struct ATMData {
    let locationName : String
    let vicinity : String
}

class TableViewController2: UITableViewController {

    var atmResults = [ATMData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    func callGoogleAPINearbySearch() {
        
        let url = URL(string: "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=14.5838,121.0597&radius=5000&keyword=atm&key=AIzaSyAqVn11MrD5nHQ4YPZEC_jmPOujbRng23Y")
        
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil {
                print(error!)
            } else {
                do {
                    if let dictionary = try JSONSerialization.jsonObject(with: data!) as? [String: Any],
                        let array = dictionary["results"] as? [[String: Any]] {
                        for object in array {
                            if let locationName = object["name"] as? [String: String],
                                let locationAddress = object["vicinity"] as? [String: Any] {
                                let locationName = locationName["name"] ?? ""
                                let vicinity = locationAddress["vicinity"] as? String ?? ""
                                let atmResult = ATMData(locationName: locationName, vicinity: vicinity)
                                self.atmResults.append(atmResult)
                                print(atmResult)
                            }
                            
                        }
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                } catch {
                    print(error)
                }
            }
        }
        task.resume()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3 //atmResults.count
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

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
