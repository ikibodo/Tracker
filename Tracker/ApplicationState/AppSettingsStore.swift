//
//  Untitled.swift
//  Tracker
//
//  Created by N L on 8.2.25..
//
import Foundation

final class AppSettingsStore {
    
    private let userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    var hasSeenOnboarding: Bool {
        get {
            return userDefaults.bool(forKey: "hasSeenOnboarding")
        }
        set {
            userDefaults.set(newValue, forKey: "hasSeenOnboarding")
        }
    }
}
