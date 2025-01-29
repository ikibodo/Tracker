//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by N L on 24.1.25..
//
import Foundation
import UIKit
import CoreData

enum TrackerCategoryStoreError: Error {
    case missingTitle
    case missingColor
    case invalidSchedule
}

protocol TrackerCategoryStoreDelegate: AnyObject {
    func didUpdateCategories(inserted: Set<IndexPath>, deleted: Set<IndexPath>, updated: Set<IndexPath>)
}

final class TrackerCategoryStore: NSObject, NSFetchedResultsControllerDelegate {
    var trackersCategory: [TrackerCategory] {
        guard
            let data = self.fetchedResultsController.fetchedObjects,
            let categories = try? data.map({ try self.getCategories(from: $0) })
        else { return [] }
        return categories
    }
    
    weak var delegate: TrackerCategoryStoreDelegate?
    
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>!
    
    private var insertedIndexes: Set<IndexPath> = []
    private var deletedIndexes: Set<IndexPath> = []
    private var updatedIndexes: Set<IndexPath> = []
    
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
    }
    
    func getCategories(from trackerCategoryStore: TrackerCategoryCoreData) throws -> TrackerCategory {
        guard let title = trackerCategoryStore.title else { throw TrackerCategoryStoreError.missingTitle }
        var trackers: [Tracker] = []
        
        guard let trackerSet = trackerCategoryStore.tracker as? Set<TrackerCoreData> else {
            return TrackerCategory(title: title, trackers: [])
        }
        
        for trackerCoreData in trackerSet {
            do {
                let tracker = try createTracker(from: trackerCoreData)
                trackers.append(tracker)
            } catch {
                print("Не удалось создать трекер для категории \(title): \(error)")
            }
        }
        return TrackerCategory(title: title, trackers: trackers)
    }
    
    private func createTracker(from trackerCoreData: TrackerCoreData) throws -> Tracker {
        guard let id = trackerCoreData.id ?? UUID() as UUID?,
              let name = trackerCoreData.name else {
            throw TrackerCategoryStoreError.missingTitle
        }
        
        let color: UIColor
        if let colorName = trackerCoreData.color, let uiColor = UIColor(named: colorName) {
            color = uiColor
        } else {
            color = .colorSelected17
        }
        
        let emoji = trackerCoreData.emoji ?? ""
        
        let schedule: [WeekDay]
        if let scheduleData = trackerCoreData.schedule,
           let transformedSchedule = DaysValueTransformer().reverseTransformedValue(scheduleData) as? [WeekDay] {
            schedule = transformedSchedule
        } else {
            schedule = []
        }
        return Tracker(id: id, name: name, color: color, emoji: emoji, schedule: schedule)
    }
    
    func setupFetchedResultsController()  -> NSFetchedResultsController<TrackerCategoryCoreData> {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            print("Failed to fetch categories: \(error)")
        }
        return fetchedResultsController
    }
    
    func fetchAllCategories() throws -> [TrackerCategoryCoreData] {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        let result = try context.fetch(fetchRequest)
        return result
    }
    
    func deleteCategory(_ category: TrackerCategoryCoreData) {
        context.perform {
            self.context.delete(category)
            self.saveContext()
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
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes.removeAll()
        deletedIndexes.removeAll()
        updatedIndexes.removeAll()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                insertedIndexes.insert(newIndexPath)
            }
        case .delete:
            if let indexPath = indexPath {
                deletedIndexes.insert(indexPath)
            }
        case .update:
            if let indexPath = indexPath {
                updatedIndexes.insert(indexPath)
            }
        case .move:
            if let oldIndexPath = indexPath {
                deletedIndexes.insert(oldIndexPath)
            }
            if let newIndexPath = newIndexPath {
                insertedIndexes.insert(newIndexPath)
            }
        @unknown default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdateCategories(inserted: insertedIndexes, deleted: deletedIndexes, updated: updatedIndexes)
    }
}

