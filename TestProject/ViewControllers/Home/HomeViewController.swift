//
//  HomeViewController.swift
//  TestProject
//
//  Created by apple on 12/31/20.
//

import UIKit
import GooglePlaces
import GoogleMapsBase
import MapKit
import GoogleMaps

struct Global {
    static let API_KEY = "AIzaSyAHzgaXbTenGQj6O39F9lNAomqjiuF9yN8"
}

class HomeViewController: BaseViewController {
    
    private let searchResultCell = "searchResultCell"
    private let marker = GMSMarker()
    private let locationManager = CLLocationManager()
    
    private var selectedLocLatitude = 0.0
    private var selectedLocLongitude = 0.0
    private var selectedPlaceId = ""
    private var selectedPlace = ""
    
    private var selectedLocation = SelectedLocation()
    private var locationsToBeSaved = [GApiResponse.NearBy]()
    
    var autocompleteResults :[GApiResponse.Autocomplete] = []
    
    
    //MARK: Outlets
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var findButtonView: UIView! {
        didSet {
            findButtonView.layer.cornerRadius = 20
        }
    }
    
    @IBOutlet weak var selectedLocationTextField: UITextField! {
        didSet {
            selectedLocationTextField.attributedPlaceholder = NSAttributedString(string: "Select location..",
                                                                                 attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightText])
        }
    }
    
    
    @IBOutlet weak var searchBarView: UIView! {
        didSet {
            searchBarView.layer.cornerRadius = 26
        }
    }
    
    
    //MARK: Override Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let tabBar = self.tabBarController?.tabBar {
            tabBar.items?.first?.title = "Home"
            tabBar.items?.last?.title = "Saved"
            tabBar.tintColor = .white
            tabBar.backgroundColor = .black
            tabBar.items?.first?.image = UIImage(named: "home")
            tabBar.items?.last?.image = UIImage(named: "pin")
        }
        
        mapView.mapType = .terrain
        mapView.isMyLocationEnabled = true
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 204/255, green: 33/255, blue: 49/255, alpha: 1)
        self.navigationController?.navigationBar.tintColor = .white
        
        locationManager.requestAlwaysAuthorization()
       
        let savedLoc = UserDefaultsManager.shared.readUser()
        if let long = savedLoc.long, let lat = savedLoc.lat {
            let camera = GMSCameraPosition.camera(withLatitude: lat,
                                                  longitude: long,
                                                  zoom: 15.0)
            
            self.mapView.camera = camera
            marker.position = CLLocationCoordinate2DMake(lat , long)
            marker.title = savedLoc.name
            marker.map = self.mapView
            marker.icon = GMSMarker.markerImage(with: UIColor.blue)
            marker.tracksViewChanges = true
            self.selectedLocationTextField.text = savedLoc.name
            self.selectedLocation = savedLoc
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        self.navigationController?.navigationBar.topItem?.title = "Home"
    }
    
    //MARK: Actions
    @IBAction
    func selectLocationButton(_ sender: UIButton) {
        openSelectLocationViewController()
    }
    
    @IBAction
    func findLocationButton(_ sender: UIButton) {
        let isSelectedLocationEmpty = self.selectedLocationTextField.text?.isEmpty ?? true
        if !isSelectedLocationEmpty {
            openFindLocationListingVC()
        } else {
            Utils.showAlert(title: "", message: "Please select any location", viewController: self)
        }
    }
    
    //MARK: Helper Methods
    private func openSelectLocationViewController() {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        if #available(iOS 13.0, *) {
            if UIScreen.main.traitCollection.userInterfaceStyle == .dark  {
                autocompleteController.primaryTextColor = UIColor.white
                autocompleteController.secondaryTextColor = UIColor.lightGray
                autocompleteController.tableCellSeparatorColor = UIColor.lightGray
                autocompleteController.tableCellBackgroundColor = UIColor.darkGray
            } else {
                autocompleteController.primaryTextColor = UIColor.black
                autocompleteController.secondaryTextColor = UIColor.lightGray
                autocompleteController.tableCellSeparatorColor = UIColor.lightGray
                autocompleteController.tableCellBackgroundColor = UIColor.white
            }
        }
        
        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
                                                    UInt(GMSPlaceField.coordinate.rawValue) |
                                                    UInt(GMSPlaceField.addressComponents.rawValue) |
                                                    UInt(GMSPlaceField.formattedAddress.rawValue) |
                                                    UInt(GMSPlaceField.placeID.rawValue))!
        autocompleteController.placeFields = fields
        
        
        let filter = GMSAutocompleteFilter()
        filter.type = .address
        
        autocompleteController.autocompleteFilter = filter
        present(autocompleteController, animated: true, completion: nil)
        
    }
    
    private func openFindLocationListingVC() {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard?.instantiateViewController(withIdentifier: "locationListingViewController") as? LocationListingViewController {
            vc.selectedLocation = self.selectedLocation
            vc.showLocally = false
            vc.delegate = self
            UserDefaultsManager.shared.saveLocation(selectedLocation)
            CoreDataManager.shared.saveSearchedPlace(searchedPlace: self.selectedLocation) { _ in
                
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        }
    }
    
    private func savetoDatabase(location: GApiResponse.NearBy) {
        CoreDataManager.shared.saveSearchedLocation(searchedLocation: location) { _ in }
    }
}


//MARK: GMSAutocompleteViewControllerDelegate
extension HomeViewController: GMSAutocompleteViewControllerDelegate {
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        selectedLocationTextField.text = place.name
        
        selectedLocation.name = place.name
        selectedLocation.long = place.coordinate.longitude
        selectedLocation.lat = place.coordinate.latitude
        selectedLocation.placeId = place.placeID ?? ""
        
        let camera = GMSCameraPosition.camera(withLatitude: place.coordinate.latitude,
                                              longitude: place.coordinate.longitude, zoom: 15.0)
        
        self.mapView.camera = camera
        marker.position = CLLocationCoordinate2DMake(place.coordinate.latitude, place.coordinate.longitude)
        marker.title = place.name
        marker.snippet = place.formattedAddress
        marker.map = self.mapView
        marker.icon = GMSMarker.markerImage(with: UIColor.blue)
        marker.tracksViewChanges = true
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}

extension HomeViewController: LocationListingDelegate {
    
    func saveLocations(_ locations: [GApiResponse.NearBy]) {
        self.locationsToBeSaved.append(contentsOf: locations)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            for location in self.locationsToBeSaved {
                
                let alreadySavedPlace = UserDefaultsManager.shared.readUser()
                if let placeId = alreadySavedPlace.placeId {
                    
                    let isAlreadySearchedPlace = CoreDataManager.shared.isAlreadyPlacedSearched(placeId: placeId)
                    if !isAlreadySearchedPlace {
                        
                        self.savetoDatabase(location: location)
                        
                    } else {
                        
                        let isAlreadySearchedLocation = CoreDataManager.shared.isAlreadyExists(placeId: location.placeId)
                        if !isAlreadySearchedLocation {
                            self.savetoDatabase(location: location)
                        }
                        
                        
                    }
                }
            }
            
            self.locationsToBeSaved.removeAll()
        }
        
    }
    
}
