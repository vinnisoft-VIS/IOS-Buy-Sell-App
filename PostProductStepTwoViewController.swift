//
//  PostProductStepTwoViewController.swift
//  iChota
//
//  Created by Lalit on 12/10/20.
//  Copyright © 2020 AppDeft. All rights reserved.
//

import UIKit
//import BonsaiController
import GoogleMaps
import GooglePlaces
import CoreLocation

protocol HandleCancel {
    func goBack()
}

protocol clearProductData {
    func clearPreviousData()
}
var handleCancel: HandleCancel?

class PostProductStepTwoViewController: UIViewController {

    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var switchSellNationwide: UISwitch!
    @IBOutlet weak var viewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewLineOne: UIView!
    @IBOutlet weak var lblSelectBox: UILabel!
    @IBOutlet weak var viewOne: UIView!
    @IBOutlet weak var viewTwo: UIView!
    @IBOutlet weak var viewThree: UIView!
    @IBOutlet weak var viewFour: UIView!
    @IBOutlet weak var lblPriceOne: UILabel!
    @IBOutlet weak var lblPriceTwo: UILabel!
    @IBOutlet weak var lblPriceThree: UILabel!
    @IBOutlet weak var lblPriceFour: UILabel!
    @IBOutlet weak var lblChooseSizeWeight: UILabel!
    @IBOutlet weak var lblTerms: UILabel!
    @IBOutlet weak var viewLineTwo: UIView!
    @IBOutlet weak var btnPostProduct: UIButton!
    @IBOutlet weak var imgFile: UIImageView!
    @IBOutlet weak var lblFile: UILabel!
    @IBOutlet weak var imgMedicine: UIImageView!
    @IBOutlet weak var lblMedicine: UILabel!
    @IBOutlet weak var imgBox: UIImageView!
    @IBOutlet weak var lblBox: UILabel!
    @IBOutlet weak var imgBoxFour: UIImageView!
    @IBOutlet weak var lblBoxFour: UILabel!
    @IBOutlet weak var viewForMap: GMSMapView!
    @IBOutlet weak var lblShippingPolicy: UILabel!
    var isFromEdit = false
    var productId = String()
    
    var locationManager = CLLocationManager()
    private var transitionType: TransitionType = .bubble
    var productName = ""
    var productDescription = ""
    var productPrice = ""
    var firmOnPrice = 0
    var category = ""
    var buyingOption = ""
    var condition = ""
    var sellShipNationwide = 0
    var boxSize = ""
    var categoryid = ""
    var coverImage = UIImage()
    var arrProductImages = [UIImage()]
    
    var brand = ""
    var year = ""
    var fuelType = ""
    var transmissionType = ""
    var KmDriven = ""
    var NoOfOwners = ""
    
    var lat = 0.0
    var lng = 0.0
    var delegate:clearProductData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if isFromEdit{
            self.btnPostProduct.setTitle("Update Product", for: .normal)
        }else{
            self.btnPostProduct.setTitle("Post Product", for: .normal)
        }
        self.txtSearch.delegate = self
        self.setUpMap()
        self.designUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }

    @IBAction func btnBackClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func swichSellNationwideClicked(_ sender: UISwitch) {
        if sender.isOn {
            self.sellShipNationwide = 1
            self.boxSize = "Box(5lb)"
            self.showView()
        } else {
            self.sellShipNationwide = 0
            self.boxSize = ""
            self.hideView()
        }
    }
    
    @IBAction func btnPostProductClicked(_ sender: UIButton) {
        if isFromEdit{
            self.editProduct()
        }else{
            self.postProduct()
        }
    }
    private func showSmallVC(transition: TransitionType) {
//        transitionType = transition
//        let vc = storyboard?.instantiateViewController(withIdentifier: "ThanksViewController") as! ThanksViewController
//        vc.transitioningDelegate = self
//        vc.modalPresentationStyle = .custom
//        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func btnMedicineClicked(_ sender: UIButton) {
        self.medicineClick()
    }
    
    @IBAction func btnFileClicked(_ sender: UIButton) {
        self.fileClick()
    }
    
    
    @IBAction func btnBoxClicked(_ sender: UIButton) {
        self.boxClick()
    }
    
    @IBAction func btnFourClicked(_ sender: UIButton) {
        self.btnFourClick()
    }
}


