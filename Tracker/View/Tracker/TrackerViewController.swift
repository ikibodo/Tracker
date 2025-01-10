//
//  ViewController.swift
//  Tracker
//
//  Created by N L on 26.12.24..
//
import UIKit

final class TrackersViewController: UIViewController, NewHabitViewControllerDelegate {
   
    
    private var newHabitViewController: NewHabitViewController!
    
    private var categories: [TrackerCategory] = []
    private var viewCategories: [TrackerCategory] = [
        TrackerCategory(title: "Default", trackers: [])
    ]
    private var completedTrackers: [TrackerRecord] = []
    private var trackerIds: Set<UUID> = [] //  private var completedTrackers: Set<UUID> = []
    private var selectedDate: Date = Date()
    private let cellIdentifier = "cell"

    private var trackers: [String] = ["Трекер 1", "Трекер 2"] // убрать 
    
    private struct cellParams {
        let cellCount: Int
            let leftInset: CGFloat
            let rightInset: CGFloat
            let cellSpacing: CGFloat
        let height: CGFloat
        let paddingWidth: CGFloat
        
        init(cellCount: Int, leftInset: CGFloat, rightInset: CGFloat, cellSpacing: CGFloat, height: CGFloat, paddingWidth: CGFloat) {
            self.cellCount = cellCount
            self.leftInset = leftInset
            self.rightInset = rightInset
            self.cellSpacing = cellSpacing
            self.height = height
            self.paddingWidth =  leftInset + rightInset + CGFloat(cellCount - 1) * cellSpacing
        }
        }
    
    private let params = cellParams(
        cellCount: 2,
        leftInset: 16,
        rightInset: 16,
        cellSpacing: 9,
        height: 148,
        paddingWidth: 0
    )
    
    private lazy var plusButton: UIButton = {
        let plusButton = UIButton(type: .custom)
        plusButton.setImage(UIImage(named: "Add tracker"), for: .normal)
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        plusButton.addTarget(self, action: #selector(didTapPlusButton), for: .touchUpInside)
        return plusButton
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let descriptionLabel = UILabel()
        descriptionLabel.text = "Трекеры"
        descriptionLabel.font = .systemFont(ofSize: 34, weight: .bold)
        descriptionLabel.textColor = .label
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        return descriptionLabel
    }()
    
    private lazy var searchTextField: UISearchTextField = {
        let search = UISearchTextField()
        search.textColor = .ypBlack
        search.placeholder = "Поиск..."
        search.font = .systemFont(ofSize: 17, weight: .regular)
        search.backgroundColor = .clear
        search.layer.cornerRadius = 10
        search.layer.masksToBounds = true
        search.translatesAutoresizingMaskIntoConstraints = false
        return search
    }()
    
    private lazy var errorImage: UIImageView = {
        let errorImage = UIImageView()
        errorImage.image = UIImage(named: "Error")
        errorImage.translatesAutoresizingMaskIntoConstraints = false
        return errorImage
    }()
    
    private lazy var errorLabel: UILabel = {
        let descriptionLabel = UILabel()
        descriptionLabel.text = "Что будем отслеживать?"
        descriptionLabel.font = .systemFont(ofSize: 12, weight: .medium)
        descriptionLabel.textColor = .ypBlack
        descriptionLabel.numberOfLines = 2
        descriptionLabel.textAlignment = .center
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        return descriptionLabel
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.locale = Locale.current
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.addTarget(self, action: #selector(didChangeDate), for: .valueChanged)
        return datePicker
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = .ypWhite
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.register(TrackerHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: TrackerHeaderView.switchHeaderIdentifier)
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.addSubview(errorImage)
        collectionView.addSubview(errorLabel)
        
        setupNavigationBar()
        addSubViews()
        addConstraints()
        showContentOrPlaceholder()
        
        newHabitViewController = NewHabitViewController()
        newHabitViewController.delegate = self
    }
    
    private func setupNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: false)
        guard (navigationController?.navigationBar) != nil else { return }
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(plusButton)
        containerView.addSubview(descriptionLabel)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: containerView)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }
    
    private func showContentOrPlaceholder() {
        if categories.isEmpty {
            collectionView.isHidden = true
            errorImage.isHidden = false
            errorLabel.isHidden = false
        } else {
            collectionView.isHidden = false
            errorImage.isHidden = true
            errorLabel.isHidden = true
        }
    }
    
    private func addSubViews() {
        view.addSubview(plusButton)
        view.addSubview(descriptionLabel)
        view.addSubview(searchTextField)
        view.addSubview(errorImage)
        view.addSubview(errorLabel)
        view.addSubview(datePicker)
        view.addSubview(collectionView)
    }
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            plusButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 45),
            plusButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 6),
            
            descriptionLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 88),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            searchTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 136),
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            errorImage.topAnchor.constraint(equalTo: view.topAnchor, constant: 402),
            errorImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorLabel.topAnchor.constraint(equalTo: errorImage.bottomAnchor, constant: 8),
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            collectionView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 10),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            datePicker.heightAnchor.constraint(equalToConstant: 34),
            datePicker.widthAnchor.constraint(equalToConstant: 77),
            datePicker.centerYAnchor.constraint(equalTo: plusButton.centerYAnchor),
            datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }
    
