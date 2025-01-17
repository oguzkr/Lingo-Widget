//
//  NotificationCenterManager.swift
//  Lingo Widget
//
//  Created by Oguz Doruk on 17.01.2025.
//

import Foundation

final class NotificationCenterManager {
    static let shared = NotificationCenterManager()
    private let notificationCenter = NotificationCenter.default
    
    // Notification names
    static let premiumStatusChanged = Notification.Name("premiumStatusChanged")
    
    private init() {}
    
    // Post premium status change notification
    func postPremiumStatusChanged(_ status: Bool) {
        notificationCenter.post(
            name: NotificationCenterManager.premiumStatusChanged,
            object: nil,
            userInfo: ["isPremium": status]
        )
    }
    
    // Add observer for premium status changes
    func addPremiumStatusObserver(_ observer: Any, selector: Selector) {
        notificationCenter.addObserver(
            observer,
            selector: selector,
            name: NotificationCenterManager.premiumStatusChanged,
            object: nil
        )
    }
    
    // Remove observer
    func removePremiumStatusObserver(_ observer: Any) {
        notificationCenter.removeObserver(
            observer,
            name: NotificationCenterManager.premiumStatusChanged,
            object: nil
        )
    }
    
    // Remove all observers (call this when cleaning up)
    func removeAllObservers(_ observer: Any) {
        notificationCenter.removeObserver(observer)
    }
}

/* 
 USAGE EXAMPLE IN VIEW CONTROLLERS / VIEWS:
 
 // 1. Subscribe to premium status changes
 class MyViewController {
     override func viewDidLoad() {
         super.viewDidLoad()
         NotificationCenterManager.shared.addPremiumStatusObserver(
             self,
             selector: #selector(handlePremiumStatusChange)
         )
     }
     
     @objc private func handlePremiumStatusChange(_ notification: Notification) {
         if let isPremium = notification.userInfo?["isPremium"] as? Bool {
             // Handle premium status change
             // Example: Update UI, enable/disable features
             if isPremium {
                 enablePremiumFeatures()
             } else {
                 disablePremiumFeatures()
             }
         }
     }
     
     // 2. IMPORTANT: Always remove observer when the view/controller is deallocated
     deinit {
         NotificationCenterManager.shared.removePremiumStatusObserver(self)
         // or if you have multiple observers:
         // NotificationCenterManager.shared.removeAllObservers(self)
     }
 }
 
 // 3. Integration with RevenueCatManager
 // In your purchase completion handler:
 RevenueCatManager.shared.checkProEntitlement { hasPro in
     UserDefaultsManager.shared.updatePremiumStatus(hasPro)
 }
 
 // 4. For SwiftUI views, you can use onReceive:
 struct MyView: View {
     var body: some View {
         ContentView()
             .onReceive(NotificationCenter.default.publisher(
                 for: NotificationCenterManager.premiumStatusChanged
             )) { notification in
                 if let isPremium = notification.userInfo?["isPremium"] as? Bool {
                     // Handle premium status change
                 }
             }
     }
 }
*/
