//
//  SettingsSKHelper.swift
//  MysticCompanion
//
//  Created by Michael Craun on 11/30/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import UIKit
import StoreKit

extension SettingsVC: Alertable, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    //TODO: StoreKit Functionality
    func buyProduct(productID: String) {
        for product in productList {
            let productToCheck = product.productIdentifier
            if productToCheck == productID {
                productPurchasing = product
                
                NetworkIndicator.networkOperationStarted()
                
                let pay = SKPayment(product: productPurchasing)
                SKPaymentQueue.default().add(self)
                SKPaymentQueue.default().add(pay)
                
                NetworkIndicator.networkOperationFinished()
//                shouldPresentLoadingView(false)
            }
        }
    }
    
    func checkCanMakePayments() {
        if (SKPaymentQueue.canMakePayments()) {
            let productIDs: NSSet = NSSet(objects: Products.premiumUpgrade.productIdentifier)
            let request: SKProductsRequest = SKProductsRequest(productIdentifiers: productIDs as! Set<String>)
            request.delegate = self
            request.start()
        } else {
            showAlert(withTitle: "In-App Purchases Diabled.", andMessage: "Please enable in-app purchases to access the full features of this app.")
        }
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        NetworkIndicator.networkOperationStarted()
        
        let myProducts = response.products
        for product in myProducts {
            productList.append(product)
        }
        
        NetworkIndicator.networkOperationFinished()
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
                layoutView()
            default: break
            }
        }
//        shouldPresentLoadingView(false)
        showAlert(withTitle: "Purchases Restored", andMessage: "Your purchases have been restored. Thank you.")
        NetworkIndicator.networkOperationFinished()
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        NetworkIndicator.networkOperationStarted()
        
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
                    layoutView()
                default: break
                }
                showAlert(withTitle: "Purchase Complete", andMessage: "Thank you for purchasing!")
                queue.finishTransaction(trans)
            case .failed:
                showAlert(withTitle: "Transaction Failed", andMessage: "Please try again later or contact support.")
                queue.finishTransaction(trans)
            default: break
            }
        }
        
//        shouldPresentLoadingView(false)
        NetworkIndicator.networkOperationFinished()
    }
}
