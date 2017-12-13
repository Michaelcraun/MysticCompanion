//
//  SKHelper.swift
//  MysticCompanion
//
//  Created by Michael Craun on 12/12/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import Foundation
import StoreKit

protocol SKHelperDelegate {
    var productPurchasing: SKProduct { get set }
    var productList: [SKProduct] { get set }
}

extension SKHelperDelegate where Self: SKProductsRequestDelegate {
    func checkCanMakePayments() {
        if (SKPaymentQueue.canMakePayments()) {
            let productIDs: NSSet = NSSet(objects: Products.premiumUpgrade.productIdentifier)
            let request: SKProductsRequest = SKProductsRequest(productIdentifiers: productIDs as! Set<String>)
            request.delegate = self
            request.start()
        } else {
            print("Please enable in-app purchases to access the full features of this app.")
//            let iapAlert = UIAlertController(title: "IAP Disabled", message: "Please enable in-app purchases to access the full features of this app.", preferredStyle: .alert)
//            iapAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//            self.present(iapAlert, animated: true, completion: nil)
//            self.showAlert("Please enable in-app purchases to access the full features of this app.")
        }
    }
    
    mutating func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
//        NetworkIndicator.networkOperationStarted()
        
        let myProducts = response.products
        for product in myProducts { productList.append(product) }
        
//        purchaseBtn.isEnabled = true
//        restoreBtn.isEnabled = true
        
//        NetworkIndicator.networkOperationFinished()
    }
}

extension SKHelperDelegate where Self: SKPaymentTransactionObserver {
    mutating func buyProduct(productID: String) {
        for product in productList {
            let productToCheck = product.productIdentifier
            if productToCheck == productID {
                productPurchasing = product
//                NetworkIndicator.networkOperationStarted()
                let pay = SKPayment(product: productPurchasing)
                SKPaymentQueue.default().add(self)
                SKPaymentQueue.default().add(pay)
//                NetworkIndicator.networkOperationFinished()
            }
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        for transaction in queue.transactions {
            let t: SKPaymentTransaction = transaction
            let productID = t.payment.productIdentifier
            switch productID {
            case Products.premiumUpgrade.productIdentifier:
                let defaults = UserDefaults.standard
                PREMIUM_PURCHASED = true
                defaults.set(PREMIUM_PURCHASED, forKey: "premium")
//                initialSetup()
            default: break
            }
        }
        print("Your purchases have been restored. Thank you.")
//        let restoreAlert = UIAlertController(title: "Purchases Restored", message: "Your purchases have been restored. Thank you.", preferredStyle: .alert)
//        restoreAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//        self.present(restoreAlert, animated: true, completion: nil)
        
//        NetworkIndicator.networkOperationFinished()
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
//        NetworkIndicator.networkOperationStarted()
        
        for transaction: AnyObject in transactions {
            let trans = transaction as! SKPaymentTransaction
            switch trans.transactionState {
            case .purchased:
                let productID = productPurchasing.productIdentifier
                
                switch productID {
                case Products.premiumUpgrade.productIdentifier:
                    let defaults = UserDefaults.standard
                    PREMIUM_PURCHASED = true
                    defaults.set(PREMIUM_PURCHASED, forKey: "premium")
//                    initialSetup()
                default: break
                }
                print("Thank you for purchasing!")
//                let purchaseAlert = UIAlertController(title: "Purchase Complete", message: "Thank you for purchasing!", preferredStyle: .alert)
//                purchaseAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//                self.present(purchaseAlert, animated: true, completion: nil)
                queue.finishTransaction(trans)
            case .failed:
                print("Transaction failed. Please try again later or contact support.")
//                let failedAlert = UIAlertController(title: "Transaction Failed", message: "Transaction failed. Please try again later or contact support.", preferredStyle: .alert)
//                failedAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//                self.present(failedAlert, animated: true, completion: nil)
                queue.finishTransaction(trans)
            default: break
            }
        }
        
//        NetworkIndicator.networkOperationFinished()
    }
}
