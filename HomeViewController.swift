//
//  HomeViewController.swift
//  iChota
//
//  Created by Lalit on 26/08/20.
//  Copyright © 2020 AppDeft. All rights reserved.
//

import UIKit
import CarbonKit
import GooglePlaces
import BonsaiController
import CoreLocation
import ViewAnimator
import SDWebImage
import IQKeyboardManagerSwift
protocol HideShowUpperView {
    func hide()
    func show()
}

var hideShowUpperView:HideShowUpperView?
class CategoryCell: UICollectionViewCell {
    
    @IBOutlet weak var imgRow: UIImageView!
    @IBOutlet weak var lblCatName: UILabel!
    
}

class HomeViewController: UIViewController {
    
    @IBOutlet weak var imgSearch: UIImageView!
    @IBOutlet weak var topView: NSLayoutConstraint!
    @IBOutlet weak var heightView: NSLayoutConstraint!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var btnLocation: UIButton!
    @IBOutlet weak var insideView: UIView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var imgLocationDownArrow: UIImageView!
    
    @IBOutlet weak var lblLocation: UILabel!
    private var lastContentOffset: CGFloat = 0
    private let animations = [AnimationType.from(direction: .bottom, offset: 300)]
    var jsonResponse:[CategoriesData]?
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchCategories()
        hideShowUpperView = self
        self.designUI()

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }

    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnLocationClicked(_ sender: Any) {

        goToPlace()
    }
    
    func goToPlace() {
        self.txtSearch.resignFirstResponder()
        let acController = GMSAutocompleteViewController()
        acController.delegate = self
        present(acController, animated: true, completion: nil)
    }
    
    
    
    
    //MARK:- Loaction Label Click
    
    @objc
    func tapFunction(sender:UITapGestureRecognizer) {
       goToPlace()
    }
    
}


//MARK:- HELPER FUNCTIONS
extension HomeViewController {
    func designUI() {
//        self.setupCarbonTabSwipe()
        self.txtSearch.delegate = self
//        txtSearch.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        
    }
}

//MARK:- CUSTOM SWIPE BAR
extension HomeViewController {
    
    func generateImage(for view: UIView) -> UIImage? {
        defer {
            UIGraphicsEndImageContext()
        }
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, UIScreen.main.scale)
        if let context = UIGraphicsGetCurrentContext() {
            view.layer.render(in: context)
            return UIGraphicsGetImageFromCurrentImageContext()
        }
        return nil
    }
    
    var iconWithTextImage: UIImage {
        let button = UIButton()
        let icon = UIImage(named: "ic_shopping")
        button.setImage(icon, for: .normal)
        button.setTitle("Sales", for: .normal)
        button.setTitleColor(UIColor.blue, for: .normal)
        button.titleLabel?.font = UIFont.init(name: "SFProDisplay-Semibold", size: 20.0) ?? UIFont.systemFont(ofSize: 20)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 10)
        button.imageEdgeInsets = UIEdgeInsets(top: 2, left: 80, bottom: 2, right: 16)
        button.sizeToFit()
        return generateImage(for: button) ?? UIImage()
    }
    
    
}

//MARK:- CARBON KIT DELEGATE
//extension HomeViewController: CarbonTabSwipeNavigationDelegate {
//    func carbonTabSwipeNavigation(_ carbonTabSwipeNavigation: CarbonTabSwipeNavigation, viewControllerAt index: UInt) -> UIViewController {
//        var viewController = UIViewController()
//        switch index {
//        case 0:
//            viewController = ViewControllerHelper.getViewController(ofType: .CategoryViewController) as! CategoryViewController
//            return viewController
//        case 1:
//            viewController = ViewControllerHelper.getViewController(ofType: .SalesViewController) as! SalesViewController
//            return viewController
//        default:
//            viewController = ViewControllerHelper.getViewController(ofType: .SalesViewController) as! SalesViewController
//            return viewController
//        }
//        
//    }
//    
//    
//}


extension HomeViewController: GMSAutocompleteViewControllerDelegate {
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        //print("Place name: \(place.name)")
        //print("Place ID: \(place.placeID)")
        //print("Place attributions: \(place.attributions)")

         let locValue: CLLocationCoordinate2D = place.coordinate
        UserDefaults.standard.set(locValue.latitude, forKey: "latitude")
        UserDefaults.standard.set(locValue.longitude, forKey: "longitude")
        let location = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)

        location.placemark { (place, err) in
            if err == nil{
                self.lblLocation.text = "\(place?.subLocality ?? "Unnamed Area"), \(place?.subAdministrativeArea ?? "Unnamed Location")"
            }
        }
//        location.fetchCityAndCountry { city, country, error in
//            guard let city = city, let country = country, error == nil else { return }
//            self.lblLocation.text = "\(city), \(country)"
//        }
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}


//MARK:- UITEXTVIEW DELEGATE
extension HomeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if self.txtSearch.text?.isEmpty == false {
            DispatchQueue.main.async {
                self.view.endEditing(true)
            }
            if let vc = ViewControllerHelper.getViewController(ofType: .SearchResultViewController) as? SearchResultViewController {
                vc.searchedText = self.txtSearch.text ?? ""
                self.txtSearch.text = ""
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        return true
    }
    
