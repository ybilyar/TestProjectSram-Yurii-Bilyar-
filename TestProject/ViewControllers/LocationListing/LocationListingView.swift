//
//  LocationListingView.swift
//  TestProject
//
//  Created by apple on 12/30/20.
//

import UIKit

class LocationListingView: UIView {

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.tableFooterView = UIView()
            tableView.separatorStyle = .none
            tableView.separatorColor = .clear
        }
    }
    
    @IBOutlet weak var selectedLocationName: UILabel!
}
