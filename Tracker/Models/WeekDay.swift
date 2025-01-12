//
//  Untitled.swift
//  Tracker
//
//  Created by N L on 6.1.25..
//
import Foundation

enum WeekDay: String, CaseIterable {
    case monday = "Понедельник"
    case tuesday = "Вторник"
    case wednesday = "Среда"
    case thursday = "Четверг"
    case friday = "Пятница"
    case saturday = "Суббота"
    case sunday = "Воскресенье"
    
    // Метод для получения WeekDay по индексу (1 - Понедельник, 7 - Воскресенье)
    static func from(weekdayIndex: Int) -> WeekDay? {
        switch weekdayIndex {
        case 1: return .sunday
        case 2: return .monday
        case 3: return .tuesday
        case 4: return .wednesday
        case 5: return .thursday
        case 6: return .friday
        case 7: return .saturday
        default: return nil
        }
    }
}
