//
//  Untitled.swift
//  Tracker
//
//  Created by N L on 24.1.25..
//
import Foundation
import UIKit
import CoreData

final class TrackerStore: NSObject {
    private let context: NSManagedObjectContext
    
    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
}
