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
        tabBar.layer.borderWidth = 1
        tabBar.layer.borderColor = UIColor.ypGray.cgColor
        
        let trackerViewController = TrackersViewController()
        let trackerTabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(named: "Disc"),
            tag: 0)
        trackerViewController.tabBarItem = trackerTabBarItem
        
        let statisticsViewController = StatisticsViewController()
        let statisticsTabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(named: "Rabbit"),
            tag: 1)
        statisticsViewController.tabBarItem = statisticsTabBarItem
        
//        let statisticsTabBarItem = UIViewController()
//        statisticsViewController.tabBarItem = UITabBarItem(
//            title: "Статистика",
//            image: UIImage(named: "Rabbit"),
//            tag: 1)
        
        self.viewControllers = [trackerViewController, statisticsViewController]
    }
}