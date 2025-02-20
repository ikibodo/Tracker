//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by N L on 24.1.25..
//
import UIKit
import CoreData

protocol TrackerCategoryStoreDelegate: AnyObject {
    func didUpdateCategories(inserted: Set<IndexPath>, deleted: Set<IndexPath>, updated: Set<IndexPath>)
}

final class TrackerCategoryStore: NSObject {
    var trackersCategory: [TrackerCategory] {
        guard
            let data = self.fetchedResultsController?.fetchedObjects,
            let categories = try? data.map({ try self.getCategories(from: $0) })
        else { return [] }
        return categories
    }
    
    weak var delegate: TrackerCategoryStoreDelegate?
    
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>?
    
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
        setupFetchedResultsController()
    }
    
    func setDelegate(_ delegate: TrackerCategoryStoreDelegate) {
        self.delegate = delegate
    }

    func fetchAllCategories() throws -> [TrackerCategory] {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        let result = try context.fetch(fetchRequest)

        return result.compactMap { trackerCategoryCoreData in
            do {
                return try getCategories(from: trackerCategoryCoreData)
            } catch {
                print("Ошибка при создании Tracker в TrackerStore: \(error)")
                return nil
            }
        }
    }
    
    func addCategory(_ category: TrackerCategory) throws {
        let categoryEntity = TrackerCategoryCoreData(context: context)
        categoryEntity.title = category.title
        categoryEntity.tracker = NSSet(array: category.trackers.map { mapToCoreData($0) })
        saveContext()
    }
    
    func deleteCategory(_ category: TrackerCategory) throws {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", category.title)
        
        guard let categoryToDelete = try context.fetch(fetchRequest).first else { return }
        context.perform {
            self.context.delete(categoryToDelete)
            self.saveContext()
        }
    }
    
    private func getCategories(from trackerCategoryStore: TrackerCategoryCoreData) throws -> TrackerCategory {
        guard let title = trackerCategoryStore.title else { throw TrackerStoreError.missingTitle }
        var trackers: [Tracker] = []
        
        guard let trackerSet = trackerCategoryStore.tracker as? Set<TrackerCoreData> else {
            return TrackerCategory(title: title, trackers: [])
        }
        
        for trackerCoreData in trackerSet {
            do {
                let tracker = try createTracker(from: trackerCoreData)
                trackers.append(tracker)
            } catch {
                print("TrackerCategoryStore Не удалось создать трекер для категории \(title): \(error)")
            }
        }
        return TrackerCategory(title: title, trackers: trackers)
    }
    
    private func mapToCoreData(_ tracker: Tracker) -> TrackerCoreData {
        guard let (colorString, _) = colorDictionary.first(where: { $0.value == tracker.color }) else {
            fatalError("TrackerCategoryStore Не удалось найти строковое представление для цвета \(tracker.color)")
        }
        
        let trackerEntity = TrackerCoreData(context: context)
        trackerEntity.id = tracker.id
        trackerEntity.name = tracker.name
        trackerEntity.color = colorString
        trackerEntity.emoji = tracker.emoji
        print("TrackerCategoryStore - Исходное schedule перед трансформацией: \(tracker.schedule)")
        trackerEntity.schedule = tracker.schedule as NSObject
        return trackerEntity
    }
    
    private func createTracker(from trackerCoreData: TrackerCoreData) throws -> Tracker {
        guard let id = trackerCoreData.id ?? UUID() as UUID?,
              let name = trackerCoreData.name else {
            throw TrackerStoreError.missingTitle
        }
        
        let color: UIColor
        if let colorName = trackerCoreData.color, let uiColor = UIColor(named: colorName) {
            color = uiColor
        } else {
            color = .colorSelected17
        }

        let emoji = trackerCoreData.emoji ?? ""
        var schedule: [WeekDay] = []
        if let scheduleData = trackerCoreData.schedule as? [WeekDay?] {
            schedule = scheduleData.compactMap { $0 }
        }
        if schedule.isEmpty {
            print("ТrackerCoreData: расписание оказалось пустым после фильтрации.")
        }
        return Tracker(id: id, name: name, color: color, emoji: emoji, schedule: schedule)
    }
    
    private func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
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
            print("Failed to fetch categories: \(error)")
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

extension  TrackerCategoryStore: NSFetchedResultsControllerDelegate {
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
