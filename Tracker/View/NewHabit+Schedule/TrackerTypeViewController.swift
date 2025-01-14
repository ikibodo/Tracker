//
//  TrackerTypeContropper.swift
//  Tracker
//
//  Created by N L on 5.1.25..
//
import UIKit

final class TrackerTypeViewController: UIViewController {
    
    weak var trackerViewController: TrackersViewController?
    weak var delegate: NewHabitOrEventViewControllerDelegate?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypBlack
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        label.text = "Создание трекера"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var habitsButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .ypBlack
        button.titleLabel?.textColor = .ypWhite
        button.setTitle("Привычка", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.titleLabel?.textAlignment = .center
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(habitsButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var eventsButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .ypBlack
        button.titleLabel?.textColor = .ypWhite
        button.setTitle("Нерегулярное событие", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.titleLabel?.textAlignment = .center
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(eventsButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        navigationBar()
        addSubViews()
        addConstraints()
        
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeDown))
        swipeDownGesture.direction = .down
        view.addGestureRecognizer(swipeDownGesture)
    }
    
    private func navigationBar() {
        guard let navigationBar = navigationController?.navigationBar else { return }
        navigationBar.topItem?.titleView = titleLabel
    }
    
    private func addSubViews() {
        view.addSubview(titleLabel)
        view.addSubview(habitsButton)
        view.addSubview(eventsButton)
    }
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            habitsButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            habitsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            habitsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            habitsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            habitsButton.heightAnchor.constraint(equalToConstant: 60),
            
            eventsButton.topAnchor.constraint(equalTo: habitsButton.bottomAnchor, constant: 16),
            eventsButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            eventsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            eventsButton.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
    
    @objc private func habitsButtonTapped() {
        let newHabitVC = NewHabitOrEventViewController(isForHabits: true)
        newHabitVC.delegate = delegate
        let navigationController = UINavigationController(rootViewController: newHabitVC)
        navigationController.modalPresentationStyle = .pageSheet
        present(navigationController, animated: true)
    }
    
    @objc private func eventsButtonTapped() {
        let newEventVC = NewHabitOrEventViewController(isForHabits: false)
        newEventVC.delegate = delegate
        let navigationController = UINavigationController(rootViewController: newEventVC)
        navigationController.modalPresentationStyle = .pageSheet
        present(navigationController, animated: true)
    }
    
    
    @objc func handleSwipeDown() {
        self.dismiss(animated: true, completion: nil)
    }
}
