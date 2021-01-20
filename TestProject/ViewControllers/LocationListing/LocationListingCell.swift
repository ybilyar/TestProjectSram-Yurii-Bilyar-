//
//  LocationListingCell.swift
//  TestProject
//
//  Created by apple on 12/30/20.
//

import UIKit
import SDWebImage

class LocationListingCell: UITableViewCell {

    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var imageOuterView: UIView!
    @IBOutlet weak var locationTitle: UILabel!
    @IBOutlet weak var locationDistance: UILabel!
    @IBOutlet weak var locationImage: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageOuterView.clipsToBounds = true
        imageOuterView.layer.cornerRadius = 30
        outerView.dropShadow(color: UIColor(red: 191/255, green: 191/255, blue: 191/255, alpha: 1),
                             opacity: 0.08,
                             offSet: CGSize(width: -1, height: 0.5),
                             radius: 20,
                             scale: true)

    }
    
    func setData(_ location: GApiResponse.NearBy) {
        locationTitle.text = location.formattedAddress
    }
    
}
