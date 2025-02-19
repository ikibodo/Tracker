//
//  ViewController.swift
//  Tracker
//
//  Created by N L on 26.12.24..
//
import UIKit

final class TrackersViewController: UIViewController {
    
    private var appSettingsStore = AppSettingsStore()
    private var currentFilter: TrackerFilter = .allTrackers
    
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
    
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private var isLoading = false
    
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
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        label.numberOfLines = 2
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var errorSearchImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ErrorSearch")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var errorSearchLabel: UILabel = {
        let label = UILabel()
        label.text = "Ничего не найдено"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        label.numberOfLines = 2
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        let localID = Locale.preferredLanguages.first ?? "ru_RU"
        datePicker.locale = Locale(identifier: localID)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.addTarget(self, action: #selector(datePickerChanged), for: .valueChanged)
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
        let filtersButtonHeight: CGFloat = 50
        let filtersButtonBottomSpacing: CGFloat = 16
        let totalBottomInset = filtersButtonHeight + filtersButtonBottomSpacing
        collectionView.contentInset.bottom = totalBottomInset
        collectionView.verticalScrollIndicatorInsets.bottom = totalBottomInset
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
        if let savedFilter = appSettingsStore.selectedFilter {
            currentFilter = savedFilter
        } else {
            currentFilter = .allTrackers
            appSettingsStore.selectedFilter = .allTrackers
        }
        activityIndicator.center = view.center
        setupNavigationBar()
        addSubViews()
        addConstraints()
        updateErrorImageVisibility()
        
        newHabitOrEventViewController = NewHabitOrEventViewController()
        newHabitOrEventViewController.delegate = self
        
        loadCategories()
        datePickerChanged()
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
        view.addSubview(errorSearchLabel)
        view.addSubview(collectionView)
        view.addSubview(filterButton)
        view.addSubview(activityIndicator)
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
            errorSearchLabel.topAnchor.constraint(equalTo: errorImage.bottomAnchor, constant: 8),
            errorSearchLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            errorSearchLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
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
    
    @objc private func datePickerChanged() {
        currentDate = Calendar.current.startOfDay(for: datePicker.date)
        updateVisibleCategories()
    }
    
    private func updateVisibleCategories() {
        let calendar = Calendar.current
        let selectedDayIndex = calendar.component(.weekday, from: currentDate)
        print("Update Visible Categories: selectedDayIndex: \(selectedDayIndex)")
        
        guard let selectedWeekDay = WeekDay.from(weekdayIndex: selectedDayIndex) else { return }
        
        loadCategories()
        var newVisibleCategories: [TrackerCategory] = []
        
        let pinnedTrackersList = trackerStore.fetchPinnedTrackers()
        if !pinnedTrackersList.isEmpty {
            newVisibleCategories.append(TrackerCategory(title: "Закрепленные", trackers: pinnedTrackersList))
        }
        
        let filteredCategories: [TrackerCategory] = categories.compactMap { category in
            let filteredTrackers: [Tracker] = category.trackers.filter { tracker in
                if pinnedTrackersList.contains(where: { $0.id == tracker.id }) {
                    return false
                }
                if tracker.schedule.isEmpty {
                    return true
                }
                if !tracker.schedule.contains(selectedWeekDay) {
                    return false
                }
                if let searchText = searchTextField.text?.lowercased(), !searchText.isEmpty {
                    if !tracker.name.lowercased().contains(searchText) {
                        return false
                    }
                }
                
                switch currentFilter {
                case .allTrackers:
                    return true
                case .trackersToday:
//                    datePicker.date = Date()
                    return true
                case .completed:
                    do {
                        return try trackerRecordStore.isRecordExists(id: tracker.id, date: currentDate)
                    } catch {
                        print("Filter - Ошибка при проверке выполнения трекера: \(error)")
                        return false
                    }
                case .notCompleted:
                    do {
                        return try !trackerRecordStore.isRecordExists(id: tracker.id, date: currentDate)
                    } catch {
                        print("Filter - Ошибка при проверке выполнения трекера: \(error)")
                        return true
                    }
                }
            }
            return filteredTrackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: filteredTrackers)
        }
        
        newVisibleCategories.append(contentsOf: filteredCategories)
        visibleCategories = newVisibleCategories
        updateErrorImageVisibility()
        updateFilterButtonState()
        collectionView.reloadData()
    }
    
    private func updateErrorImageVisibility() {
        let isEmpty = visibleCategories.isEmpty
        let isFilterEmpty = isEmpty && currentFilter != .allTrackers
        let isNoTrackersForToday = isEmpty && currentFilter == .allTrackers
        let isSearchError = isEmpty && !(searchTextField.text?.isEmpty ?? true)

        errorSearchImage.isHidden = !(isSearchError || isFilterEmpty)
        errorSearchLabel.isHidden = !(isSearchError || isFilterEmpty)
        
        errorImage.isHidden = !isNoTrackersForToday || isSearchError
        errorLabel.isHidden = !isNoTrackersForToday || isSearchError
        
        filterButton.isHidden = isNoTrackersForToday
        collectionView.isHidden = isNoTrackersForToday || isFilterEmpty || isSearchError
    }
    
    private func updateFilterButtonState() {
        if currentFilter != .allTrackers {
            filterButton.setTitleColor(.ypRed, for: .normal)
        } else {
            filterButton.setTitleColor(.ypWhite, for: .normal)
        }
    }
}

extension TrackersViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        updateVisibleCategories()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateVisibleCategories()
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        updateVisibleCategories()
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
        //        print("Создана ячейка для секции \(indexPath.section), элемента \(indexPath.row), с трекером \(tracker.name)")
        return cell
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
           let offsetY = scrollView.contentOffset.y
           let contentHeight = scrollView.contentSize.height
           let threshold = contentHeight - scrollView.frame.size.height
           if offsetY > threshold && !isLoading {
               loadMoreData()
           }
       }
       
       private func loadMoreData() {
           startLoading()
           DispatchQueue.global().async {
               sleep(1)
               DispatchQueue.main.async {
                   self.collectionView.reloadData()
                   self.stopLoading()
               }
           }
       }

       private func startLoading() {
           isLoading = true
           activityIndicator.startAnimating()
           collectionView.isUserInteractionEnabled = false
       }

       private func stopLoading() {
           isLoading = false
           activityIndicator.stopAnimating()
           collectionView.isUserInteractionEnabled = true
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

extension TrackersViewController: TrackerCellDelegate {
    func completeTracker(id: UUID, at indexPath: IndexPath) {
        let todayDate = Date()
        guard currentDate <= todayDate else {
            showDateAlert()
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
    
    private func showDateAlert() {
        let alert = UIAlertController(title: nil, message: "Отметить трекер выполненым можно для текущей и прошедших дат", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension TrackersViewController: TrackerCategoryStoreDelegate {
    private func loadCategories() {
        if trackerCategoryStore.trackersCategory.isEmpty {
            print("Категории пусты")
        }
        categories = trackerCategoryStore.trackersCategory
        trackers = categories.flatMap { $0.trackers }
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
            print("TrackersViewController - Трекер \(tracker.name) добавлен в категорию: \(category.title)")
            datePickerChanged()
        } catch {
            print("TrackersViewController - Ошибка при добавлении трекера: \(error.localizedDescription)")
        }
    }
}

extension TrackersViewController: FiltersViewControllerDelegate {
    func didSelectFilter(selectFilter: TrackerFilter) {
        currentFilter = selectFilter
        appSettingsStore.selectedFilter = currentFilter
        updateVisibleCategories()
    }
}
