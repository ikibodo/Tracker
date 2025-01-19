//
//  ViewController.swift
//  Tracker
//
//  Created by N L on 26.12.24..
//
import UIKit

final class TrackersViewController: UIViewController {
    
    private var newHabitOrEventViewController: NewHabitOrEventViewController!
    private var categories: [TrackerCategory] = []
    private var visibleCategories: [TrackerCategory] = []
    private var trackers: [Tracker] = []
    private var completedTrackers: [TrackerRecord] = []
    private let cellIdentifier = "cell"
    private var countDays: Int = 0
    private var currentDate: Date = Date()
    
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
        let textField = UISearchTextField()
        textField.textColor = .ypBlack
        textField.placeholder = "Поиск..."
        textField.font = .systemFont(ofSize: 17, weight: .regular)
        textField.backgroundColor = .clear
        textField.layer.cornerRadius = 10
        textField.layer.masksToBounds = true
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
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
        let localID = Locale.preferredLanguages.first ?? "ru_RU"
        datePicker.locale = Locale(identifier: localID)
        //        datePicker.maximumDate = Date() // Второй вариант с ограничением дат, интуитивно понятнее пользователю блок, но не дающий посмотреть что в следующие дни предстоит.Хотя вариате что есть сейчас алерта (не предусмотрен макетом) явно не хватает чтобы уведомить пользователя, почему нельзя нажать на кнопку.
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        return datePicker
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = .ypBlack
        label.backgroundColor = .colorSelected0
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy"
        label.text = dateFormatter.string(from: datePicker.date)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
        
        categories = MockData.mockData // mockData убрать в следующих спринтах
        dateChanged()
        
        navigationBar()
        addSubViews()
        addConstraints()
        showContentOrPlaceholder()
        
        newHabitOrEventViewController = NewHabitOrEventViewController()
        newHabitOrEventViewController.delegate = self
    }
    
    private func addSubViews() {
        collectionView.addSubview(errorImage)
        collectionView.addSubview(errorLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(searchTextField)
        view.addSubview(errorImage)
        view.addSubview(errorLabel)
        view.addSubview(collectionView)
    }
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 1),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            searchTextField.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 7),
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
        ])
    }
    
    private func navigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: false)
        guard (navigationController?.navigationBar) != nil else { return }
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: plusButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }
    
    private func showContentOrPlaceholder() {
        if visibleCategories.isEmpty {
            collectionView.isHidden = true
            errorImage.isHidden = false
            errorLabel.isHidden = false
        } else {
            collectionView.isHidden = false
            errorImage.isHidden = true
            errorLabel.isHidden = true
        }
    }
    
    // MARK: - Actions
    
    @objc
    private func didTapPlusButton() {
        print("Кнопка плюс нажата и открывается страница выбора типа трекера")
        let viewController = TrackerTypeViewController()
        viewController.delegate = self
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .pageSheet
        present(navigationController, animated: true)
    }
    
    @objc private func dateChanged() {
        currentDate = Calendar.current.startOfDay(for: datePicker.date)
        updateVisibleCategories()
    }
    
    private func updateVisibleCategories() {
        let calendar = Calendar.current
        let selectedDayIndex = calendar.component(.weekday, from: currentDate)
        guard let selectedWeekDay = WeekDay.from(weekdayIndex: selectedDayIndex) else { return }
        
        visibleCategories = categories.compactMap { category in
            let trackers = category.trackers.filter { tracker in
                print("Проверка трекера: \(tracker.name)")
                if tracker.schedule.isEmpty {
                    print("Трекер без расписания: \(tracker.name)")
                    return true
                } else {
                    let containsWeekDay = tracker.schedule.contains { weekDay in
                        weekDay == selectedWeekDay
                    }
                    print("Трекер содержит \(selectedWeekDay): \(containsWeekDay)")
                    return containsWeekDay
                }
            }
            if trackers.isEmpty { return nil }
            return TrackerCategory(
                title: category.title,
                trackers: trackers
            )
        }
        if visibleCategories.isEmpty {
            print("Видимые категории: \(visibleCategories)")
            showErrorImage(true)
        } else {
            showErrorImage(false)
        }
        collectionView.reloadData()
    }
    
    private func showErrorImage(_ show: Bool) {
        collectionView.isHidden = show
        errorImage.isHidden = !show
        errorLabel.isHidden = !show
    }
}

