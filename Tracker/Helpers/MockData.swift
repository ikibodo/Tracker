//
//  Untitled.swift
//  Tracker
//
//  Created by N L on 14.1.25..
//
import Foundation
//
final class MockData {
    static var mockData: [TrackerCategory] = [
        TrackerCategory(
            title: "Домашний уют",
            trackers: [
                Tracker(id: UUID(),
                        name: "Поливать растения",
                        color: .colorSelected18,
                        emoji: "❤️",
                        schedule: [.monday, .friday]),
            ]),
        TrackerCategory(
            title: "Радостные мелочи",
            trackers: [
                Tracker(id: UUID(),
                        name: "Кошка заслонила камеру на созвоне",
                        color: .colorSelected2,
                        emoji: "😻",
                        schedule: [.monday, .tuesday,.wednesday,]),
                Tracker(id: UUID(),
                        name: "Бабушка прислала открытку в ватсапе",
                        color: .colorSelected1,
                        emoji: "🌺",
                        schedule: [.saturday, .sunday]),
                Tracker(id: UUID(),
                        name: "Свидания в апреле",
                        color: .colorSelected14,
                        emoji: "❤️",
                        schedule: [.saturday]),
            ]),
        TrackerCategory(
            title: "Самочувствие",
            trackers: [
                Tracker(id: UUID(),
                        name: "Хорошее настроение",
                        color: .colorSelected16,
                        emoji: "🙂",
                        schedule: [.tuesday, .sunday]),
                Tracker(id: UUID(),
                        name: "Легкая тревожность",
                        color: .colorSelected8,
                        emoji: "😪",
                        schedule: [.wednesday, .sunday]),
            ]),
    ]
}
