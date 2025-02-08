//
//  Untitled.swift
//  Tracker
//
//  Created by N L on 6.2.25..
//
import Foundation

typealias Binding<T> = (T) -> Void

final class CategoryViewModel {
    var selectedCategory: String?
    
    var onCategoriesUpdated: Binding<[String]>?
    var onError: Binding<String?>?
    
    private let categoryStore: TrackerCategoryStore
    private var categories: [String] = [] {
        didSet {
            onCategoriesUpdated?(categories)
        }
    }
    
    init(categoryStore: TrackerCategoryStore = TrackerCategoryStore() ) {
        self.categoryStore = categoryStore
        categoryStore.setDelegate(self)
        loadCategories()
    }
    
    func addCategory(_ category: String) {
        let newCategory = TrackerCategory(title: category, trackers: [])
        do {
            try categoryStore.addCategory(newCategory)
        } catch {
            onError?("CategoryViewModel - Ошибка добавления категории: \(error)")
        }
    }
    
    func getCategories() -> [String] {
        return categories
    }
    
    func isCategorySelected(_ category: String) -> Bool {
        return category == selectedCategory
    }
    
    func selectCategory(_ category: String) {
        selectedCategory = category
    }
    
    private func loadCategories() {
        do {
            let storedCategories = try categoryStore.fetchAllCategories()
            categories = storedCategories.map { $0.title }
        } catch {
            print("CategoryViewModel - Ошибка загрузки категорий: \(error)")
        }
    }
}

extension CategoryViewModel: TrackerCategoryStoreDelegate {
    func didUpdateCategories(inserted: Set<IndexPath>, deleted: Set<IndexPath>, updated: Set<IndexPath>) {
        loadCategories()
    }
}
