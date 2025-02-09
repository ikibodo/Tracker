//
//  Untitled.swift
//  Tracker
//
//  Created by N L on 8.2.25..
//
import Foundation

final class CategoryViewModelFactory {
    static func createCategoryViewModel() -> CategoryViewModel {
        let categoryStore = TrackerCategoryStore()
        return CategoryViewModel(categoryStore: categoryStore)
    }
}