extension TrackersViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
        // TODO сортировка при выборе в поле поиска
    }
}

extension TrackersViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        print("Количество секций: \(visibleCategories.count)")
        return visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard section < visibleCategories.count else {
            return 0
        }
        let category = visibleCategories[section]
        return category.trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? TrackerCell else { return UICollectionViewCell() }
        
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        print("Секция: \(indexPath.section), Элемент: \(indexPath.row)")
        
        let isCompletedToday = isTrackerCompletedToday(id: tracker.id)
        cell.delegate = self
        
        let currentDate = datePicker.date
        let completedDay = completedTrackers.filter{ $0.id == tracker.id }.count
        cell.configure(with: tracker.name, date: currentDate)
        cell.setupCell(with: tracker, indexPath: indexPath, completedDay: completedDay, isCompletedToday: isCompletedToday)
        print("Создана ячейка для секции \(indexPath.section), элемента \(indexPath.row), с трекером \(tracker.name)")
        return cell
    }
    
    private func isTrackerCompletedToday(id: UUID) -> Bool {
        completedTrackers.contains { trackerRecord in
            isSameTrackerRecord(trackerRecord: trackerRecord, id: id)
        }
    }
    
    private func isSameTrackerRecord(trackerRecord: TrackerRecord, id: UUID) -> Bool {
        let isSomeDay = Calendar.current.isDate(trackerRecord.date, inSameDayAs: datePicker.date)
        return trackerRecord.id == id && isSomeDay
    }
}

extension TrackersViewController: TrackerCellDelegate {
    func completeTracker(id: UUID, at indexPath: IndexPath) {
        let todayDate = Date()
        guard datePicker.date <= todayDate else {
            print("Ошибка: нельзя отметить трекер для будущей даты \(datePicker.date)")
            return
        }
        
        let trackerRecord = TrackerRecord(id: id, date: datePicker.date)
        print("Выполнен трекер с id \(id) о чем создана запись \(trackerRecord.date)")
        completedTrackers.append(trackerRecord)
        collectionView.reloadItems(at: [indexPath])
    }
    
    func uncompleteTracker(id: UUID, at indexPath: IndexPath) {
        completedTrackers.removeAll() { trackerRecord in
            isSameTrackerRecord(trackerRecord: trackerRecord, id: id)
        }
        print("Отмена выполнения трекера с id \(id) - запись о нем удалена")
        collectionView.reloadItems(at: [indexPath])
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
        let titleCategory = visibleCategories[indexPath.section].title
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

extension TrackersViewController: NewHabitOrEventViewControllerDelegate {
    func addTracker(_ tracker: Tracker, to category: TrackerCategory) {
        var addedToCategory = category.title
        if let categoryIndex = categories.firstIndex(where: { $0.title == category.title }) {
            updateCategory(at: categoryIndex, with: tracker)
        } else {
            addToDefaultCategory(tracker)
            addedToCategory = "Новая категория"
        }
        trackers.append(tracker)
        print("Трекер \(tracker.name) добавлен в категорию: \(addedToCategory)")
        dateChanged()
    }
    
    private func updateCategory(at index: Int, with tracker: Tracker) {
        var updatedTrackers = categories[index].trackers
        updatedTrackers.append(tracker)
        categories[index] = TrackerCategory(title: categories[index].title, trackers: updatedTrackers)
    }
    
    private func addToDefaultCategory(_ tracker: Tracker) {
        if let defaultIndex = categories.firstIndex(where: { $0.title == "Домашний уют" }) {
            updateCategory(at: defaultIndex, with: tracker)
        } else {
            categories.append(TrackerCategory(title: "Новая категория", trackers: [tracker]))
        }
    }
}
