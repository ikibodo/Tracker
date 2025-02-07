//
//  Untitled.swift
//  Tracker
//
//  Created by N L on 6.2.25..
//
import Foundation

final class CategoryViewModel {
    var selectedCategory: String?
    
    private var categories: [String] = []
    
    func addCategory(_ category: String) {
        print("CategoryViewModel сохранил категорию: \(category)")
        categories.append(category)
    }
    
    func getCategories() -> [String] {
        print("CategoryViewModel возвращает категории: \(categories)")
        return categories
    }
    
    func isCategorySelected(_ category: String) -> Bool {
        return category == selectedCategory
    }
    
    func selectCategory(_ category: String) {
        selectedCategory = category
    }
}