//MARK:- HELPER FUNCTION
extension PostProductStepTwoViewController {
    func designUI() {
        self.lblShippingPolicy.isUserInteractionEnabled = true
        self.lblShippingPolicy.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(handleShippingPolicyClick)))
        self.fileClick()
        self.hideView()
        handleCancel = self
    }
    
    func showView() {
        self.viewHeightConstraint.constant = 280
        viewLineOne.isHidden = false
        self.lblSelectBox.isHidden = false
        self.viewOne.isHidden = false
        self.viewTwo.isHidden = false
        self.viewThree.isHidden = false
        self.viewFour.isHidden = false
        self.lblPriceOne.isHidden = false
        self.lblPriceTwo.isHidden = false
        self.lblPriceThree.isHidden = false
        self.lblPriceFour.isHidden = false
        self.lblChooseSizeWeight.isHidden = false
        self.lblTerms.isHidden = false
        self.viewLineTwo.isHidden = false
    }
    
    func hideView() {
        self.viewHeightConstraint.constant = 0
        viewLineOne.isHidden = true
        self.lblSelectBox.isHidden = true
        self.viewOne.isHidden = true
        self.viewTwo.isHidden = true
        self.viewThree.isHidden = true
        self.viewFour.isHidden = true
        self.lblPriceOne.isHidden = true
        self.lblPriceTwo.isHidden = true
        self.lblPriceThree.isHidden = true
        self.lblPriceFour.isHidden = true
        self.lblChooseSizeWeight.isHidden = true
        self.lblTerms.isHidden = true
        self.viewLineTwo.isHidden = true
    }
    
    func fileClick() {
        self.viewOne.backgroundColor = ChotaColors.BUTTON_BACKGROUND_COLOR
        self.viewTwo.backgroundColor = ChotaColors.BUTTON_LIGHT_COLOR
        self.viewThree.backgroundColor = ChotaColors.BUTTON_LIGHT_COLOR
        self.viewFour.backgroundColor = ChotaColors.BUTTON_LIGHT_COLOR
        self.imgFile.image = UIImage.init(named: "file-copy_white")
        self.lblFile.textColor = UIColor.white
        self.imgMedicine.image = UIImage.init(named: "medicine")
        self.lblMedicine.textColor = UIColor.darkGray
        self.imgBox.image = UIImage.init(named: "box-ribbon")
        self.lblBox.textColor = UIColor.darkGray
        self.imgBoxFour.image = UIImage.init(named: "box-5")
        self.lblBoxFour.textColor = UIColor.darkGray
    }
    
    func medicineClick() {
        self.viewOne.backgroundColor = ChotaColors.BUTTON_LIGHT_COLOR
        self.viewTwo.backgroundColor = ChotaColors.BUTTON_BACKGROUND_COLOR
        self.viewThree.backgroundColor = ChotaColors.BUTTON_LIGHT_COLOR
        self.viewFour.backgroundColor = ChotaColors.BUTTON_LIGHT_COLOR
        self.imgFile.image = UIImage.init(named: "file-copy")
        self.lblFile.textColor = UIColor.darkGray
        self.imgMedicine.image = UIImage.init(named: "medicine_white")
        self.lblMedicine.textColor = UIColor.white
        self.imgBox.image = UIImage.init(named: "box-ribbon")
        self.lblBox.textColor = UIColor.darkGray
        self.imgBoxFour.image = UIImage.init(named: "box-5")
        self.lblBoxFour.textColor = UIColor.darkGray
    }
    
    func boxClick() {
        self.viewOne.backgroundColor = ChotaColors.BUTTON_LIGHT_COLOR
        self.viewTwo.backgroundColor = ChotaColors.BUTTON_LIGHT_COLOR
        self.viewThree.backgroundColor = ChotaColors.BUTTON_BACKGROUND_COLOR
        self.viewFour.backgroundColor = ChotaColors.BUTTON_LIGHT_COLOR
        self.imgFile.image = UIImage.init(named: "file-copy")
        self.lblFile.textColor = UIColor.darkGray
        self.imgMedicine.image = UIImage.init(named: "medicine")
        self.lblMedicine.textColor = UIColor.darkGray
        self.imgBox.image = UIImage.init(named: "box-ribbon_white")
        self.lblBox.textColor = UIColor.white
        self.imgBoxFour.image = UIImage.init(named: "box-5")
        self.lblBoxFour.textColor = UIColor.darkGray
    }
    
    func btnFourClick() {
        self.viewOne.backgroundColor = ChotaColors.BUTTON_LIGHT_COLOR
        self.viewTwo.backgroundColor = ChotaColors.BUTTON_LIGHT_COLOR
        self.viewThree.backgroundColor = ChotaColors.BUTTON_LIGHT_COLOR
        self.viewFour.backgroundColor = ChotaColors.BUTTON_BACKGROUND_COLOR
        self.imgFile.image = UIImage.init(named: "file-copy")
        self.lblFile.textColor = UIColor.darkGray
        self.imgMedicine.image = UIImage.init(named: "medicine")
        self.lblMedicine.textColor = UIColor.darkGray
        self.imgBox.image = UIImage.init(named: "box-ribbon")
        self.lblBox.textColor = UIColor.darkGray
        self.imgBoxFour.image = UIImage.init(named: "box_white")
        self.lblBoxFour.textColor = UIColor.white
    }
    
    func showMap(_ lat: Double, _ lng: Double) {
        DispatchQueue.main.async {
            let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: lng, zoom: 14.0)
            self.viewForMap.camera = camera
            self.viewForMap.settings.compassButton = true
            self.viewForMap.isMyLocationEnabled = true
            self.viewForMap.settings.myLocationButton = true
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: lat, longitude: lng)
            marker.map = self.viewForMap
        }

    }
    
    @objc func handleShippingPolicyClick() {
        if let url = URL(string: "https://www.freeprivacypolicy.com/blog/privacy-policy-url/") {
            UIApplication.shared.open(url)
        }
    }
    
    
    func goToPlace() {
        self.txtSearch.resignFirstResponder()
        let acController = GMSAutocompleteViewController()
        acController.delegate = self
        present(acController, animated: true, completion: nil)
    }
}







