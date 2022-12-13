//
//  ProductDetailsViewController.swift
//  iChota
//
//  Created by Lalit on 12/10/20.
//  Copyright © 2020 AppDeft. All rights reserved.
//

import UIKit
import FloatRatingView
import GoogleMaps
import SDWebImage
import AdvancedPageControl
import Toast_Swift
import KRProgressHUD
protocol ShowChatProtocol {
    func showChat()
}

protocol RelatedProductsLikeBtn {
    func likeUnlike(cell:RelatedItemsCell)
}


var showChatProtocol: ShowChatProtocol?

class ProductDetailsCell: UICollectionViewCell {
    
    @IBOutlet weak var imgProduct: UIImageView!
    @IBOutlet weak var imgwidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var imgHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var imgProductNew: UIImageView!

}

class RelatedItemsCell: UICollectionViewCell {
    
    @IBOutlet weak var imgRow: UIImageView!
    @IBOutlet weak var imgSellType: UIImageView!
    
    @IBOutlet weak var lblProductName: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    
    @IBOutlet weak var lblMonth: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var btnLikeUnlike: UIButton!
    @IBOutlet weak var lblFeatured: UILabel!
    
    var cellDelegate:RelatedProductsLikeBtn?
    override class func awakeFromNib() {
        
    }
    
    @IBAction func btnLikeUnlike(_ sender: Any) {
        cellDelegate?.likeUnlike(cell: self)
    }
    
}

class ProductDetailsViewController: UIViewController,RelatedProductsLikeBtn {
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnFavorite: UIButton!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var btnReport: UIButton!
    @IBOutlet weak var btnSendOffer: UIButton!
    @IBOutlet weak var lblRatingAndReviews: UILabel!
    @IBOutlet weak var lblItemDescription: UILabel!
    @IBOutlet weak var lblListedSinceData: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblListedSince: UILabel!
    @IBOutlet weak var rightConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblProductLocation: UILabel!
    @IBOutlet weak var lblProductName: UILabel!
    @IBOutlet weak var btnCall: UIButton!
    @IBOutlet weak var clcViewRealtedItems: UICollectionView!
    @IBOutlet weak var clcViewRelatedHeight: NSLayoutConstraint!
    @IBOutlet weak var lblRealtedHeight: NSLayoutConstraint!
    @IBOutlet weak var lblRelatedClcTop: NSLayoutConstraint!
    @IBOutlet weak var viewCallAndChat: UIView!
    @IBOutlet weak var viewMarkAsSold: UIView!
    @IBOutlet weak var lblSellerLocation: UILabel!
    @IBOutlet weak var viewLine1: UIView!
    @IBOutlet weak var viewLine2: UIView!
    @IBOutlet weak var viewLine3: UIView!
    
