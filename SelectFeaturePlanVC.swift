//
//  SelectFeaturePlanVC.swift
//  iChota
//
//  Created by Apple Developer on 26/07/21.
//  Copyright © 2021 AppDeft. All rights reserved.
//

import UIKit
import KRProgressHUD
import PayPalCheckout
import PassKit

struct Plans {
    static let planDuration = ["Featured Ad for 1 Day", "Featured Ad for 3 Days","Featured Ad for 1 Week", "Featured Ad for 2 Weeks"]
    static let price = ["1.5","2.5","4","7.5"]
    
    static let description = ["Reach up to 2 times more buyers","Reach up to 6 times more buyers","Reach up to 14 times more buyers","Reach up to 28 times more buyers"]
}

class FeatureTblCell:UITableViewCell{
    
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var viewSelection: UIView!
    @IBOutlet weak var btnCheck: UIButton!
    override class func awakeFromNib() {
        
    }
    

}

class SelectFeaturePlanVC: UIViewController {

    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnPay: UIButton!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var tblHeight: NSLayoutConstraint!
    var amount = "5.00"
    var productId = ""
    var type = 2
    var isFromEdit = false
    var selectedIndex = 1
    let formatter = NumberFormatter()
    var isPaymentDone = Bool()
    var paymentToken = String()
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    //MARK:- Button Actions
    
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnPay(_ sender: Any) {
        
            self.triggerPayPalCheckout()
        
    }
    
    //MARK:- Functions
    
    func setupUI(){
        formatter.generatesDecimalNumbers = true
        lblTitle.text = "Reach more buyers and Sell \n Faster"
        tblHeight.constant = CGFloat(Plans.price.count * 110)
    }
}
extension SelectFeaturePlanVC{

    
    func triggerPayPalCheckout() {
        Checkout.start(
            createOrder: { createOrderAction in
                let amount = PurchaseUnit.Amount(currencyCode: .usd, value: self.amount)
                let purchaseUnit = PurchaseUnit(amount: amount)
                let order = OrderRequest(intent: .capture, purchaseUnits: [purchaseUnit])
                createOrderAction.create(order: order)
            }, onApprove: { approval in
                approval.actions.capture { (response, error) in
                    print("Order successfully captured: \(String(describing: response?.data))")
                    self.featureProduct(transactionId: String(describing: response?.data))
                }

            }, onCancel: {

                /*  Optionally use this closure to respond to the user canceling the paysheet */

            }, onError: { error in
                print(error.error.localizedDescription)
                /* Optionally use this closure to respond to the user experiencing an error in
                 the payment experience */
            }
        )
    }
    
}


extension SelectFeaturePlanVC:UITableViewDataSource, UITableViewDelegate{
    
    //MARK:- Table view methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Plans.price.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblView.dequeueReusableCell(withIdentifier: "FeatureTblCell", for: indexPath) as! FeatureTblCell
        cell.lblHeading.text = Plans.planDuration[indexPath.row]
        cell.lblDescription.text = Plans.description[indexPath.row]
        if selectedIndex == indexPath.row{
            cell.btnCheck.setImage(UIImage(named: "blueCheck"), for: .normal)
        }else{
            cell.btnCheck.setImage(nil, for: .normal)
        }
        cell.lblPrice.text = "$ \(Plans.price[indexPath.row])"
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.type = indexPath.row + 1
        self.btnPay.setTitle("Pay $\(Plans.price[indexPath.row])", for: .normal)
        self.amount = Plans.price[indexPath.row]
        self.selectedIndex = indexPath.row
        self.tblView.reloadData()
    }
    
}

extension SelectFeaturePlanVC{
    
    func featureProduct(transactionId:String){
        var newDate = String()
        let calendar = Calendar.current
        if type == 1{
           let date = calendar.date(byAdding: .day, value: 1, to: Date())
            newDate = "\(date?.timeIntervalSince1970 ?? 1627541761)"
        }else if type == 2{
            let date = calendar.date(byAdding: .day, value: 3, to: Date())
             newDate = "\(date?.timeIntervalSince1970 ?? 1627541761)"
        }else if type == 3{
            let date = calendar.date(byAdding: .day, value: 7, to: Date())
             newDate = "\(date?.timeIntervalSince1970 ?? 1627541761)"
        }else{
            let date = calendar.date(byAdding: .day, value: 14, to: Date())
             newDate = "\(date?.timeIntervalSince1970 ?? 1627541761)"
        }
        let params = ["isFeatured":type,"featuredUpto":newDate,"product_id":self.productId,"transaction_id":"\(transactionId)","payment_status":"success","amount":amount] as [String : Any]
        RVApiManager.putAPI(Apis.featureProduct, parameters: params, Vc: self, showLoader: true) { (data: PostAd) in
            if let success =  data.success{
                if success{
                    if self.type == 1{
                        Helper.showOKAlertWithCompletion(onVC: self, title: "Payment Successfull", message: "Your post will be featured for 3 Days to reach more customers!!!", btnOkTitle: "OK") {
                            if self.isFromEdit{
                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
                                vc.isFromEdit = true
                                self.navigationController?.pushViewController(vc, animated: true)
                            }else{
                                self.tabBarController?.selectedIndex = 0
                            }
                        }
                    }else if self.type == 2{
                        Helper.showOKAlertWithCompletion(onVC: self, title: "Payment Successfull", message: "Your post will be featured for 1 week to reach more customers!!!", btnOkTitle: "OK") {
                            if self.isFromEdit{
                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
                                vc.isFromEdit = true
                                self.navigationController?.pushViewController(vc, animated: true)
                            }else{
                                self.tabBarController?.selectedIndex = 0
                            }                        }
                    }else{
                        Helper.showOKAlertWithCompletion(onVC: self, title: "Payment Successfull", message: "Your post will be featured for 2 weeks to reach more customers!!!", btnOkTitle: "OK") {
                            if self.isFromEdit{
                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
                                vc.isFromEdit = true
                                self.navigationController?.pushViewController(vc, animated: true)
                            }else{
                                self.tabBarController?.selectedIndex = 0
                            }
                        }
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

