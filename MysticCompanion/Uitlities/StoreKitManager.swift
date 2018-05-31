//
//  Products.swift
//  MysticCompanion
//
//  Created by Michael Craun on 12/12/17.
//  Copyright © 2017 Craunic Productions. All rights reserved.
//

import Foundation
import StoreKit

class StoreKitManager: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    /// The UIViewController StoreKitDelegate belongs to
    var delegate: UIViewController!
    
    /// A list of your productIdentifiers. Automatically executes checkCanMakePayments() on didSet
    var productIdentifiers = [String]() {
        didSet {
            checkCanMakePayments()
            startProductRequest()
        }
    }
    
    //MARK: StoreKit variables for storing data
    private let defaults = UserDefaults.standard
    private var canMakePayments = false
    private var productList = [SKProduct]()
    private var productPurchasing = SKProduct()
    
    /// Used to determine if user has purchased a "premium version" by checking UserDefaults for Bool "isPremium" key.
    func checkForPremium() -> Bool {
        let isPremium = defaults.bool(forKey: "premium")
        return isPremium
    }
    
    /// Checks if user can make payments and begins product request. Purchase buttons should be disabled before called
    /// to prevent crashes and productsRequest(_:didReceive:) should be modified to re-enable buttons upon success
    func checkCanMakePayments() {
        if !canMakePayments {
            if (SKPaymentQueue.canMakePayments()) {
                canMakePayments = true
            }
        }
    }
    
    private func startProductRequest() {
        let productIDs = NSSet(array: productIdentifiers)
        let request: SKProductsRequest = SKProductsRequest(productIdentifiers: productIDs as! Set<String>)
        
        request.delegate = self
        request.start()
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let myProducts = response.products
        for product in myProducts {
            productList.append(product)
        }
        
        //TODO: Purchase buttons should be re-enabled when product list has finished loading.
        guard let settingsVC = delegate as? SettingsVC else {
            print("IAP: unable to find settingsVC...")
            return
        }
        
        settingsVC.purchaseButtonsAreEnabled = true
    }
    
    /// Presents a loading indicator to prevent user-caused crashes and starts purchase request
    func buyProduct(_ productID: String) {
        delegate.presentLoadingScreen(true)
        for product in productList {
            let productToCheck = product.productIdentifier
            if productToCheck == productID {
                productPurchasing = product
                let pay = SKPayment(product: productPurchasing)
                
                SKPaymentQueue.default().add(self)
                SKPaymentQueue.default().add(pay)
            }
        }
    }
    
    /// Presents a loading indicator to prevent user-caused crashes and starts restore request
    func restoreProducts() {
        delegate.presentLoadingScreen(true)
        
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    //MARK: Begins purchase request
    internal func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                let productID = productPurchasing.productIdentifier
                finishPurchase(withIdentifier: productID)
                queue.finishTransaction(transaction)
            case .failed:
                queue.finishTransaction(transaction)
            default: break
            }
        }
    }
    
    //MARK: Finished purchasing product with no errors.
    internal func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        for transaction in queue.transactions {
            let productID = transaction.payment.productIdentifier
            switch transaction.transactionState {
            case .purchased:
                finishPurchase(withIdentifier: productID)
            case .restored:
                finishPurchase(withIdentifier: productID)
            default: break
            }
        }
        delegate.showPurchaseAlert(.restoreComplete)
        delegate.presentLoadingScreen(false)
    }
    
    //MARK: Finished purchasing product with error.
    internal func paymentQueue(_ queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .failed: delegate.showPurchaseAlert(.purchaseFailed)
            default: break
            }
            queue.finishTransaction(transaction)
        }
        delegate.presentLoadingScreen(false)
    }
    
    //MARK: Finished restoring products with error.
    internal func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        delegate.showPurchaseAlert(.restoreFailed)
        delegate.presentLoadingScreen(false)
    }
    
    /// Used to finish purchases and exectue whatever commands are necessary. Should be modified to fit your needs
    func finishPurchase(withIdentifier identifier: String) {
        //TODO: Should switch on your own productIdentifiers and execute whatever commands are neccessary.
        switch identifier {
        case Products.premiumUpgrade.rawValue:
            defaults.set(true, forKey: "premium")
            PREMIUM_PURCHASED = checkForPremium()
        default: break
        }
    }
    
    /// Used to ask user for rating after this method is called 10 times. It is recommended this method be called
    /// in viewDidLoad(_:) of your main UIViewController (otherwise it gets severely annoying to the user).
    func askForRating() {
        var timesAppOpened = defaults.integer(forKey: "timesAppOpened")
        
        if timesAppOpened >= 10 {
            SKStoreReviewController.requestReview()
            timesAppOpened = 0
        } else {
            timesAppOpened += 1
        }
        
        defaults.set(timesAppOpened, forKey: "timesAppOpened")
    }
}

fileprivate enum PurchaseAlert {
    case purchaseFailed
    case restoreComplete
    case restoreFailed
    
    var title: String {
        switch self {
        case .purchaseFailed: return "Purchase Failed"
        case .restoreComplete: return "Restore Successful"
        case .restoreFailed: return "Resotre Failed"
        }
    }
    
    var message: String {
        switch self {
        case .purchaseFailed: return "Your purchase has failed. Please try again."
        case .restoreComplete: return "Restoring your purchases was successful. Thank you."
        case .restoreFailed: return "Restoring your purchases has failed. Please try again."
        }
    }
}

fileprivate extension UIViewController {
    func presentLoadingScreen(_ status: Bool) {
        var fadeView: UIView?
        
        if status == true {
            fadeView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
            fadeView?.backgroundColor = .black
            fadeView?.alpha = 0
            fadeView?.tag = 5050
            
            let spinner = UIActivityIndicatorView()
            spinner.color = .white
            spinner.activityIndicatorViewStyle = .whiteLarge
            spinner.center = (fadeView?.center)!
            
            view.addSubview(fadeView!)
            fadeView?.addSubview(spinner)
            
            spinner.startAnimating()
            fadeView?.fadeAlphaTo(0.7, withDuration: 0.2)
        } else {
            for subview in view.subviews {
                if subview.tag == 5050 {
                    UIView.animate(withDuration: 0.2, animations: {
                        subview.alpha = 0
                    }, completion: { (finished) in
                        subview.removeFromSuperview()
                    })
                }
            }
        }
    }
    
    func showPurchaseAlert(_ alert: PurchaseAlert) {
        view.addBlurEffect()
        
        let alertController = UIAlertController(title: alert.title, message: alert.message, preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .default) { (action) in
            self.dismissAlert()
        }
        
        alertController.addAction(defaultAction)
        present(alertController, animated: false, completion: nil)
    }
    
    func dismissAlert() {
        for subview in self.view.subviews {
            if subview.tag == 1001 {
                subview.fadeAlphaOut()
            }
        }
    }
}

fileprivate extension UIView {
    func addBlurrEffect() {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = UIScreen.main.bounds
        blurEffectView.tag = 1001
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.addSubview(blurEffectView)
    }
    
    func fadeAlphaTo(_ alpha: CGFloat, withDuration duration: TimeInterval) {
        UIView.animate(withDuration: duration) {
            self.alpha = alpha
        }
    }
}


/// An enumeration of products available in the app
enum Products: String {
    case premiumUpgrade = "com.CraunicProductions.MysticCompanion.PremiumUpgrade"
}
