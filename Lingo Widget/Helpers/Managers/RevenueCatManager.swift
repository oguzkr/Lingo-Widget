//
//  RevenueCatManager.swift
//  Lingo Widget
//
//  Created by Oguz Doruk on 14.01.2025.
//

import Foundation
import RevenueCat

class RevenueCatManager: NSObject, PurchasesDelegate {
    
    // MARK: - Properties
    static let shared = RevenueCatManager()
    
    private let notificationCenterManager = NotificationCenterManager.shared
    private let userDefaultsManager = UserDefaultsManager.shared
    
    // Product Identifiers
    private let monthlyIdentifier = "lingo_m"
    private let annualIdentifier = "lingo_a"
    private let lifetimeIdentifier = "com.oguzkr.lingowidget.lifetime"
    
    // MARK: - Initialization
    private override init() {
        super.init()
        Purchases.configure(withAPIKey: "appl_cVTqIGKVQFNoZBpbeXxrdBkZeKr")
        Purchases.logLevel = .error
        Purchases.shared.delegate = self
    }
    
    var isPremiumUser: Bool {
        return userDefaultsManager.isPremiumUser
    }
    
    // MARK: - Delegate Methods
    func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        let hasSubscription = customerInfo.entitlements["pro"]?.isActive == true
        let hasLifetime = customerInfo.nonSubscriptions.contains {
            $0.productIdentifier == lifetimeIdentifier
        }
        
        let hasPro = hasSubscription || hasLifetime
        
        print("******* USER PREMIUM STATUS UPDATED START *******")
        userDefaultsManager.updatePremiumStatus(hasPro)
        notificationCenterManager.postPremiumStatusChanged(hasPro)
        print("Updated user premium status: \(hasPro)")
        print("******* USER PREMIUM STATUS UPDATED END *******")
    }
    
    // MARK: - Purchase Management
    
    /// Restore previous purchases
    func restorePurchase(completion: @escaping (Bool) -> Void) {
        Purchases.shared.restorePurchases { [weak self] (purchaserInfo, error) in
            guard let self = self else { return }
            
            if let purchaserInfo = purchaserInfo {
                let hasSubscription = purchaserInfo.entitlements["pro"]?.isActive == true
                let hasLifetime = purchaserInfo.nonSubscriptions.contains {
                    $0.productIdentifier == self.lifetimeIdentifier
                }
                
                let hasPro = hasSubscription || hasLifetime
                self.userDefaultsManager.updatePremiumStatus(hasPro)
                self.notificationCenterManager.postPremiumStatusChanged(hasPro)
                completion(hasPro)
            } else {
                print("Error restoring purchase: \(error?.localizedDescription ?? "Unknown error")")
                self.userDefaultsManager.updatePremiumStatus(false)
                self.notificationCenterManager.postPremiumStatusChanged(false)
                completion(false)
            }
        }
    }
    
    /// Check if user has pro entitlement
    func checkProEntitlement(completion: @escaping (Bool) -> Void) {
        Purchases.shared.getCustomerInfo { [weak self] (customerInfo, error) in
            guard let self = self else { return }
            
            if let customerInfo = customerInfo {
                let hasSubscription = customerInfo.entitlements["pro"]?.isActive == true
                let hasLifetime = customerInfo.nonSubscriptions.contains {
                    $0.productIdentifier == self.lifetimeIdentifier
                }
                
                let hasPro = hasSubscription || hasLifetime
                self.userDefaultsManager.updatePremiumStatus(hasPro)
                self.notificationCenterManager.postPremiumStatusChanged(hasPro)
                completion(hasPro)
            } else {
                print("Error retrieving customer info: \(error?.localizedDescription ?? "Unknown error")")
                self.userDefaultsManager.updatePremiumStatus(false)
                self.notificationCenterManager.postPremiumStatusChanged(false)
                completion(false)
            }
        }
    }
    
    /// Apply promo code
    func applyPromoCode(completion: @escaping (Bool, String?) -> Void) {
        Purchases.shared.presentCodeRedemptionSheet()
        restorePurchase { success in
            if success {
                completion(true, nil)
            } else {
                completion(false, "Failed to apply promo code. Please try again later.")
            }
        }
    }
    
    /// Check trial eligibility
    func checkTrialEligibility(completion: @escaping (Bool) -> Void) {
        let productIdentifiers = [monthlyIdentifier, annualIdentifier]
        
        Purchases.shared.getCustomerInfo { [weak self] customerInfo, error in
            guard let self = self else { return }
            
            if let customerInfo = customerInfo {
                let activeSubscriptions = customerInfo.activeSubscriptions
                if !activeSubscriptions.isEmpty {
                    print("User already has an active subscription")
                    self.userDefaultsManager.updatePremiumStatus(true)
                    self.notificationCenterManager.postPremiumStatusChanged(true)
                    completion(false)
                    return
                }
                
                // Check if user has lifetime purchase
                let hasLifetime = customerInfo.nonSubscriptions.contains {
                    $0.productIdentifier == self.lifetimeIdentifier
                }
                
                if hasLifetime {
                    print("User has lifetime access")
                    self.userDefaultsManager.updatePremiumStatus(true)
                    self.notificationCenterManager.postPremiumStatusChanged(true)
                    completion(false)
                    return
                }
                
                // Check trial eligibility
                Purchases.shared.checkTrialOrIntroDiscountEligibility(productIdentifiers: productIdentifiers) { eligibility in
                    for identifier in productIdentifiers {
                        if let productEligibility = eligibility[identifier], productEligibility.status == .eligible {
                            print("User is eligible for trial offer on product: \(identifier)")
                            completion(true)
                            return
                        }
                    }
                    print("User is not eligible for any trial offers")
                    completion(false)
                }
            } else {
                print("Error fetching customer info: \(error?.localizedDescription ?? "Unknown error")")
                self.userDefaultsManager.updatePremiumStatus(false)
                self.notificationCenterManager.postPremiumStatusChanged(false)
                completion(false)
            }
        }
    }
    
    // MARK: - Purchase Status Helpers
    
    /// Check lifetime access status
    private func hasLifetimeAccess(_ customerInfo: CustomerInfo) -> Bool {
        return customerInfo.nonSubscriptions.contains {
            $0.productIdentifier == lifetimeIdentifier
        }
    }
    
    /// Check subscription status
    private func hasActiveSubscription(_ customerInfo: CustomerInfo) -> Bool {
        return customerInfo.entitlements["pro"]?.isActive == true
    }
    
    // MARK: - Error Handling
    
    /// Log purchase error
    private func logPurchaseError(_ error: NSError) {
        print("Purchase error: \(error.localizedDescription)")
        if let info = error.userInfo["message"] as? String {
            print("Additional info: \(info)")
        }
    }
}
