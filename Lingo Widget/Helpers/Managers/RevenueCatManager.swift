//
//  RevenueCatManager.swift
//  Lingo Widget
//
//  Created by Oguz Doruk on 14.01.2025.
//

import Foundation
import RevenueCat

class RevenueCatManager: NSObject, PurchasesDelegate {
    
    static let shared = RevenueCatManager()
    
    private let notificationCenterManager = NotificationCenterManager.shared
    private let userDefaultsManager = UserDefaultsManager.shared
    
    private override init() {
        super.init()
        Purchases.configure(withAPIKey: "appl_cVTqIGKVQFNoZBpbeXxrdBkZeKr")
        Purchases.logLevel = .error
        Purchases.shared.delegate = self
    }
    
    func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        let hasPro = customerInfo.entitlements["pro"]?.isActive == true
        print("******* USER PREMIUM STATUS UPDATED START *******")
        userDefaultsManager.updatePremiumStatus(hasPro)
        notificationCenterManager.postPremiumStatusChanged(hasPro)
        print("Updated user premium status: \(hasPro)")
        print("******* USER PREMIUM STATUS UPDATED END *******")
    }
    
    func restorePurchase(completion: @escaping (Bool) -> Void) {
        Purchases.shared.restorePurchases { [weak self] (purchaserInfo, error) in
            guard let self = self else { return }
            
            if let purchaserInfo = purchaserInfo {
                let hasPro = purchaserInfo.entitlements["pro"]?.isActive == true
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
    
    func checkProEntitlement(completion: @escaping (Bool) -> Void) {
        Purchases.shared.getCustomerInfo { [weak self] (customerInfo, error) in
            guard let self = self else { return }
            
            if let customerInfo = customerInfo {
                let hasPro = customerInfo.entitlements["pro"]?.isActive == true
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
    
    func checkTrialEligibility(completion: @escaping (Bool) -> Void) {
        let productIdentifiers = ["lingo_a", "prtracker_1y"]
        
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
}
