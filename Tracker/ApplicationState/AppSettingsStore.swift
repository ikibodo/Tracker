//
//  Untitled.swift
//  Tracker
//
//  Created by N L on 8.2.25..
//
import Foundation

final class AppSettingsStore {
    static let shared = AppSettingsStore()
    
    private let userDefaults: UserDefaults
    
    private enum Key: String {
        case bestStreak
        case perfectDays
        case totalCompleted
        case averageCompleted
        case hasSeenOnboarding
        case selectedFilter
    }
    
    private init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    var hasSeenOnboarding: Bool {
        get {
            return userDefaults.bool(forKey: Key.hasSeenOnboarding.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Key.hasSeenOnboarding.rawValue)
        }
    }
    
    var selectedFilter: TrackerFilterType? {
        get {
            guard let rawValue = userDefaults.string(forKey: Key.selectedFilter.rawValue) else { return nil }
            return TrackerFilterType(rawValue: rawValue)
        }
        set {
            userDefaults.set(newValue?.rawValue, forKey: Key.selectedFilter.rawValue)
        }
    }
    
    func saveStatistics(bestStreak: Int, perfectDays: Int, totalCompleted: Int, averageCompleted: Int) {
        userDefaults.set(bestStreak, forKey: Key.bestStreak.rawValue)
        userDefaults.set(perfectDays, forKey: Key.perfectDays.rawValue)
        userDefaults.set(totalCompleted, forKey: Key.totalCompleted.rawValue)
        userDefaults.set(averageCompleted, forKey: Key.averageCompleted.rawValue)
    }
    
    func loadStatistics() -> (bestStreak: Int, perfectDays: Int, totalCompleted: Int, averageCompleted: Int) {
        let bestStreak = userDefaults.integer(forKey: Key.bestStreak.rawValue)
        let perfectDays = userDefaults.integer(forKey: Key.perfectDays.rawValue)
        let totalCompleted = userDefaults.integer(forKey: Key.totalCompleted.rawValue)
        let averageCompleted = userDefaults.integer(forKey: Key.averageCompleted.rawValue)
        return (bestStreak, perfectDays, totalCompleted, averageCompleted)
    }
}
