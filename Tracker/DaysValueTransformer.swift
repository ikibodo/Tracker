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
        print("DaysValueTransformer - Начальное значение \(String(describing: value))")
        guard let days = value as? [WeekDay] else {
            print("DaysValueTransformer - возвращаю без трансформации значение value: \(String(describing: value))")
            return value
        }
        print("DaysValueTransformer: Переменная расписание \(days)" )
        do {
             let encodedData = try JSONEncoder().encode(days)
            print("DaysValueTransformer - Сереализованные данные: \(encodedData)" )
             return encodedData
         } catch {
             print("DaysValueTransformer - Ошибка кодирования: \(error)")
             return nil
         }
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        print("DaysValueTransformer reverse - Тип value из CoreData:", type(of: value))
        guard let data = value as? NSData else {
            print("Ошибка: scheduleData не NSData - возвращаю без декодирования значение value")
            return value
        }
        if let jsonString = String(data: data as Data, encoding: .utf8) {
              print("DaysValueTransformer reverse - JSON перед декодированием:", jsonString)
          } else {
              print("DaysValueTransformer reverse: ошибка - не удалось преобразовать в строку")
          }
        do {
            let decodedDays = try JSONDecoder().decode([WeekDay].self, from: data as Data)
            print("DaysValueTransformer reverse - Декодированные дни:", decodedDays)
            return decodedDays
        } catch {
            print("DaysValueTransformer reverse - Ошибка декодирования: \(error)")
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
