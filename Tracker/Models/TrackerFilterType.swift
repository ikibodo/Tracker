//
//  Untitled.swift
//  Tracker
//
//  Created by N L on 17.2.25..
//
import Foundation

enum TrackerFilterType: String, CaseIterable {
    case allTrackers = "Все трекеры"
    case trackersToday = "Трекеры на сегодня"
    case completed = "Завершённые"
    case notCompleted = "Незавершённые"
    
    static func from(rawValue: String) -> TrackerFilterType? {
        return TrackerFilterType(rawValue: rawValue)
    }
}
