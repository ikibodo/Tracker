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
        print("DVT - Начальное значение \(String(describing: value))")
        
        guard let days = value as? [WeekDay?] else {
            print("DVT - Возвращаю nil так как не подходящее значение value: \(String(describing: value))")
            return nil
        }
        let filteredDays = days.compactMap { $0 }
        
        if filteredDays.isEmpty {
        } else {
            print("DVT - массив не пуст, сохраняем данные.")
        }
        
        do {
            let encodedData = try JSONEncoder().encode(filteredDays) as NSData
            return encodedData as NSData
        } catch {
            print("DVT - Ошибка кодирования: \(error)")
            return nil
        }
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? NSData else {
            print("DVT - Ошибка: scheduleData не NSData - возвращаю nil")
            return nil
        }
        if let jsonString = String(data: data as Data, encoding: .utf8) {
        } else {
            print("DVT - Ошибка: не удалось преобразовать в строку")
        }
        do {
            let decodedDays = try JSONDecoder().decode([WeekDay].self, from: data as Data)
            return decodedDays
        } catch {
            print("DVT - Ошибка декодирования: \(error)")
            return nil
        }
    }
    
    static func register() {
        ValueTransformer.setValueTransformer(
            DaysValueTransformer(),
            forName: NSValueTransformerName(rawValue: String(describing: DaysValueTransformer.self))
        )
    }
}