    var productId = ""
    var myAdd = false
    var id = ""
    var userId = ""
    var arrProductImages = [String]()
    var jsonResponse:ProductDetail?
    var arrRelatedItems:[CatProductDetails]?
    var style = ToastStyle()
    var type = ""
    var isFav = 0
    var sellerPhoneNumber = String()
    var isMyOwnProduct = false
    var userImg = String()
    var categoryId = String()
    var isFromURL = Bool()
    var productName = String()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchProductDetail()
//        self.showMap(UserDefaultsValue.LATITUDE, UserDefaultsValue.LONGITUDE)
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        self.designUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.clcViewRelatedHeight.constant = 0
        self.lblRealtedHeight.constant = 0
        self.lblRelatedClcTop.constant = 0
        self.fetchProducts()
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @IBAction func btnBackClicked(_ sender: UIButton) {
        if isFromURL{
            let story = UIStoryboard(name: "Main", bundle:nil)
            let vc = story.instantiateViewController(withIdentifier: "TabBarViewController") as! TabBarViewController
            UIApplication.shared.windows.first?.rootViewController = vc
            UIApplication.shared.windows.first?.makeKeyAndVisible()
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func btnLikeClicked(_ sender: UIButton) {

        if self.isFav == 0{
            addToFavourite(id: self.productId)
        }else{
            deleteFavourite(id: self.productId)
        }
    }
    
    @IBAction func btnShareClicked(_ sender: UIButton) {
        let image = UIImageView()
        if arrProductImages.count > 0{
            image.sd_setImage(with: URL(string: "\(serverBaseURL)/\(arrProductImages[0])"))
        }
//        let items = [image.image ?? #imageLiteral(resourceName: "placeHolder"),URL(string: "www.beba.com://ProductDetailsViewController?product_id=\(self.productId)&type=0")!] as [Any]
        
        let items = [image.image ?? #imageLiteral(resourceName: "placeHolder"),URL(string: "\(serverBaseURL)/api/user/share/\(self.productId)")!] as [Any]
        
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(ac, animated: true)
    }
    
    func likeUnlike(cell: RelatedItemsCell) {
        if let indexpath = clcViewRealtedItems.indexPath(for: cell){
            if let dict = arrRelatedItems?[indexpath.row]{
                if let isFav = dict.isFav{
                    if isFav == 0{
                        if let productId = dict.id{
                            self.relatedAddToFavourite(id: "\(productId)", index: indexpath.row)
                        }
                    }else{
                        if let productId = dict.id{
                            self.realtedDeleteFavourite(id: "\(productId)", index: indexpath.row)
                        }
                    }
                }
            }
        }
    }
    
    
//    @IBAction func btnReportClicked(_ sender: UIButton) {
//        let userId = UserDefaults.standard.value(forKey: "user_id")
//        if userId == nil {
//            self.view.makeToast(AlertMessages.LOGIN_TO_REPORT_ITEM, duration: 2, position: .bottom, style: self.style)
//        } else if userId as? String == self.userId {
//            self.view.makeToast(AlertMessages.LOGIN_TO_REPORT_ITEM, duration: 2, position: .bottom, style: self.style)
//        } else {
//            if let vc = ViewControllerHelper.getViewController(ofType: .ReportItemViewController) as? ReportItemViewController {
//                vc.modalPresentationStyle = .overFullScreen
//                if let id = self.jsonResponse[WSResponseParams.WS_RESP_PARAM_ID] as? String {
//                    vc.id = id
//                    self.present(vc, animated: true, completion: nil)
//                }
//            }
//        }
//
//    }
    
    @IBAction func btnViewProfile(_ sender: UIButton) {
        
    }
    
    @IBAction func btnMarkAsSold(_ sender: Any) {
        self.markAsSold()
    }
    
    
    @IBAction func btnCall(_ sender: Any) {
        if let url = URL(string: "tel://\(self.sellerPhoneNumber)"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    
    @IBAction func btnSendOfferClicked(_ sender: UIButton) {
        
//        self.openChat()
//        let selfId = UserDefaults.standard.value(forKey: "userId")  as? String ?? ""
//        self.createChannel(users: ["P\(productId)",userId,selfId], name: self.productName)
//
//        if isMyOwnProduct{
//            self.showAlertWithOkAndCancel(message: "Are you sure! you want to mark this ad as sold", strtitle: "", okTitle: "Mark as sold", cancel: "Cancel") { (ok) in
//                self.markAsSold()
//            } handlerCancel: { (Cancel) in
//
//            }
//        }else{
//                self.setUpQuickBlox()
//        }
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChatDetailVC") as! ChatDetailVC
        vc.productDetails.name = productName
        vc.productDetails.id = productId
        if self.arrProductImages.count > 0{
            vc.productDetails.img = arrProductImages[0]
        }
        vc.productDetails.sellerId = userId
        vc.productDetails.sellerName = lblUserName.text ?? ""
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func btnShowUserProfileClicked(_ sender: UIButton) {
        if !isMyOwnProduct{
            if let vc = ViewControllerHelper.getViewController(ofType: .PublicProfileViewController) as? PublicProfileViewController {
                vc.userId = self.userId
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    

    
}

//MARK:- UICOLLECTION VIEW DELEGATE
extension ProductDetailsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if clcViewRealtedItems == collectionView{
            return arrRelatedItems?.count ?? 0
        }else{
            return self.arrProductImages.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if clcViewRealtedItems == collectionView{
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RelatedItemsCell", for: indexPath) as! RelatedItemsCell
            cell.shadowDecorate()
            let dict = self.arrRelatedItems?[indexPath.row]
            if let catImage = dict?.img {
                    cell.imgRow.sd_setImage(with: URL(string: "\(serverBaseURL)/\(catImage)"), placeholderImage: UIImage(named: "placeHolder"))
            }
            
            if let pName = dict?.name{
                cell.lblProductName.text = pName
            }

            if let productDesc = dict?.product_desc{
                cell.lblDescription.text = productDesc
            }
            if let price = dict?.price{
                cell.lblPrice.text = "\(price)$"
            }
            
            if let createdDate = dict?.createdDtm{
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                let date = dateFormatter.date(from: createdDate)
                cell.lblMonth.text = date?.timeAgoSinceDate()
            }

            cell.cellDelegate = self

            if let favStatus = dict?.isFav{
                if favStatus == 1{
                    cell.btnLikeUnlike.setImage(#imageLiteral(resourceName: "like"), for: .normal)
                }else{
                    cell.btnLikeUnlike.setImage(#imageLiteral(resourceName: "heartUnfilled"), for: .normal)
                }
            }
            
            if let isFeatured = dict?.isFeatured{
                if isFeatured > 0{
                    cell.lblFeatured.isHidden = false
                }else{
                    cell.lblFeatured.isHidden = true
                }
            }
            return cell
            
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIds.ProductDetailsCell, for: indexPath) as! ProductDetailsCell
            let img = self.arrProductImages[indexPath.row]
            cell.imgProduct.sd_setImage(with: URL(string: "\(serverBaseURL)/\(img)"), placeholderImage: UIImage(named: "placeHolder"))
            
            cell.imgProductNew.sd_setImage(with: URL(string: "\(serverBaseURL)/\(img)"), placeholderImage: UIImage(named: "placeHolder"))
            
            let width = self.collectionView.frame.width
            let height = self.collectionView.frame.height
            cell.imgHeightConstraint.constant = height
            cell.imgwidthConstraint.constant = width
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let userId = UserDefaults.standard.value(forKey: "userId") as? String ?? ""
        if clcViewRealtedItems == collectionView{
                if let dict = arrRelatedItems?[indexPath.row]{
                    if let id = dict.id{
                        self.productId = "\(id)"
                        if let catId = dict.category_id{
                            self.categoryId = "\(catId)"
                        }
                        if let sellerId = dict.user_id{
                            if userId == "\(sellerId)"{
                                self.isMyOwnProduct = true
                                    self.btnCall.isHidden = true
                                    self.btnSendOffer.isHidden = true
                                    self.viewMarkAsSold.isHidden = false
                            }else{
                                self.isMyOwnProduct = false
                                self.btnCall.isHidden = false
                                self.btnSendOffer.isHidden = false
                                self.viewMarkAsSold.isHidden = true
                            }
                        }
                        self.fetchProductDetail()
                        self.fetchProducts()
                    }
                }
        }else{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "PhotoDetailsVC") as! PhotoDetailsVC
            vc.arrProductImages = self.arrProductImages
            vc.selectedIndex = indexPath.row
            vc.phoneNumber = self.sellerPhoneNumber
            vc.productId = self.productId
            vc.isMyOwnProduct = self.isMyOwnProduct
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if clcViewRealtedItems == collectionView{
            let width = (self.clcViewRealtedItems.frame.width / 2) - 15
            return CGSize(width: width, height: 254)
        }else{
            return CGSize(width: self.collectionView.frame.width, height: self.collectionView.frame.height)
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if clcViewRealtedItems == collectionView{
            return 10
        }else{
            return 0
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
    }
    
}


//MARK:- DESIGNUI
extension ProductDetailsViewController {
    func designUI() {
        self.navigationController?.navigationBar.isHidden = true
        if isMyOwnProduct{
            self.btnCall.isHidden = true
            self.btnSendOffer.isHidden = true
            self.viewMarkAsSold.isHidden = false
        }else{
            self.btnCall.isHidden = false
            self.btnSendOffer.isHidden = false
            self.viewMarkAsSold.isHidden = true
        }
    }
}


//MARK:- API CALL
extension ProductDetailsViewController {
//    func fetchProductData() {
//        if WSManager.isConnectedToInternet() {
//            let params: [String: AnyObject] = [WSRequestParams.WS_REQS_PARAM_ID: self.id as AnyObject]
//            WSManager.wsCallFetchProductData(params) { (response, message) in
//                self.navigationController?.view.makeToastActivity(.center)
//                for i in 0..<response.count {
//                    let dict = response[i]
//                    self.jsonResponse = dict
//                    if let productImages = dict[WSResponseParams.WS_RESP_PARAM_PRODUCT_IMAGE] as? [String] {
//                        self.arrProductImages = productImages
//                        self.collectionView.reloadData()
//                    }
//
//                    if let productName = dict[WSResponseParams.WS_RESP_PARAM_PRODUCT_NAME] as? String {
//                    }
//
//                    if let productDescription = dict[WSResponseParams.WS_RESP_PARM_PRODUCT_DESCRIPTION] as? String {
//                        self.lblItemDescription.text = productDescription
//                    }
//
//                    if let listedDate = dict[WSResponseParams.WS_RESP_PARAM_CREATE_DTM] as? String {
//                        self.lblListedSinceData.text = Helper.convertProductListedDate(listedDate)
//
//                    }
//
//                    if let lat = dict[WSResponseParams.WS_RESP_PARAM_LATITUDE] as? String {
//                        if let lng = dict[WSResponseParams.WS_RESP_PARAM_LONGITUDE] as? String {
////                            self.showMap(Double(lat) ?? 0.0, Double(lng) ?? 0.0)
//                            if lat == "" || lng == "" {
////                                self.lblItemAddress.text = Strings.NO_ADDRESS
//                            } else {
//                                self.getAddressFromLatLon(pdblLatitude: lat, withLongitude: lng)
//                            }
//                        }
//                    }
//
//                    if let userId = dict[WSResponseParams.WS_RESP_PARAM_USERID] as? String {
//                        if userId == UserDefaults.standard.value(forKey: "user_id") as? String {
////                            self.btnSendOffer.isHidden = true
//                            self.btnFavorite.isHidden = true
//                            self.btnReport.isHidden = true
//                            self.rightConstraint.constant = -32
//                        } else {
////                            self.btnSendOffer.isHidden = false
//                            self.btnFavorite.isHidden = false
//                            self.btnReport.isHidden = false
//                            self.rightConstraint.constant = 8
//                        }
//                        self.userId = userId
//                    }
//                    if let userDetails = dict[WSRequestParams.WS_REQS_PARAM_USER_DETAIL] as? [[String: AnyObject]] {
//                        for i in 0..<userDetails.count {
//                            let userDict = userDetails[i]
//                            if let name = userDict[WSResponseParams.WS_RESP_PARAM_NAME] as? String {
//                            }
//                            if let userImage = userDict[WSResponseParams.WS_RESP_PARAM_USER_IMAGE] as? String {
//                                let image = WebService.imageBaseUrl + userImage
//
//
//                            }
//                        }
//                    }
//
//                    if let favStatus = dict[WSResponseParams.WS_RESP_PARAM_FAV_STATUS] as? String {
//                        if favStatus == Strings.ONE {
//                            self.btnFavorite.setImage(UIImage.init(named: "ic_fav_selected"), for: UIControl.State())
//                        } else {
//                            self.btnFavorite.setImage(UIImage.init(named: "ic_favorite"), for: UIControl.State())
//                        }
//                    }
//
//                }
//
//                self.pageControl.numberOfPages = self.arrProductImages.count
//                self.navigationController?.view.hideToastActivity()
//            } failure: { (error) in
//                print(error.localizedDescription)
//                self.navigationController?.view.hideToastActivity()
//            }
//
//        } else {
//
//        }
//    }
    
    func fetchServiceData() {
        if WSManager.isConnectedToInternet() {
            let params: [String: AnyObject] = ["service_id": self.id as AnyObject]
            WSManager.wsCallFetchParticularServiceDetails(params) { response, message in
//                for i in 0..<response.count {
//                    let dict = response[i]
//                    self.jsonResponse = dict
//                    if let productImages = dict["service_img"] as? [String] {
//                        self.arrProductImages = productImages
//                        self.collectionView.reloadData()
//                    }
//
//                    if let productDescription = dict["service_description"] as? String {
//                        self.lblItemDescription.text = productDescription
//                    }
//
//                    if let listedDate = dict["createdon"] as? String {
//                        self.lblListedSinceData.text = Helper.convertProductListedDate(listedDate)
//
//                    }
//
//                    if let lat = dict["latitude"] as? String {
//                        if let lng = dict["longitude"] as? String {
////                            self.showMap(Double(lat) ?? 0.0, Double(lng) ?? 0.0)
//                            if lat == "" || lng == "" {
////                                self.lblItemAddress.text = Strings.NO_ADDRESS
//                            } else {
//                                self.getAddressFromLatLon(pdblLatitude: lat, withLongitude: lng)
//                            }
//                        }
//                    }
//
//                    if let userId = dict[WSResponseParams.WS_RESP_PARAM_USERID] as? String {
//                        self.userId = userId
//                    }
//                    if let userDetails = dict["userdetail"] as? [[String: AnyObject]] {
//                        for _ in 0..<userDetails.count {
//                            let newDict = userDetails[0]
//                            if let name = newDict[WSResponseParams.WS_RESP_PARAM_NAME] as? String {
//                            }
//
//                            if let userImage = newDict[WSResponseParams.WS_RESP_PARAM_USER_IMAGE] as? String {
//                                let image = WebService.imageBaseUrl + userImage
//
//
//                            }
//                        }
//
//                    }
//
//                    if let favStatus = dict[WSResponseParams.WS_RESP_PARAM_FAV_STATUS] as? String {
//                        if favStatus == Strings.ONE {
//                            self.btnFavorite.setImage(UIImage.init(named: "ic_fav_selected"), for: UIControl.State())
//                        } else {
//                            self.btnFavorite.setImage(UIImage.init(named: "ic_favorite"), for: UIControl.State())
//                        }
//                    }
//
//                }
                
                self.pageControl.numberOfPages = self.arrProductImages.count
                self.navigationController?.view.hideToastActivity()
            } failure: { error in
                print(error.localizedDescription)
                self.navigationController?.view.hideToastActivity()
            }

        }
    }
    
    func addToFavorite() {
        let userId = UserDefaults.standard.value(forKey: "user_id")
        if WSManager.isConnectedToInternet() {
            let params: [String: AnyObject] = [WSRequestParams.WS_REQS_PARAM_USER_ID: userId as AnyObject,
                                               WSRequestParams.WS_REQS_PARAM_PRODUCT_ID: self.id as AnyObject]
            
            WSManager.wsCallAddToFavoriteList(params) { (response, message) in
                
                if let dataMessage = response[WSResponseParams.WS_RESP_PARAM_DATA] as? Int {
                    if dataMessage == 1 {
                        self.btnFavorite.setImage(UIImage.init(named: "ic_fav_selected"), for: UIControl.State())
                    } else {
                        self.btnFavorite.setImage(UIImage.init(named: "ic_favorite"), for: UIControl.State())
                    }
                }
                self.view.makeToast(message, duration: 2, position: .bottom, style: self.style)
            } failure: { (error) in
                print(error.localizedDescription)
            }
            
        } else {
            
        }
    }
}


//MARK:- GET ADDRESS
extension ProductDetailsViewController {
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
//                                            self.lblItemAddress.text = addressString
                                            //self.lblCurrentLocation.text = addressString
                                        }
                                    })
        
    }
}



extension ProductDetailsViewController{
    //MARK:- Api Call
    
    func fetchProductDetail(){
        let params = [String:Any]()
        RVApiManager.getAPI("\(Apis.singleProductDetails)/\(self.productId)", parameters:params, Vc: self, showLoader: true) { (data:SingleProductDetails) in
            if let success = data.success{
                if success{
                    if let categoriesData = data.data{
                        self.jsonResponse = categoriesData
                        if let arrImages = categoriesData.imgs{
                            self.arrProductImages = arrImages
                            self.pageControl.numberOfPages = self.arrProductImages.count
                        }
                        if let pName = categoriesData.name{
                            if let price = categoriesData.price{
                                self.lblProductName.text = "\(pName)\n$\(price)"
                                self.productName = pName
                            }
                        }
                        self.viewLine1.backgroundColor = .lightGray
                        self.viewLine2.backgroundColor = .lightGray
                        self.viewLine3.backgroundColor = .lightGray
                        self.viewLine1.alpha = 0.3
                        self.viewLine2.alpha = 0.3
                        self.viewLine3.alpha = 0.3
                        self.lblDescription.text = "Item Description"
                        if let itemDesc = categoriesData.product_desc{
                            self.lblItemDescription.text = itemDesc
                        }
                        if let userImg = categoriesData.userImg{
                            self.userImg = userImg
                            self.imgUser.borderWidth = 2
                            self.imgUser.sd_setImage(with: URL(string: "\(serverBaseURL)/\(userImg)"), placeholderImage: UIImage(named: "placeHolder"))
                        }
                        if let userName = categoriesData.user_name{
                            self.lblUserName.text = userName
                        }
                        if let userId = categoriesData.user_id{
                            self.userId = "\(userId)"
                        }
                        
                        if let userNumber = categoriesData.mobile{
                            self.sellerPhoneNumber = userNumber
                        }
                        if self.sellerPhoneNumber == "" || self.sellerPhoneNumber == "0"{
                            self.btnCall.isEnabled = false
                            self.btnCall.alpha = 0.6
                        }else{
                            self.btnCall.isEnabled = true
                            self.btnCall.alpha = 1
                        }
                        if let isFav = categoriesData.isFav{
                            if isFav == 1{
                                self.isFav = 1
                                self.btnFavorite.setImage(UIImage(named: "ic_fav_selected"), for: .normal)
                            }else{
                                self.isFav = 0
                                self.btnFavorite.setImage(UIImage(named: "ic_favorite"), for: .normal)
                            }
                        }
                        if let lat = categoriesData.latitude{
                            if let long = categoriesData.longitude{
                                let location = CLLocation(latitude: Double(lat) ?? 0.0000, longitude: Double(long) ?? 0.0000)
                                location.fetchCityAndCountry { city, country, error in
                                    guard let city = city, let country = country, error == nil else { return }
                                    self.lblSellerLocation.text = "Sellers Location"
                                    self.lblProductLocation.text = "\(city), \(country)"
                                }
                            }
                        }
                        if let createdDate = categoriesData.createdDtm{
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                            if  let date = dateFormatter.date(from: createdDate){
                                dateFormatter.dateFormat = "MMM d, yyyy"
                                self.lblListedSince.text = "Item Listed Since"
                                self.lblListedSinceData.text = dateFormatter.string(from: date)
                            }
                        }
                        if !self.checkAlreadyLogin(){
                            self.viewCallAndChat.isHidden = true
                        }
                        self.collectionView.reloadData()
                    }
                }else{
                    self.showAlert(message: data.message ?? "Something went wrong", strtitle: "")
                }
            }else{
                self.showAlert(message: data.message ?? "Something went wrong", strtitle: "")
            }
        }
        
    }
    
    func addToFavourite(id:String){
        let params = [String:Any]()
        RVApiManager.postAPI("\(Apis.addToFavourite)/\(id)", parameters: params, Vc: self, showLoader: true) { (data: AddToFavourite) in
            if let success =  data.success{
                if success{
                        self.fetchProductDetail()
                }else{
                    self.showAlert(message: data.message ?? "Something went wrong", strtitle: "")
                }
            }else{
                self.showAlert(message: data.message ?? "Something went wrong", strtitle: "")
            }
        }
    }
    
    func deleteFavourite(id:String){
        let params = [String:Any]()
        
        RVApiManager.deleteAPI("\(Apis.addToFavourite)/\(id)", parameters: params, Vc: self, showLoader: true) { (data:AddToFavourite) in
            if let success =  data.success{
                if success{
                    self.fetchProductDetail()
                }else{
                    self.showAlert(message: data.message ?? "Something went wrong", strtitle: "")
                }

            }else{
                self.showAlert(message: data.message ?? "Something went wrong", strtitle: "")
            }
        }
    }
    
        func markAsSold() {
            let params = [String:Any]()
            RVApiManager.putAPI("\(Apis.markAsSold)/\(self.productId)", parameters:params, Vc: self, showLoader: false) { (data:PostAd) in
                if let success = data.success{
                    if success == true{
                        self.showAlert(message: data.message ?? "Something went wrong", strtitle: "") { (ok) in
                            self.navigationController?.popViewController(animated: true)
                        }
                        }
                    }else{
                        self.showAlert(message: data.message ?? "Something went wrong", strtitle: "")
                    }
                }
            }

    
    func fetchProducts(){
        let params = [String:Any]()
        self.arrRelatedItems?.removeAll()
        RVApiManager.getAPI("\(Apis.getRelatedProducts)/\(self.categoryId)/\(self.productId)", parameters:params, Vc: self, showLoader: true) { (data:CategoryProducts) in
            if let success = data.success{
                if success{
                    if let categoriesData = data.data{
                        self.arrRelatedItems = categoriesData
                        
                        if categoriesData.count > 0{
                            self.clcViewRelatedHeight.constant = 270
                            self.lblRealtedHeight.constant = 30
                            self.lblRelatedClcTop.constant = 15
                        }else{
                            self.clcViewRelatedHeight.constant = 0
                            self.lblRealtedHeight.constant = 0
                            self.lblRelatedClcTop.constant = 0
                        }
                        self.clcViewRealtedItems.reloadData()
                    }
                }else{
                    self.clcViewRelatedHeight.constant = 0
                    self.lblRealtedHeight.constant = 0
                    self.lblRelatedClcTop.constant = 0
                    self.showAlert(message: data.message ?? "Something went wrong", strtitle: "")
                }
            }else{
                self.clcViewRelatedHeight.constant = 0
                self.lblRealtedHeight.constant = 0
                self.lblRelatedClcTop.constant = 0
                self.showAlert(message: data.message ?? "Something went wrong", strtitle: "")
            }
        }
    }
    
    func relatedAddToFavourite(id:String, index:Int){
        let params = [String:Any]()
        RVApiManager.postAPI("\(Apis.addToFavourite)/\(id)", parameters: params, Vc: self, showLoader: true) { (data: AddToFavourite) in
            if let success =  data.success{
                if success{
                        self.fetchProducts()
                }else{
                    self.showAlert(message: data.message ?? "Something went wrong", strtitle: "")
                }
            }else{
                self.showAlert(message: data.message ?? "Something went wrong", strtitle: "")
            }
        }
    }
    
    func realtedDeleteFavourite(id:String, index:Int){
        let params = [String:Any]()
        RVApiManager.deleteAPI("\(Apis.addToFavourite)/\(id)", parameters: params, Vc: self, showLoader: true) { (data:AddToFavourite) in
            if let success =  data.success{
                if success{
                        self.fetchProducts()
                }else{
                    self.showAlert(message: data.message ?? "Something went wrong", strtitle: "")
                }
            }else{
                self.showAlert(message: data.message ?? "Something went wrong", strtitle: "")
            }
        }
    }

}
extension CLLocation {
    func fetchCityAndCountry(completion: @escaping (_ city: String?, _ country:  String?, _ error: Error?) -> ()) {
        CLGeocoder().reverseGeocodeLocation(self) { completion($0?.first?.locality, $0?.first?.country, $1) }
        
    
    }
    
    func placemark(completion: @escaping (_ placemark: CLPlacemark?, _ error: Error?) -> ()) {
        CLGeocoder().reverseGeocodeLocation(self) { completion($0?.first, $1) }
    }
}


