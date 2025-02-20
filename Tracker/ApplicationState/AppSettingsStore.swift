//
//  Untitled.swift
//  Tracker
//
//  Created by N L on 8.2.25..
//
import Foundation

final class AppSettingsStore {
    
    private let userDefaults: UserDefaults
    private enum Keys {
        static let bestStreak = "bestStreak"
        static let perfectDays = "perfectDays"
        static let totalCompleted = "totalCompleted"
        static let averageCompleted = "averageCompleted"
    }
    
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
    
    var selectedFilter: TrackerFilterType? {
        get {
            guard let rawValue = userDefaults.string(forKey: "selectedFilter") else { return nil }
            return TrackerFilterType(rawValue: rawValue)
        }
        set {
            userDefaults.set(newValue?.rawValue, forKey: "selectedFilter")
        }
    }
    
    func saveStatistics(bestStreak: Int, perfectDays: Int, totalCompleted: Int, averageCompleted: Int) {
        userDefaults.set(bestStreak, forKey: Keys.bestStreak)
        userDefaults.set(perfectDays, forKey: Keys.perfectDays)
        userDefaults.set(totalCompleted, forKey: Keys.totalCompleted)
        userDefaults.set(averageCompleted, forKey: Keys.averageCompleted)
    }
    
    func loadStatistics() -> (bestStreak: Int, perfectDays: Int, totalCompleted: Int, averageCompleted: Int) {
        let bestStreak = userDefaults.integer(forKey: Keys.bestStreak)
        let perfectDays = userDefaults.integer(forKey: Keys.perfectDays)
        let totalCompleted = userDefaults.integer(forKey: Keys.totalCompleted)
        let averageCompleted = userDefaults.integer(forKey: Keys.averageCompleted)
        return (bestStreak, perfectDays, totalCompleted, averageCompleted)
    }
}
