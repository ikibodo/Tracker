//
//  Tracker.swift
//  Tracker
//
//  Created by N L on 5.1.25..
//
import Foundation
import UIKit

struct Tracker {
    let id: UUID
    let title: String
    let color: UIColor
    let emoji: String
    let schedule: [WeekDay?]
}
//    init(id: UUID = UUID(),
//             title: String,
//             color: UIColor,
//             emoji: String,
//             schedule: [WeekDay?]) {
//            self.id = id
//            self.title =  title.isEmpty ? "Поливать растения" : title
//            self.color = color
//            self.emoji = emoji.isEmpty ? "❤️" : emoji
//            self.schedule = schedule
//        }