        func textFieldDidBeginEditing(_ textField: UITextField) {
            
            let invocation = IQInvocation(self, #selector(didPressOnDoneButton))
            txtSearch.keyboardToolbar.doneBarButton.invocation = invocation
        }
        
        @objc func didPressOnDoneButton() {
           txtSearch.resignFirstResponder()
            if self.txtSearch.text?.isEmpty == false {
                DispatchQueue.main.async {
                    self.view.endEditing(true)
                }
                if let vc = ViewControllerHelper.getViewController(ofType: .SearchResultViewController) as? SearchResultViewController {
                    vc.searchedText = self.txtSearch.text ?? ""
                    self.txtSearch.text = ""
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    
//    @objc func textFieldDidChange(_ textField: UITextField) {
//
//        let params = ["keyword":textField.text ?? ""]
//        RVApiManager.postAPI(Apis.searchCategories, parameters:params, Vc: self, showLoader: false) { (data:Categories) in
//            if let success = data.success{
//                if success == true{
//                    if let categoriesData = data.data{
//                        self.jsonResponse = categoriesData
//                        self.collectionView.reloadData()
//                        if self.jsonResponse?.count == 0{
//                            self.showAlert(message: "No categories found", strtitle: "")
//                        }
//                    }
//                }else{
//                    self.showAlert(message: data.message ?? "Something went wrong", strtitle: "")
//                }
//            }else{
//                self.showAlert(message: data.message ?? "Something went wrong", strtitle: "")
//            }
//        }
//
//    }
}


//MARK:- CLLOCATION MANAGER DELEGATE
extension HomeViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        UserDefaults.standard.set(locValue.latitude, forKey: "latitude")
        UserDefaults.standard.set(locValue.longitude, forKey: "longitude")
    }
    
 
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
        case .authorizedAlways:
            setUpLocation()
        case.authorizedWhenInUse:
            setUpLocation()
        case.denied:
            print("Location Permission denied")
        case .notDetermined:
            print("Location Permission not determined")
        default:
            print("Location Permission not determined")
        }
    }
    
    func setUpLocation(){
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.requestAlwaysAuthorization()

        if
           CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
           CLLocationManager.authorizationStatus() ==  .authorizedAlways
        {
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            let locValue: CLLocationCoordinate2D = locationManager.location?.coordinate ?? CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
           UserDefaults.standard.set(locValue.latitude, forKey: "latitude")
           UserDefaults.standard.set(locValue.longitude, forKey: "longitude")
            let location = CLLocation(latitude: locationManager.location?.coordinate.latitude ?? 0.0, longitude: locationManager.location?.coordinate.longitude ?? 0.0)
            location.placemark { (place, err) in
                if err == nil{
                    self.lblLocation.text = "\(place?.subLocality ?? ""), \(place?.subAdministrativeArea ?? "")"
                }
            }
//            location.fetchCityAndCountry { city, country, error in
//                guard let city = city, let country = country, error == nil else { return }
//                self.lblLocation.text = "\(city), \(country)"
//            }
        }
    }
}

//MARK:- CUSTOM DELEGATE
extension HomeViewController: HideShowUpperView {
    func hide() {
        UIView.animate(withDuration: 0.5) {
            self.imgSearch.isHidden = true
            self.btnLocation.isHidden = true
            self.heightView.constant = 0
            self.topView.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    func show() {
        UIView.animate(withDuration: 0.5) {
            self.imgSearch.isHidden = false
            self.btnLocation.isHidden = false
            self.heightView.constant = 36
            self.topView.constant = 16
            self.view.layoutIfNeeded()
        }
    }
}
//MARK:- HELPER FUNCTIONS
extension HomeViewController {
    func animateView() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.collectionView?.performBatchUpdates({
                UIView.animate(views: self.collectionView!.orderedVisibleCells,
                               animations: self.animations, delay: 0, duration: 2, completion: {
                    })
            }, completion: nil)
        }
    }
}


extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.jsonResponse?.count ?? 0
                
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIds.CategoryCell, for: indexPath) as! CategoryCell
        let dict = self.jsonResponse?[indexPath.row]
        if let catName = dict?.name {
            cell.lblCatName.text = catName
        }
        if let catImage = dict?.img{
            cell.imgRow.sd_setImage(with: URL(string: "\(serverBaseURL)/\(catImage)"), placeholderImage: UIImage(named: "dummy_img"))
        }

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (self.collectionView.frame.width / 2) - 12
        return CGSize(width: width, height: width)
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let dict = self.jsonResponse?[indexPath.row]
        if let vc = ViewControllerHelper.getViewController(ofType: .SeeAllProductsViewController) as? SeeAllProductsViewController {
            if let categoryId = dict?.id {
                vc.catId = "\(categoryId)"
            }
            vc.viewType = false
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
}

//MARK:- SCROLLVIEW DELEGATE
extension HomeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (self.lastContentOffset > scrollView.contentOffset.y) {
            if scrollView.contentOffset.y < 100 {
//                hideShowUpperView?.show()
            }
            
        }
        
        else if (self.lastContentOffset < scrollView.contentOffset.y) {
            if scrollView.contentOffset.y > 100 {
//                hideShowUpperView?.hide()
            }
            
        }
        self.lastContentOffset = scrollView.contentOffset.y
    }
}

//MARK:- Api Call
extension HomeViewController{
    
    func fetchCategories(){
        let params = [String:Any]()
        RVApiManager.getAPI(Apis.categories, parameters:params, Vc: self, showLoader: true) { (data:Categories) in
            if let success = data.success{
                if success == true{
                    if let categoriesData = data.data{
                        self.jsonResponse = categoriesData
                        self.collectionView.reloadData()
                        if self.jsonResponse?.count == 0{
                            self.showAlert(message: "No categories found", strtitle: "")
                        }
//                        DispatchQueue.main.async {
//                            self.animateView()
//                        }
                       
                    }
                }else{
                    self.showAlert(message: data.message ?? "Something went wrong", strtitle: "")
                }
            }else{
                self.showAlert(message: data.message ?? "Something went wrong", strtitle: "")
            }
        }
    }
}
