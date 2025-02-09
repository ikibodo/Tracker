//
//  Untitled.swift
//  Tracker
//
//  Created by N L on 6.2.25..
//
import UIKit

final class OnboardingViewController: UIPageViewController {
    
    
    private lazy var pages: [UIViewController] = {
        let firstPage = PageViewController(pageType: .first)
        let secondPage = PageViewController(pageType: .second)
        
        firstPage.didFinishOnboarding = { [weak self] in
            self?.finishOnboarding()
        }
        secondPage.didFinishOnboarding = { [weak self] in
            self?.finishOnboarding()
        }
        
        return [firstPage, secondPage]
    }()
    
    private var currentPageIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        setViewControllers([pages[0]], direction: .forward, animated: true)
    }
    
    static func shouldShowOnboarding() -> Bool {
        return !UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
    }
    
    private func finishOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")

        if let window = view.window {
            let tabBarController = TabBarViewController()
            window.rootViewController = tabBarController
        }
    }
}

extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pages.firstIndex(of: viewController), currentIndex > 0 else {
            return nil
        }
        return pages[currentIndex - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pages.firstIndex(of: viewController), currentIndex < pages.count - 1 else {
            return nil
        }
        return pages[currentIndex + 1]
    }
}

extension OnboardingViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed, let visibleViewController = pageViewController.viewControllers?.first,
              let newIndex = pages.firstIndex(of: visibleViewController) else {
            return
        }
        currentPageIndex = newIndex
        print("Текущая страница: \(currentPageIndex)")
    }
}
