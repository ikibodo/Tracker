//
//  Untitled.swift
//  Tracker
//
//  Created by N L on 24.1.25..
//
import Foundation
import UIKit
import CoreData

final class TrackerStore: NSObject, NSFetchedResultsControllerDelegate {
    var trackers: [TrackerCoreData] { return fetchedResultsController.fetchedObjects ?? [] }
    
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>!
    
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
    
    func addTracker(_ tracker: Tracker, with category: TrackerCategory) throws {
        let trackerCoreData = TrackerCoreData(context: context)
        updateTrackers(trackerCoreData, with: tracker)
        let categoryToAdd = try fetchCategory(with: category.title) ?? createNewCategory(with: category.title)
        categoryToAdd.addToTracker(trackerCoreData)
        print("Трекер добавлен в категорию \(categoryToAdd.title ?? "неизвестная категория")")
        saveContext()
    }
    
    func createNewCategory(with title: String) -> TrackerCategoryCoreData {
        let newCategory = TrackerCategoryCoreData(context: context)
        newCategory.title = title.isEmpty ? "Новая категория" : title
        return newCategory
    }
    
    func updateTrackers(_ trackerCoreData: TrackerCoreData, with tracker: Tracker) {
        guard let (colorString, _) = colorDictionary.first(where: { $0.value == tracker.color }) else { return }
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.color = colorString
        trackerCoreData.emoji = tracker.emoji
        print("🟡 Исходное schedule перед трансформацией: \(tracker.schedule)")
        if let transformedSchedule = DaysValueTransformer().transformedValue(tracker.schedule) as? NSObject {
            trackerCoreData.schedule = transformedSchedule
            print("✅ Успешно сохраненное schedule: \(transformedSchedule)")
        } else {
            print("❌ Ошибка преобразования расписания! Schedule не сохранен")
            trackerCoreData.schedule = nil
        }
    }
    
    func fetchCategory(with title: String) throws -> TrackerCategoryCoreData? {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", title)
        return try context.fetch(fetchRequest).first
    }
    
    func setupFetchedResultsController() -> NSFetchedResultsController<TrackerCoreData> {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Failed to fetch trackers: \(error)")
        }
        return fetchedResultsController
    }
    
    func fetchAllTrackers() throws -> [TrackerCoreData] {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        let result = try context.fetch(fetchRequest)
        return result
    }
    
    func deleteTracker(_ tracker: TrackerCoreData) {
        context.perform {
            self.context.delete(tracker)
            self.saveContext()
        }
    }
    
    private func saveContext() {
        do {
            try context.save()
            print("✅ Данные успешно сохранены в Core Data")
        } catch {
            context.rollback()
            print("❌ Ошибка сохранения в Core Data: \(error)")
        }
    }
}
