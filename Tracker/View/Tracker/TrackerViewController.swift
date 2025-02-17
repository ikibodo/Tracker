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
    
    private let trackerStore = TrackerStore()
    private let trackerCategoryStore = TrackerCategoryStore()
    private let trackerRecordStore = TrackerRecordStore()
    
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
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Error")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
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
    
    private lazy var errorSearchImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ErrorSearch")
        imageView.isHidden = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        let localID = Locale.preferredLanguages.first ?? "ru_RU"
        datePicker.locale = Locale(identifier: localID)
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
    
    private lazy var filterButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .ypBlue
        button.setTitle("Фильтры", for: .normal)
        button.titleLabel?.textColor = .ypWhite
        button.tintColor = .ypWhite
        button.layer.cornerRadius = 16
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        collectionView.dataSource = self
        collectionView.delegate = self
        
        trackerCategoryStore.delegate = self
        //      trackerCategoryStore.setupFetchedResultsController()
        //      categories = MockData.mockData
        
        setupNavigationBar()
        addSubViews()
        addConstraints()
        //        showContentOrPlaceholder()
        updateErrorImageVisibility()
        
        newHabitOrEventViewController = NewHabitOrEventViewController()
        newHabitOrEventViewController.delegate = self
        
        loadCategories()
        dateChanged()
        //              deleteAllData()
    }
    
    private func addSubViews() {
        collectionView.addSubview(errorImage)
        collectionView.addSubview(errorLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(searchTextField)
        view.addSubview(errorImage)
        view.addSubview(errorLabel)
        view.addSubview(errorSearchImage)
        view.addSubview(collectionView)
        view.addSubview(filterButton)
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
            
            errorSearchImage.topAnchor.constraint(equalTo: view.topAnchor, constant: 402),
            errorSearchImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            collectionView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 10),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.widthAnchor.constraint(equalToConstant: 114),
            filterButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: false)
        guard (navigationController?.navigationBar) != nil else { return }
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: plusButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }
    
    // MARK: - Actions
    
    @objc private func didTapPlusButton() {
        print("🔘 Tapped + и открывается страница выбора типа трекера")
        let viewController = TrackerTypeViewController()
        viewController.delegate = self
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .pageSheet
        present(navigationController, animated: true)
    }
    
    @objc private func filterButtonTapped() {
        let viewController = FiltersViewController()
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
        let selectedWeekDay = getCurrentWeekDay()
        loadCategories()
        
        var newVisibleCategories: [TrackerCategory] = getPinnedTrackersCategory()
        let filteredCategories = getFilteredCategories(excluding: newVisibleCategories, selectedWeekDay: selectedWeekDay)
        
        newVisibleCategories.append(contentsOf: filteredCategories)
        visibleCategories = newVisibleCategories
        updateErrorImageVisibility()
        collectionView.reloadData()
    }

    private func getCurrentWeekDay() -> WeekDay? {
        let calendar = Calendar.current
        let selectedDayIndex = calendar.component(.weekday, from: currentDate)
        return WeekDay.from(weekdayIndex: selectedDayIndex)
    }

    private func getPinnedTrackersCategory() -> [TrackerCategory] {
        let pinnedTrackersList = trackerStore.fetchPinnedTrackers()
        guard !pinnedTrackersList.isEmpty else { return [] }
        return [TrackerCategory(title: "Закрепленные", trackers: pinnedTrackersList)]
    }

    private func getFilteredCategories(excluding pinnedCategories: [TrackerCategory], selectedWeekDay: WeekDay?) -> [TrackerCategory] {
        guard let selectedWeekDay = selectedWeekDay else { return [] }
        let pinnedTrackers = pinnedCategories.flatMap { $0.trackers }

        return categories.compactMap { category in
            let filteredTrackers = category.trackers.filter { tracker in
                if pinnedTrackers.contains(where: { $0.id == tracker.id }) {
                    return false
                }
                if tracker.schedule.isEmpty {
                    return true
                }
                return tracker.schedule.contains(selectedWeekDay)
            }
            return filteredTrackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: filteredTrackers)
        }
    }

    private func updateErrorImageVisibility() {
        let isEmpty = visibleCategories.isEmpty
        print("Update Visible Categories: Видимые категории: \(visibleCategories)")
        
        collectionView.isHidden = isEmpty
        errorImage.isHidden = !isEmpty
        errorLabel.isHidden = !isEmpty
    }
    
    private func showErrorSearchImage(isHidden: Bool) {
        errorSearchImage.isHidden = isHidden
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
        guard indexPath.section < visibleCategories.count else {
            print("Ошибка: indexPath.section (\(indexPath.section)) выходит за пределы visibleCategories (\(visibleCategories.count))")
            return UICollectionViewCell()
        }
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? TrackerCell else { return UICollectionViewCell() }
        
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        print("Секция: \(indexPath.section), Элемент: \(indexPath.row)")
        
        let isCompletedToday = isTrackerCompletedToday(id: tracker.id)
        cell.delegate = self
        let isPinned = trackerStore.isTrackerPinned(id: tracker.id)
        let currentDate = datePicker.date
        let completedDay = (try? trackerRecordStore.completedDays(for: tracker.id).count) ?? 0
        cell.configure(with: tracker.name, date: currentDate, isPinned: isPinned)
        cell.setupCell(with: tracker, indexPath: indexPath, completedDay: completedDay, isCompletedToday: isCompletedToday)
        print("Создана ячейка для секции \(indexPath.section), элемента \(indexPath.row), с трекером \(tracker.name)")
        return cell
    }
    
    private func isTrackerCompletedToday(id: UUID) -> Bool {
        do {
            let completedDates = try trackerRecordStore.completedDays(for: id)
            return completedDates.contains { Calendar.current.isDate($0, inSameDayAs: datePicker.date) }
        } catch {
            print("Ошибка при получении выполненных дней трекера: \(error)")
            return false
        }
    }
    
    private func isSameTrackerRecord(trackerRecord: TrackerRecord, id: UUID) -> Bool {
        do {
            return try trackerRecordStore.isRecordExists(id: id, date: datePicker.date)
        } catch {
            print("Ошибка при проверке записи трекера: \(error)")
            return false
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        let isPinned = trackerStore.isTrackerPinned(id: tracker.id)
        
        let pinAction = UIAction(title: isPinned ? "Открепить" : "Закрепить", handler: { _ in
            if isPinned {
                self.unpinTracker(id: tracker.id, at: indexPath)
            } else {
                self.pinTracker(id: tracker.id, at: indexPath)
            }
        })
        
        let editAction = UIAction(title: "Редактировать", handler: { _ in
            self.editTracker(id: tracker.id, at: indexPath)
        })
        
        let deleteAction = UIAction(title: "Удалить", attributes: .destructive, handler: { _ in
            self.showDeleteTrackerAlert(id: tracker.id, at: indexPath)
        })
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            return UIMenu(title: "", children: [pinAction, editAction, deleteAction])
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration
    ) -> UITargetedPreview? {
        let touchPoint = collectionView.panGestureRecognizer.location(in: collectionView)
        
        guard let indexPath = collectionView.indexPathForItem(at: touchPoint),
              let cell = collectionView.cellForItem(at: indexPath) as? TrackerCell else {
            return nil
        }
        
        return UITargetedPreview(view: cell.topContainerView)
    }
    
    private func pinTracker(id: UUID, at indexPath: IndexPath) {
        do {
            try trackerStore.pinTracker(id: id)
            updateVisibleCategories()
            collectionView.reloadItems(at: [indexPath])
        } catch {
            print("Ошибка при закреплении трекера: \(error)")
        }
    }
    
    private func unpinTracker(id: UUID, at indexPath: IndexPath) {
        do {
            try trackerStore.unpinTracker(id: id)
            updateVisibleCategories()
            collectionView.reloadItems(at: [indexPath])
        } catch {
            print("Ошибка при откреплении трекера: \(error)")
        }
    }
    
    
    private func editTracker(id: UUID, at indexPath: IndexPath) {
        guard let category = categories.first(where: { $0.trackers.contains(where: { $0.id == id }) }),
              let tracker = category.trackers.first(where: { $0.id == id }) else {
            return
        }
        let editTrackerVC = NewHabitOrEventViewController(isForHabits: !tracker.schedule.isEmpty)
        editTrackerVC.editTrackerDelegate = self
        editTrackerVC.editingTracker = tracker
        editTrackerVC.categoryTitle = category.title
        
        let navigationController = UINavigationController(rootViewController: editTrackerVC)
        navigationController.modalPresentationStyle = .pageSheet
        present(navigationController, animated: true)
    }
    
    private func showDeleteTrackerAlert(id: UUID, at indexPath: IndexPath) {
        let alert = UIAlertController(title: "Уверены что хотите удалить трекер?", message: nil, preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { _ in
            if self.trackers.first(where: { $0.id == id }) != nil {
                do {
                    try self.trackerStore.deleteTracker(id: id)
                    print("🗑 Трекер с id \(id) успешно удален")
                    self.trackers.removeAll { $0.id == id }
                    self.updateVisibleCategories()
                } catch {
                    print("Ошибка при удалении трекера: \(error)")
                }
            } else {
                print("Трекер с id \(id) не найден в массиве")
            }
        }
        
        let cancelAction = UIAlertAction(title: "Отменить", style: .cancel)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
}

extension TrackersViewController: TrackerCellDelegate {
    func completeTracker(id: UUID, at indexPath: IndexPath) {
        let todayDate = Date()
        guard currentDate <= todayDate else {
            print("Ошибка: нельзя отметить трекер для будущей даты \(datePicker.date)")
            return
        }
        do {
            try trackerRecordStore.updateRecord(id: id, date: datePicker.date)
            print("Выполнен трекер с id \(id) о чем создана запись \(datePicker.date)")
        } catch {
            print("Ошибка при обновлении записи в CoreData: \(error)")
        }
        collectionView.reloadItems(at: [indexPath])
    }
    
    func uncompleteTracker(id: UUID, at indexPath: IndexPath) {
        do {
            try trackerRecordStore.deleteRecord(id: id, date: datePicker.date)
            print("Отмена выполнения трекера с id \(id) - запись удалена")
        } catch {
            print("Ошибка при удалении записи из CoreData: \(error)")
        }
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

extension TrackersViewController: TrackerCategoryStoreDelegate {
    private func loadCategories() {
        print("Загруженные начальные категории: \(trackerCategoryStore.trackersCategory)")
        if trackerCategoryStore.trackersCategory.isEmpty {
            print("Категории пусты")
        }
        categories = trackerCategoryStore.trackersCategory
        trackers = categories.flatMap { $0.trackers }
        print("Категории после присваивания: \(categories)")
        collectionView.reloadData()
    }
    
    func didUpdateCategories(inserted: Set<IndexPath>, deleted: Set<IndexPath>, updated: Set<IndexPath>) {
        loadCategories()
        updateVisibleCategories()
        collectionView.reloadData()
    }
    
    func deleteAllData() {
        do {
            let recordsToDelete = try trackerRecordStore.fetchAllRecords()
            for record in recordsToDelete {
                let id = record.id
                let date = record.date
                try trackerRecordStore.deleteRecord(id: id, date: date)
                print("🗑 trackerRecordStore - deleteAllData")
            }
        } catch {
            print("Ошибка при удалении записей: \(error)")
        }
        
        do {
            let trackersToDelete = try trackerStore.fetchAllTrackers()
            for tracker in trackersToDelete {
                try trackerStore.deleteTracker(id: tracker.id)
                print("🗑 trackerStore - deleteAllData")
            }
        } catch {
            print("Ошибка при удалении трекеров: \(error)")
        }
        
        do {
            let categoriesToDelete = try trackerCategoryStore.fetchAllCategories()
            for category in categoriesToDelete {
                try trackerCategoryStore.deleteCategory(category)
                print("🗑 trackerCategoryStore - deleteAllData")
            }
        } catch {
            print("Ошибка при удалении категорий: \(error)")
        }
        categories.removeAll()
        collectionView.reloadData()
    }
}

extension TrackersViewController: NewHabitOrEventViewControllerDelegate {
    func addTracker(_ tracker: Tracker, to category: TrackerCategory) {
        do {
            try trackerStore.addTracker(tracker, with: category)
            print("Трекер \(tracker.name) добавлен в категорию: \(category.title)")
            dateChanged()
        } catch {
            print("Ошибка при добавлении трекера: \(error.localizedDescription)")
        }
    }
}

extension TrackersViewController: FiltersViewControllerDelegate {
    func didSelectFilter(selectFilter: TrackerFilter) {
        applyFilter(selectFilter: selectFilter)
        updateVisibleCategories()
    }
    
    private func applyFilter(selectFilter: TrackerFilter) {
        //           switch selectFilter {
        //           case .allTrackers:
        //               // Показываем все трекеры
        //           case .trackersToday:
        //               // Показываем трекеры на сегодня
        //           case .completed:
        //               // Показываем завершенные трекеры
        //           case .notCompleted:
        //               // Показываем незавершенные трекеры
        //           default:
        //           }
    }
}
