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
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>?
    
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
    
    func addTracker(_ tracker: Tracker, with category: TrackerCategory) throws {
        let trackerCoreData = TrackerCoreData(context: context)
        updateTrackers(trackerCoreData, with: tracker)
        let categoryToAdd = try fetchCategory(with: category.title) ?? createNewCategory(with: category.title)
        categoryToAdd.addToTracker(trackerCoreData)
        print("Трекер добавлен в категорию \(categoryToAdd.title ?? "неизвестная категория")")
        saveContext()
    }
    
    func fetchAllTrackers() throws -> [Tracker] {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        let result = try context.fetch(fetchRequest)
        return result.compactMap { trackerCoreData in
            do {
                return try createTracker(from: trackerCoreData)
            } catch {
                print("Ошибка при создании Tracker в TrackerStore: \(error)")
                return nil
            }
        }
    }
    
    func deleteTracker(_ tracker: Tracker) throws {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
        guard let trackerToDelete = try context.fetch(fetchRequest).first else { return }
            context.perform {
                self.context.delete(trackerToDelete)
                self.saveContext()
            }
    }
    
    private func updateTrackers(_ trackerCoreData: TrackerCoreData, with tracker: Tracker) {
        guard let (colorString, _) = colorDictionary.first(where: { $0.value == tracker.color }) else { return }
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.color = colorString
        trackerCoreData.emoji = tracker.emoji
        print("updateTrackers - Исходное schedule перед трансформацией: \(tracker.schedule)")
        if let transformedSchedule = DaysValueTransformer().transformedValue(tracker.schedule) as? NSObject {
            trackerCoreData.schedule = transformedSchedule
            print("updateTrackers - Успешно сохраненное schedule: \(transformedSchedule)")
        } else {
            print("updateTrackers - Ошибка преобразования расписания! Schedule не сохранен")
            trackerCoreData.schedule = nil
        }
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
        
        let schedule: [WeekDay]
        if let scheduleData = trackerCoreData.schedule,
           let transformedSchedule = DaysValueTransformer().reverseTransformedValue(scheduleData) as? [WeekDay] {
            schedule = transformedSchedule
        } else {
            schedule = []
        }
        return Tracker(id: id, name: name, color: color, emoji: emoji, schedule: schedule)
    }
    
    private func fetchCategory(with title: String) throws -> TrackerCategoryCoreData? {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", title)
        return try context.fetch(fetchRequest).first
    }
    
    private func createNewCategory(with title: String) -> TrackerCategoryCoreData {
        let newCategory = TrackerCategoryCoreData(context: context)
        newCategory.title = title.isEmpty ? "Новая категория" : title
        return newCategory
    }
    
    private func setupFetchedResultsController(){
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
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
            print("Failed to fetch trackers: \(error)")
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
