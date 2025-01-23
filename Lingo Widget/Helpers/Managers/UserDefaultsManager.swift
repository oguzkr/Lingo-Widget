//
//  UserDefaultsManager.swift
//  Lingo Widget
//
//  Created by Oguz Doruk on 17.01.2025.
//

import Foundation

final class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    private let defaults = UserDefaults(suiteName: "group.com.oguzdoruk.lingowidget")!

    private let kIsPremiumUser = "isPremiumUser"
    private let kDailyRefreshCount = "dailyRefreshCount"
    private let kDailyRefreshLimit = "dailyRefreshLimit"
    private let kLastRefreshDate = "lastRefreshDate"

    private init() {
        // Initialize daily refresh limit to 3 if not set
        if defaults.object(forKey: kDailyRefreshLimit) == nil {
            defaults.set(3, forKey: kDailyRefreshLimit)
        }
    }
    
    func string(forKey key: String) -> String? {
        return defaults.string(forKey: key)
    }
    
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
    
    
    // Get daily refresh count
    var dailyRefreshCount: Int {
        get { defaults.integer(forKey: kDailyRefreshCount) }
        set { defaults.set(newValue, forKey: kDailyRefreshCount) }
    }
    
    // Get daily refresh limit
    var dailyRefreshLimit: Int {
        get { defaults.integer(forKey: kDailyRefreshLimit) }
        set { defaults.set(newValue, forKey: kDailyRefreshLimit) }
    }
    
    var remainingRefreshCount: Int {
        return dailyRefreshLimit - dailyRefreshCount
    }
    
    // Get last refresh date
    var lastRefreshDate: Date? {
        get { defaults.object(forKey: kLastRefreshDate) as? Date }
        set { defaults.set(newValue, forKey: kLastRefreshDate) }
    }

    func increaseDailyRefreshCount() {
        dailyRefreshCount += 1
        lastRefreshDate = Date()
    }

    func shouldAllowRefresh() -> Bool {
        if isPremiumUser {
            return true
        }
        
        let calendar = Calendar.current
        let now = Date()
        
        // Reset the refresh count if it's a new day
        if let lastDate = lastRefreshDate, !calendar.isDate(lastDate, inSameDayAs: now) {
            dailyRefreshCount = 0
        }

        // Check if refresh count is below limit without incrementing
        return dailyRefreshCount < dailyRefreshLimit
    }

}
