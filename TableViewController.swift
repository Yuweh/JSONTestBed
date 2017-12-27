//
//  TableViewController.swift
//  ATMfinderV3
//
//  Created by Francis Jemuel Bergonia on 27/12/2017.
//  Copyright © 2017 Francis Jemuel Bergonia. All rights reserved.
//

import UIKit
import Alamofire

class TableViewController: UITableViewController {

    var listData = [[String: Any]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        let url = URL(string: "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=14.5838,121.0597&radius=5000&keyword=atm&key=AIzaSyAqVn11MrD5nHQ4YPZEC_jmPOujbRng23Y")!
        
        Alamofire.request(url).responseJSON { response in
            switch response.result {
            case .success(let value):
                guard let json = value as? [String: Any], let listData = json["results"] as? [[String: Any]] else {
                    print("Response does not contain results")
                    return
                }
                
                self.listData = listData
                
                print(listData)
                
                self.tableView.reloadData()
                
            case .failure(let error):
                print(error)
            }
        }
    }
        
    }


    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }
/*
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        let result = listData[indexPath.row]
        
        // Configure the cell...

        return cell
    }
*/