//MARK:- CUSTOME DELEGATE
extension PostProductStepTwoViewController: HandleCancel {
    func goBack() {
        self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
    }
    
    
}

//MARK:- AUTOCOMPLETE API
extension PostProductStepTwoViewController: GMSAutocompleteViewControllerDelegate {
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("Place name: \(place.name ?? "")")
        dismiss(animated: true, completion: nil)
        self.viewForMap.clear()
        self.txtSearch.text = place.name
        
        let cordinate2D = CLLocationCoordinate2D(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        let marker = GMSMarker()
        marker.position = cordinate2D
        marker.title = "Location"
        marker.snippet = place.name
        marker.map = self.viewForMap
        self.lat = place.coordinate.latitude
        self.lng = place.coordinate.longitude
        self.viewForMap.camera = GMSCameraPosition.camera(withTarget: cordinate2D, zoom: 14)
        
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        
    }
    
}


extension PostProductStepTwoViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.goToPlace()
    }
}


//MARK:- LOCATION MANAGER DELEGATE
extension PostProductStepTwoViewController: CLLocationManagerDelegate {
    
}

//MARK:- GET ADDRESS FROM LAT LNG
extension PostProductStepTwoViewController {
    func getAddressFromLatLon(pdblLatitude: String, withLongitude pdblLongitude: String) {
        var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
        let lat: Double = Double("\(pdblLatitude)")!
        let lon: Double = Double("\(pdblLongitude)")!
        let ceo: CLGeocoder = CLGeocoder()
        center.latitude = lat
        center.longitude = lon
        let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)
        ceo.reverseGeocodeLocation(loc, completionHandler:
                                    {(placemarks, error) in
                                        if (error != nil)
                                        {
                                            print("reverse geodcode fail: \(error!.localizedDescription)")
                                        }
                                        let pm = placemarks
                                        
                                        if pm?.count ?? 0 > 0 {
                                            let pm = placemarks![0]
                                            var addressString : String = ""
                                            if pm.subLocality != nil {
                                                addressString = addressString + pm.subLocality! + ", "
                                            }
                                            if pm.thoroughfare != nil {
                                                addressString = addressString + pm.thoroughfare! + ", "
                                            }
                                            if pm.locality != nil {
                                                addressString = addressString + pm.locality! + ", "
                                            }
                                            if pm.country != nil {
                                                addressString = addressString + pm.country! + ", "
                                            }
                                            if pm.postalCode != nil {
                                                addressString = addressString + pm.postalCode! + " "
                                            }
                                            print(addressString)
                                            self.txtSearch.text = addressString
                                        }
                                    })
    }
}

extension PostProductStepTwoViewController{
    
