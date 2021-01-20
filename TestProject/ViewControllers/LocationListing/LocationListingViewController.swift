//
//  LocationListingViewController.swift
//  TestProject
//
//  Created by apple on 12/30/20.
//

import UIKit
import CoreData
import ObjectMapper
import SDWebImage

protocol LocationListingDelegate: class {
    func saveLocations(_ locations: [GApiResponse.NearBy])
}

class LocationListingViewController: BaseViewController {
    
    private let locationListingNibName = "LocationListingCell"
    private let locationListingCellIdentifier = "locationListingCellIdentifier"
    
    private var realFetchedArray = [GApiResponse.NearBy]()
    private var nextPageToken = ""
    private var searchedLocations = [GApiResponse.NearBy]()
    
    private var nextPageRequested = false
    private var lazyLoadingFooterView: UIView!
    private var indicator: UIActivityIndicatorView!
    
    private var shouldSave = true
    
    weak var delegate: LocationListingDelegate?
    
    var showLocally = true
    var selectedLocation: SelectedLocation?
    
    
    //MARK: Outlets
    @IBOutlet var locationListingView: LocationListingView!
    
    
    //MARK: Override Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerNib()
        self.locationListingView.selectedLocationName.text = selectedLocation?.name
        setupLazyLoading()
        if !self.showLocally {
            self.getNearByLocations(token: nil)
        }
        
        
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        self.navigationController?.navigationBar.topItem?.title = "Locations"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        if self.showLocally {
            self.searchedLocations.removeAll()
            self.fetchAllLocations()
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if shouldSave && !showLocally {
            delegate?.saveLocations(self.searchedLocations)
        } else {
            shouldSave = true
        }
    }
    
    //MARK: Private Methods
    private func setupLazyLoading(){
        if #available(iOS 13.0, *) {
            indicator = UIActivityIndicatorView(style: .medium)
        } else {
            
            indicator = UIActivityIndicatorView()
        }
        indicator.hidesWhenStopped = true
        indicator.startAnimating()
        indicator.color = .white
        indicator.frame = CGRect(x: UIScreen.main.bounds.width/2, y: 15, width: 20, height: 20)
        
