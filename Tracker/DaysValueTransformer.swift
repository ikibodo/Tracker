//
//  DaysValueTransformer.swift
//  Tracker
//
//  Created by N L on 25.1.25..
//
import Foundation

@objc
final class DaysValueTransformer: ValueTransformer {
    override class func transformedValueClass() -> AnyClass { NSData.self }
    override class func allowsReverseTransformation() -> Bool { true }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let days = value as? [WeekDay] else {
            print("Invalid value: \(String(describing: value))")
            return nil
        }
        return try? JSONEncoder().encode(days)
//        guard let schedule = value as? [String] else { return nil }
//        // Преобразуем массив строк в строку (например, через запятую)
//        return schedule.joined(separator: ",")
//        guard let schedule = value as? [String], !schedule.isEmpty else {
//            // Если расписания нет или оно пустое, возвращаем nil (или пустую строку)
//            return nil // или можно вернуть пустую строку ""
//        }
//        // Преобразуем массив строк в строку (например, через запятую)
//        return schedule.joined(separator: ",")
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? NSData else { return nil }
        return try? JSONDecoder().decode([WeekDay].self, from: data as Data)
//        guard let scheduleString = value as? String else { return nil }
        // Преобразуем строку обратно в массив строк
//        return scheduleString.split(separator: ",").map { String($0) }
//        guard let scheduleString = value as? String, !scheduleString.isEmpty else {
//            // Если строка пустая, возвращаем пустой массив
//            return []
//        }
//        // Преобразуем строку обратно в массив строк
//        return scheduleString.split(separator: ",").map { String($0) }
    }
    
    static func register() {
        ValueTransformer.setValueTransformer(
            DaysValueTransformer(),
            forName: NSValueTransformerName(rawValue: String(describing: DaysValueTransformer.self))
        )
    }
}
