//
//  Untitled.swift
//  Tracker
//
//  Created by N L on 6.1.25..
//
import UIKit

protocol NewHabitOrEventViewControllerDelegate: AnyObject {
    func addTracker(_ tracker: Tracker, to category: TrackerCategory)
}

final class NewHabitOrEventViewController: UIViewController, ScheduleViewControllerDelegate {
    
    weak var trackerViewController: TrackerTypeViewController?
    weak var delegate: NewHabitOrEventViewControllerDelegate?
    
    private var trackerItemsTopConstraint: NSLayoutConstraint!
    private var schedule: [WeekDay?] = []
    private let itemsForHabits = ["Категория", "Расписание"]
    private let itemsForEvents = ["Категория"]
    private var currentItems: [String] = []
    var categories: [TrackerCategory] = []
    var viewCategories: [TrackerCategory] = []
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypBlack
        label.font = .systemFont(ofSize: 17)
        label.textAlignment = .center
        label.text = "Новая привычка"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var trackerNameInput: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .ypLightGray.withAlphaComponent(0.3)
        textField.tintColor = .ypGray
        textField.placeholder = "Введите название трекера"
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0))
        textField.leftViewMode = .always
        textField.borderStyle = .roundedRect
        textField.layer.cornerRadius = 16
        textField.clipsToBounds = true
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var limitLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypRed
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textAlignment = .center
        label.text = "Ограничение 38 символов"
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var trackerItems: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.layer.cornerRadius = 16
        tableView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner]
        tableView.clipsToBounds = true
        tableView.layer.masksToBounds = true
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.isScrollEnabled = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .ypGray
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.tintColor = .ypWhite
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .ypWhite
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(.ypRed, for: .normal)
        button.tintColor = .ypRed
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.ypRed.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()
    
    init(isForHabits: Bool) {
        self.currentItems = isForHabits ? itemsForHabits : itemsForEvents
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        
        trackerItems.reloadData()
        trackerItems.delegate = self
        trackerItems.dataSource = self
        navigationBar()
        addSubViews()
        addConstraints()
    }
    
    private func navigationBar() {
        guard let navigationBar = navigationController?.navigationBar else { return }
        navigationBar.topItem?.titleView = titleLabel
    }
    
    private func addSubViews() {
        view.addSubview(titleLabel)
        view.addSubview(trackerNameInput)
        view.addSubview(limitLabel)
        view.addSubview(trackerItems)
        view.addSubview(createButton)
        view.addSubview(cancelButton)
    }
    
    private func addConstraints() {
        trackerItemsTopConstraint = trackerItems.topAnchor.constraint(equalTo: trackerNameInput.bottomAnchor, constant: 24)
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            trackerNameInput.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            trackerNameInput.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trackerNameInput.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            trackerNameInput.heightAnchor.constraint(equalToConstant: 75),
            
            limitLabel.topAnchor.constraint(equalTo: trackerNameInput.bottomAnchor, constant: 8),
            limitLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            limitLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            limitLabel.heightAnchor.constraint(equalToConstant: 22),
            
            trackerItemsTopConstraint,
            trackerItems.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trackerItems.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            trackerItems.heightAnchor.constraint(equalToConstant: CGFloat(75 * currentItems.count)),
            
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.widthAnchor.constraint(equalTo: cancelButton.widthAnchor),
            createButton.heightAnchor.constraint(equalToConstant: 60),
            
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.rightAnchor.constraint(equalTo: createButton.leftAnchor, constant: -8),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
    
    private func updateConstraints() {
        if limitLabel.isHidden {
            trackerItemsTopConstraint.isActive = false
            trackerItemsTopConstraint = trackerItems.topAnchor.constraint(equalTo: trackerNameInput.bottomAnchor, constant: 24)
        } else {
            trackerItemsTopConstraint.isActive = false
            trackerItemsTopConstraint = trackerItems.topAnchor.constraint(equalTo: limitLabel.bottomAnchor, constant: 32)
        }
        trackerItemsTopConstraint.isActive = true
        
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func validateCreateButtonState() {
        let isForHabits = currentItems.contains("Расписание")
        let isNameFilled = !(trackerNameInput.text?.trimmingCharacters(in: .whitespaces).isEmpty ?? true)
        let isScheduleSelected = !schedule.isEmpty
        
        createButton.isEnabled = isForHabits ? (isNameFilled && isScheduleSelected) : isNameFilled
        createButton.backgroundColor = createButton.isEnabled ? .ypBlack : .ypGray
    }
    
    func didUpdateSchedule(_ schedule: [WeekDay?]) {
        self.schedule = schedule
        validateCreateButtonState()
        print("Обновленное расписание \(schedule.map { $0?.rawValue ?? "None" })")
    }
    
    private func addNewTracker(_ tracker: Tracker, to categoryTitle: String) {
        if let existingCategoryIndex = viewCategories.firstIndex(where: { $0.title == categoryTitle }) {
            var updatedCategory = viewCategories[existingCategoryIndex]
            var newTrackers = updatedCategory.trackers
            newTrackers.append(tracker)
            updatedCategory = TrackerCategory(title: updatedCategory.title, trackers: newTrackers)
            viewCategories[existingCategoryIndex] = updatedCategory
            delegate?.addTracker(tracker, to: updatedCategory)
        } else {
            let defaultCategory = TrackerCategory(title: "Домашний уют", trackers: [tracker])
            viewCategories.append(defaultCategory)
            delegate?.addTracker(tracker, to: defaultCategory)
        }
    }
    
    @objc
    private func createButtonTapped() {
        let newTracker = Tracker(
            id: UUID(),
            name: trackerNameInput.text ?? "Сделай это!",
            color: .colorSelected17,
            emoji: "🌟",
            schedule: self.schedule
        )
        let categoryTitle = self.title ?? "Default"
        
        addNewTracker(newTracker, to: categoryTitle)
        dismiss(animated: true, completion: nil)
        print("Создать нажато и создается трекер")
    }
    
    @objc
    private func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
}

extension NewHabitOrEventViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("Пользователь начал редактировать поле")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        validateCreateButtonState()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = (textField.text ?? "") as NSString
        let updatedText = currentText.replacingCharacters(in: range, with: string)
        
        if updatedText.count >= 38 {
            limitLabel.isHidden = false
        } else {
            limitLabel.isHidden = true
        }
        updateConstraints()
        return true
    }
}

extension NewHabitOrEventViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            print("Категория нажата")
            // TODO - добавить логику для выбора категории
        case 1:
            print("Расписание нажато")
            let scheduleViewController = ScheduleViewController()
            scheduleViewController.delegate = self
            scheduleViewController.loadSelectedSchedule(from: schedule)
            let navigationController = UINavigationController(rootViewController: scheduleViewController)
            navigationController.modalPresentationStyle = .pageSheet
            present(navigationController, animated: true)
        default:
            break
        }
    }
}

extension NewHabitOrEventViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.selectionStyle = .none
        cell.backgroundColor = .ypLightGray.withAlphaComponent(0.3)
        cell.textLabel?.text = currentItems[indexPath.row]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17)
        cell.textLabel?.textColor = .ypBlack
        
        if indexPath.row == 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }
        
        let chevronImage = UIImage(named: "Chevron")
        if let chevronImage = chevronImage {
            let chevronImageView = UIImageView(image: chevronImage)
            cell.accessoryView = chevronImageView
        }
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}
