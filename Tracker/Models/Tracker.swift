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
    var title: String
    let color: UIColor
    let emoji: String
//    let schedule: [WeekDay]
    let schedule: Set<WeekDay>
}
