//
//  Untitled.swift
//  Tracker
//
//  Created by N L on 5.1.25..
//
import UIKit

final class TabBarViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
    }
    
    private func setupTabBar() {
        tabBar.backgroundColor = .ypWhite
        tabBar.layer.borderWidth = 0.5
        
        let trackersViewController = TrackersViewController()
        let trackersNavigationController = UINavigationController(rootViewController: trackersViewController)
        trackersNavigationController.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(named: "Disc"),
            tag: 0)
        
        
        let statisticsViewController = StatisticsViewController()
        let statisticsNavigationController = UINavigationController(rootViewController: statisticsViewController)
        statisticsNavigationController.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(named: "Rabbit"),
            tag: 1)
        
        self.viewControllers = [trackersNavigationController, statisticsNavigationController]
    }
}
