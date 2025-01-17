//
//  UserDefaultsManager.swift
//  Lingo Widget
//
//  Created by Oguz Doruk on 17.01.2025.
//

import Foundation

final class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    private let defaults = UserDefaults.standard
    
    private let kIsPremiumUser = "isPremiumUser"
    
    private init() {}
    
    // Get current premium status
    var isPremiumUser: Bool {
        get { defaults.bool(forKey: kIsPremiumUser) }
        set { defaults.set(newValue, forKey: kIsPremiumUser) }
    }
    
    // Update premium status and post notification
    func updatePremiumStatus(_ status: Bool) {
        isPremiumUser = status
        NotificationCenterManager.shared.postPremiumStatusChanged(status)
    }
}
