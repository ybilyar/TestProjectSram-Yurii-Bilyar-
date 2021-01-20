//
//  LocationDetailViewController.swift
//  TestProject
//
//  Created by apple on 1/1/21.
//

import UIKit
import MessageUI

class LocationDetailViewController: BaseViewController, MFMailComposeViewControllerDelegate {

    
    var locationDetail = GApiResponse.NearBy()
    
    //MARK: Outlets
    @IBOutlet weak var locationImageOuterView: UIView! {
        didSet {
            locationImageOuterView.backgroundColor = .clear
            locationImageOuterView.layer.cornerRadius = 75
        }
    }
    
    @IBOutlet weak var locationImage: UIImageView!
    @IBOutlet weak var locationTitleLabel: UILabel!
    @IBOutlet weak var locationDescriptionLabel: UILabel!
    @IBOutlet weak var emailLocationOuterView: UIView! {
        didSet {
            emailLocationOuterView.layer.cornerRadius = 30
        }
    }
    //locationDetailViewController
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Detail"
        initializeData()
    }
    

    @IBAction
    func emailLocationAddress(_ sender: UIButton) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setSubject("Location Address")
            mail.setMessageBody("<p>The shop name is \(locationDetail.formattedAddress), and the address is \(locationDetail.description ?? "")</p>",
                                isHTML: true)
            
            present(mail, animated: true)
        } else {
            // show failure alert
        }
    }
    
    private func initializeData() {
        locationTitleLabel.text = self.locationDetail.formattedAddress
        locationDescriptionLabel.text = self.locationDetail.description
        if let imageCount = self.locationDetail.image.pngData()?.count {
            locationImage.image = self.locationDetail.image
        } else {
            locationImage.image = UIImage(named: "placeholder")!
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
}