        lazyLoadingFooterView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        lazyLoadingFooterView.addSubview(indicator)
    }
    
    private func registerNib() {
        let nib = UINib(nibName: locationListingNibName, bundle: nil)
        locationListingView.tableView.register(nib, forCellReuseIdentifier: locationListingCellIdentifier)
    }
    
    private func getNearByLocations(token: String?) {
        var location = GLocation()
        location.latitude = self.selectedLocation?.lat
        location.longitude = self.selectedLocation?.long
        
        var input = GInput()
        input.keyword = "Bikes Shops"
        input.radius = 160934
        input.destinationCoordinate = location
        input.nextPageToken = token
        
        if !self.nextPageRequested {
            LoaderManager.show(self.view)
        }
        
        let shouldFetchedAll = self.nextPageRequested && self.nextPageToken.isEmpty
        if !shouldFetchedAll {
            GoogleApi.shared.callApi(.nearBy, input: input) { (response) in
                
                self.nextPageToken = response.nextPageToken ?? ""
                
                if let data = response.data as? [GApiResponse.NearBy], response.isValidFor(.nearBy){
                    
                    self.realFetchedArray.append(contentsOf: data)
                    DispatchQueue.main.async {
                        LoaderManager.hide(self.view)
                        
                        if self.nextPageRequested {
                            self.nextPageRequested = false
                            self.locationListingView.tableView.tableFooterView = UIView()
                        }
                        
                        self.copyElementsForLazyLoading()
                        self.locationListingView.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    private func copyElementsForLazyLoading() {
        if realFetchedArray.count > 10 {
            for index in 0..<10 {
                self.searchedLocations.append(realFetchedArray[index])
            }
            
            let removedArray = self.realFetchedArray.dropFirst(10)
            self.realFetchedArray.removeAll()
            self.realFetchedArray.append(contentsOf: removedArray)
            
        } else {
            
            for index in 0..<realFetchedArray.count {
                self.searchedLocations.append(realFetchedArray[index])
            }
            self.realFetchedArray.removeAll()
        }
        
        let sortedArray = self.searchedLocations.sorted { (obj1, obj2) -> Bool in
            return obj1.distance < obj2.distance
        }
        self.searchedLocations.removeAll()
        self.searchedLocations.append(contentsOf: sortedArray)
        DispatchQueue.main.async {
            self.locationListingView.tableView.reloadData()
        }
    }
    
    private func fetchAllLocations() {
        let alreadySaveLoc = UserDefaultsManager.shared.readUser()
        self.locationListingView.selectedLocationName.text = alreadySaveLoc.name
        let savedLocations = CoreDataManager.shared.fetchAllStudents()
        var count = 0
        for location in savedLocations {
            
            count = count + 1
            let nearBy = GApiResponse.NearBy.init()
            nearBy.formattedAddress = location.name ?? ""
            nearBy.description = location.address
            nearBy.location = GLocation(latitude: location.latitude, longitude: location.longitude)
            nearBy.placeId = location.placeId ?? ""
            nearBy.image = location.image as? UIImage ?? UIImage(named: "placeholder")!
            
            let currentObjectLoc = CLLocation(latitude: location.latitude, longitude: location.longitude)
            let lat = alreadySaveLoc.lat ?? 0.0
            let long = alreadySaveLoc.long ?? 0.0
            let selectedLoc = CLLocation(latitude: lat, longitude: long)
            
            let distance = currentObjectLoc.distance(from: selectedLoc) / 1000
            nearBy.distance = CGFloat(distance)
            
            self.searchedLocations.append(nearBy)
            
            if count == savedLocations.count {
                let sortedArray = self.searchedLocations.sorted { (obj1, obj2) -> Bool in
                    return obj1.distance < obj2.distance
                }
                self.searchedLocations.removeAll()
                self.searchedLocations.append(contentsOf: sortedArray)
                DispatchQueue.main.async {
                    self.locationListingView.tableView.reloadData()
                }
            }
            
            DispatchQueue.main.async {
                self.locationListingView.tableView.reloadData()
            }
        }
        
    }
    
    private func openLocationDetailViewController(location: GApiResponse.NearBy) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyBoard.instantiateViewController(withIdentifier: "locationDetailViewController") as? LocationDetailViewController {
            vc.locationDetail = location
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    
}


//MARK: UITableView Delegate
extension LocationListingViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        shouldSave = false
        openLocationDetailViewController(location: self.searchedLocations[indexPath.row])
    }
    
}


//MARK: UITableView DataSource
extension LocationListingViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchedLocations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: locationListingCellIdentifier, for: indexPath) as! LocationListingCell
        let location = self.searchedLocations[indexPath.row]
        cell.setData(location)
        cell.locationDistance.text = String(format: "%.3f km", Double(location.distance))
        
        
        if let photoRef = location.photoReference {
            let urlString = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=\(photoRef)&key=\(Global.API_KEY)"
            if let url = URL(string: urlString) {
                cell.activityIndicator.startAnimating()
                cell.locationImage.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder")!, options: SDWebImageOptions.highPriority) { (image, _, _ , _) in
                    cell.activityIndicator.stopAnimating()
                    cell.activityIndicator.isHidden = true
                    self.searchedLocations[indexPath.row].image = image ?? UIImage(named: "placeholder")!
                }
            } else {
                self.searchedLocations[indexPath.row].image = UIImage(named: "placeholder")!
                cell.locationImage.image = UIImage(named: "placeholder")!
            }
        } else {
            cell.activityIndicator.isHidden = true
            if !self.showLocally {
                cell.locationImage.image = UIImage(named: "placeholder")!
                self.searchedLocations[indexPath.row].image = UIImage(named: "placeholder")!
            } else {
                if let imageCount = location.image.pngData()?.count {
                    cell.locationImage.image = location.image
                } else {
                    cell.locationImage.image = UIImage(named: "placeholder")!
                }
            }
            
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 130
    }
    
}

//MARK: - Infinite Scrolling
extension LocationListingViewController {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let actualPosition = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height - scrollView.frame.size.height
        if contentHeight > 0 && contentHeight - actualPosition <= 10 {
            
            if !self.showLocally {
                self.nextPageRequested = true
                if self.realFetchedArray.count == 0 {
                    self.getNearByLocations(token: self.nextPageToken)
                    
                    if !self.nextPageToken.isEmpty {
                        self.locationListingView.tableView.tableFooterView = lazyLoadingFooterView
                    }
                    
                    
                } else {
                    
                    self.copyElementsForLazyLoading()
                }
            }
        }
    }
}

struct Utils {
    static func showAlert(title: String, message: String, viewController: UIViewController, handler: ((UIAlertAction) -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: handler)//localizedString: ok
        alertController.addAction(okAction)
        viewController.present(alertController, animated: true, completion: nil)
    }
}