    func postProduct(){
        let userId = UserDefaults.standard.value(forKey: "userId") as? String ?? ""
        let params = ["name": self.productName, "product_desc": self.productDescription,"category_id":self.categoryid,"latitude":self.lat,"longitude":self.lng,"product_condition":self.condition,"price":self.productPrice,"user_id":userId] as [String : Any]
        var imgNames = [String]()
        for _ in self.arrProductImages{
            imgNames.append("img")
        }
        RVApiManager.postApiWithImages(Apis.createProduct, image: self.arrProductImages, imageName: imgNames, Vc: self, parameters: params, isAnimating: true) { (data:PostAd) in
            if let success =  data.success{
                if success{
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "NewCongratulationsVC") as! NewCongratulationsVC
                    if let itemData = data.data{
                        if let productId = itemData.product_id{
                            vc.productId = "\(productId)"
                        }
                    }
                    self.clearData()
                    self.navigationController?.pushViewController(vc, animated: true)
                }else{
                    self.showAlert(message: data.message ?? "Something went wrong", strtitle: "")
                }
            }else{
                self.showAlert(message: data.message ?? "Something went wrong", strtitle: "")
            }
        }
    }
    
    func editProduct(){
        let userId = UserDefaults.standard.value(forKey: "userId") as? String ?? ""
        let params = ["name": self.productName, "product_desc": self.productDescription,"category_id":self.categoryid,"latitude":self.lat,"longitude":self.lng,"product_condition":self.condition,"price":self.productPrice,"user_id":userId,"id":self.productId] as [String : Any]
        var imgNames = [String]()
        for _ in self.arrProductImages{
            imgNames.append("img")
        }
        RVApiManager.postApiWithImages(Apis.editProduct, image: self.arrProductImages, imageName: imgNames, Vc: self, parameters: params, isAnimating: true) { (data:PostAd) in
            if let success =  data.success{
                if success{
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
                    vc.isFromEdit = true
                    self.navigationController?.pushViewController(vc, animated: true)
                }else{
                    self.showAlert(message: data.message ?? "Something went wrong", strtitle: "")
                }
            }else{
                self.showAlert(message: data.message ?? "Something went wrong", strtitle: "")
            }
        }
    }
    
    func clearData(){
        self.delegate?.clearPreviousData()
    }
}

// MARK:- Map Setup

extension PostProductStepTwoViewController{
    
    func setUpMap(){
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        if #available(iOS 14.0, *) {
            if self.locationManager.authorizationStatus == .authorizedWhenInUse {
                self.lat = self.locationManager.location?.coordinate.latitude ?? 0.0
                self.lng = self.locationManager.location?.coordinate.longitude ?? 0.0
                self.showMap(self.lat, self.lng)
                let location = CLLocation(latitude: locationManager.location?.coordinate.latitude ?? 0.0, longitude: locationManager.location?.coordinate.longitude ?? 0.0)
                location.placemark { (place, err) in
                    if err == nil{
                        self.txtSearch.text = "\(place?.subLocality ?? ""), \(place?.subAdministrativeArea ?? "")"
                    }
                }
                //                self.getAddressFromLatLon(pdblLatitude: String(self.lat), withLongitude: String(self.lng))
            } else if self.locationManager.authorizationStatus == .authorizedWhenInUse {
                self.lat = self.locationManager.location?.coordinate.latitude ?? 0.0
                self.lng = self.locationManager.location?.coordinate.longitude ?? 0.0
                self.showMap(self.lat, self.lng)
                let location = CLLocation(latitude: locationManager.location?.coordinate.latitude ?? 0.0, longitude: locationManager.location?.coordinate.longitude ?? 0.0)
                location.placemark { (place, err) in
                    if err == nil{
                        self.txtSearch.text = "\(place?.subLocality ?? ""), \(place?.subAdministrativeArea ?? "")"
                    }
                }
            } else if locationManager.authorizationStatus == .authorizedAlways {
                self.lat = self.locationManager.location?.coordinate.latitude ?? 0.0
                self.lng = self.locationManager.location?.coordinate.longitude ?? 0.0
                self.showMap(self.lat, self.lng)
                let location = CLLocation(latitude: locationManager.location?.coordinate.latitude ?? 0.0, longitude: locationManager.location?.coordinate.longitude ?? 0.0)
                location.placemark { (place, err) in
                    if err == nil{
                        self.txtSearch.text = "\(place?.subLocality ?? ""), \(place?.subAdministrativeArea ?? "")"
                    }
                }
            } else {
                Helper.showOKCancelAlertWithCompletion(onVC: self, title: "Alert", message: "Allow Beba to Access your current location.", btnOkTitle: "Settings", btnCancelTitle: "Cancel") {
                    UIApplication.shared.open(URL.init(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                    
                }
            }
        } else {
            if CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
                CLLocationManager.authorizationStatus() ==  .authorizedAlways {
                self.lat = self.locationManager.location?.coordinate.latitude ?? 0.0
                self.lng = self.locationManager.location?.coordinate.longitude ?? 0.0
                self.showMap(self.lat, self.lng)
                let location = CLLocation(latitude: locationManager.location?.coordinate.latitude ?? 0.0, longitude: locationManager.location?.coordinate.longitude ?? 0.0)
                location.placemark { (place, err) in
                    if err == nil{
                        self.txtSearch.text = "\(place?.subLocality ?? ""), \(place?.subAdministrativeArea ?? "")"
                    }
                }
                //                self.getAddressFromLatLon(pdblLatitude: String(self.lat), withLongitude: String(self.lng))
            }else {
                Helper.showOKCancelAlertWithCompletion(onVC: self, title: "Alert", message: "Allow Beba to Access your current location.", btnOkTitle: "Settings", btnCancelTitle: "Cancel") {
                    UIApplication.shared.open(URL.init(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                    
                }
            }
            
        }
    }
}
