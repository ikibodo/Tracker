//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by N L on 24.1.25..
// 
import UIKit
import CoreData

final class TrackerRecordStore: NSObject, NSFetchedResultsControllerDelegate {
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData>?
    
    convenience override init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("AppDelegate could not be cast to expected type.")
        }
        let context = appDelegate.persistentContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        setupFetchedResultsController()
    }

    func fetchAllRecords() throws -> [TrackerRecord] {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        let result = try context.fetch(fetchRequest)
        return result.map { convertToTrackerRecord(from: $0) }
    }

    func deleteRecord(id: UUID, date: Date) throws {
        if let record = try fetchRecord(id: id, date: date) {
            self.context.delete(record)
            self.saveContext()
        }
    }
    
    func completedDays(for id: UUID) throws -> [Date] {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        let result = try context.fetch(fetchRequest)
        let dates = result.compactMap { $0.date }
        return dates
    }
    
    func updateRecord(id: UUID, date: Date) throws {
        let calendar = Calendar.current
        let currentDateWithoutTime = calendar.startOfDay(for: Date())
        let dateWithoutTime = calendar.startOfDay(for: date)
        
        guard dateWithoutTime <= currentDateWithoutTime else {
            print("Невозможно добавить или обновить запись на будущую дату")
            return
        }
        
        if let existingRecord = try fetchRecord(id: id, date: dateWithoutTime) {
            context.delete(existingRecord)
        } else {
            let newRecord = TrackerRecordCoreData(context: context)
            newRecord.id = id
            newRecord.date = dateWithoutTime
        }
        saveContext()
    }
    
    func isRecordExists(id: UUID, date: Date) throws -> Bool {
        do {
            if let _ = try fetchRecord(id: id, date: date) { return true
            } else { return false }
        } catch {
            print("Ошибка при получении записи для трекера: \(error)")
            throw error
        }
    }
    
    private func fetchRecord(id: UUID, date: Date) throws -> TrackerRecordCoreData? {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        
        fetchRequest.predicate = NSPredicate(format: "id == %@ AND date == %@", id as CVarArg, startOfDay as CVarArg)
        do {
             let result = try context.fetch(fetchRequest)
             return result.first
         } catch {
             print("Ошибка при получении записи для трекера: \(error)")
             throw error
         }
    }
    
    private func convertToTrackerRecord(from coreDataEntity: TrackerRecordCoreData) -> TrackerRecord {
        return TrackerRecord(id: coreDataEntity.id ?? UUID(), date: coreDataEntity.date ?? Date())
    }
    
    private func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )

        controller.delegate = self
        self.fetchedResultsController = controller
        
        do {
            try controller.performFetch()
        } catch {
            print("Failed to fetch tracker records: \(error)")
        }
    }
    
    private func saveContext() {
        do {
            try context.save()
        } catch {
            context.rollback()
            print("Failed to save context: \(error)")
        }
    }
}
