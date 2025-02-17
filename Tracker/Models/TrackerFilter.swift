//
//  Untitled.swift
//  Tracker
//
//  Created by N L on 17.2.25..
//
import Foundation

enum TrackerFilter: String, CaseIterable {
    case allTrackers = "Все трекеры"
    case trackersToday = "Трекеры на сегодня"
    case completed = "Завершённые"
    case notCompleted = "Незавершённые"
    
    static func from(rawValue: String) -> TrackerFilter? {
        return TrackerFilter(rawValue: rawValue)
    }
}
