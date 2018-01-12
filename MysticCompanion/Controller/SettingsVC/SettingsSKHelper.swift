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
    func buyProduct(productID: String) {
        for product in productList {
            let productToCheck = product.productIdentifier
            if productToCheck == productID {
                productPurchasing = product
                
                NetworkIndicator.networkOperationStarted()
                
                let pay = SKPayment(product: productPurchasing)
                SKPaymentQueue.default().add(self)
                SKPaymentQueue.default().add(pay)
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
            showAlert(.iapDisabled)
        }
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        NetworkIndicator.networkOperationStarted()
        
        let myProducts = response.products
        for product in myProducts {
            productList.append(product)
        }
        
        purchaseButtonsAreEnabled = true
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
        showAlert(.purchasesRestored)
        NetworkIndicator.networkOperationFinished()
        shouldPresentLoadingView(false)
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        showAlert(.restoreFailed)
        NetworkIndicator.networkOperationFinished()
        shouldPresentLoadingView(false)
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
                default: break
                }
                shouldPresentLoadingView(false)
                showAlert(.purchaseComplete)
                queue.finishTransaction(trans)
            case .failed:
                shouldPresentLoadingView(false)
                showAlert(.purchaseFailed)
                queue.finishTransaction(trans)
            default: break
            }
        }
        
        NetworkIndicator.networkOperationFinished()
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]) {
        shouldPresentLoadingView(false)
    }
}