//    func didCreateTracker(_ tracker: Tracker) {
//            var updatedCategories = viewCategories
//            if var defaultCategory = viewCategories.first(where: { $0.title == "Default" }) {
//                defaultCategory.trackers.append(tracker)
//                updatedCategories = updatedCategories.map { $0.title == "Default" ? defaultCategory : $0 }
//            }
//        viewCategories = updatedCategories
//            collectionView.reloadData()
//        }
    
    // Отметить трекер как выполненный
        func markTrackerAsCompleted(_ tracker: Tracker) {
            trackerIds.insert(tracker.id)
        }

        // Убрать отметку о выполнении трекера
        func unmarkTrackerAsCompleted(_ tracker: Tracker) {
            trackerIds.remove(tracker.id)
        }
    // Добавить запись о выполнении трекера
    private func addCompletedTracker(_ tracker: Tracker) {
        let record = TrackerRecord(id: tracker.id, date: selectedDate)
        completedTrackers.append(record)
    }

    // Удалить запись о выполнении трекера
    private func removeCompletedTracker(_ tracker: Tracker) {
        if let index = completedTrackers.firstIndex(where: { $0.id == tracker.id && $0.date == selectedDate }) {
            completedTrackers.remove(at: index)
        }
    }


        // Получить трекеры для выбранной даты
        func trackersForSelectedDate() -> [Tracker] {
            categories.flatMap { category in
                category.trackers.filter { tracker in
                    tracker.schedule.contains { weekDay in
                        let calendar = Calendar.current
                        let weekDayForSelectedDate = calendar.component(.weekday, from: selectedDate)
                        return weekDay == WeekDay.allCases[weekDayForSelectedDate - 1]
                    }
                }
            }
        }
    
    // Пример метода для добавления трекера в категорию
    func addTracker(_ tracker: Tracker, to category: TrackerCategory) {
        guard let index = categories.firstIndex(where: { $0.title == category.title }) else { return }
        var updatedCategory = categories[index]
        updatedCategory.trackers.append(tracker)
        
        // Обновляем массив категорий:
        categories[index] = updatedCategory
    }
    // Пример метода для удаления трекера из категории
    func removeTracker(_ tracker: Tracker) {
        for (index, category) in categories.enumerated() {
            if let trackerIndex = category.trackers.firstIndex(where: { $0.id == tracker.id }) {
                var updatedCategory = category
                updatedCategory.trackers.remove(at: trackerIndex)
                categories[index] = updatedCategory
            }
        }
    }

    // MARK: - Actions
    
    @objc
    private func didTapPlusButton() {
        let viewController = TrackerTypeViewController()
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .pageSheet
        
        present(navigationController, animated: true)
    }
    
    @objc private func didChangeDate(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let formattedDate = dateFormatter.string(from: selectedDate)
        print("Выбранная дата: \(formattedDate)")
    }
}

extension TrackersViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    // количество секций в коллекционном представлении UICollectionView
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return viewCategories.count
//    }
//    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return trackers.count
//        return viewCategories[section].trackers.count
    }
    // колько элементов (ячейки) будет в каждой секции коллекции.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? TrackerCell else { return UICollectionViewCell() }
        
//        let tracker = viewCategories[indexPath.section].trackers[indexPath.row]
//        let isCompleted = completedTrackers.contains(where: { $0.id == tracker.id && $0.date == selectedDate })
//        cell.configure(with: tracker, isCompleted: isCompleted)
//        cell.onButtonTapped = { [weak self] in
//                if isCompleted {
//                    self?.removeCompletedTracker(tracker)
//                } else {
//                    self?.addCompletedTracker(tracker)
//                }
//                collectionView.reloadItems(at: [indexPath]) // Обновляем ячейку
//            }
        
        cell.contentView.backgroundColor = .ypWhite
        cell.titleLabel.text = trackers[indexPath.row]
        cell.configure(with: trackers[indexPath.item], date: datePicker.date) { date in
                    print("Трекер выполнен для даты: \(date)")
                }
        return cell
//        let tracker = trackers[indexPath.row]
//            cell.contentView.backgroundColor = .ypWhite
//            cell.titleLabel.text = tracker.title
//        cell.configure(with: tracker.title, date: datePicker.date) { date in
//                print("Трекер выполнен для даты: \(date)")
//            }
//            return cell
    }
}
extension TrackersViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: params.leftInset, bottom: 0, right: params.rightInset)
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                               withReuseIdentifier: TrackerHeaderView.switchHeaderIdentifier,
                                                                               for: indexPath) as? TrackerHeaderView
        else { return UICollectionReusableView() }
        let titleCategory = viewCategories[indexPath.section].title
        headerView.titleLabel.text = titleCategory
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.width - params.cellSpacing - params.leftInset - params.rightInset) / CGFloat(params.cellCount),
                      height: params.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return params.cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
