//
//  ViewController.swift
//  Tracker
//
//  Created by N L on 26.12.24..
//
import UIKit

final class TrackersViewController: UIViewController, NewHabitOrEventViewControllerDelegate {
    
    private var newHabitOrEventViewController: NewHabitOrEventViewController!
    
    private var categories: [TrackerCategory] = []
    private var viewCategories: [TrackerCategory] = [
        TrackerCategory(title: "Default", trackers: [])
    ]
    private var trackers: [Tracker] = []
//    private var filteredTrackers: [Tracker] = [] // Добавляем переменную для отфильтрованных трекеров

    private var completedTrackers: [TrackerRecord] = [] // для записи даты по айди
    private var selectedDate: Date = Date()
    private let cellIdentifier = "cell"
    
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
        
        newHabitOrEventViewController = NewHabitOrEventViewController()
        newHabitOrEventViewController.delegate = self
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
        //        if categories.isEmpty {
        if trackers.isEmpty {
//        if filteredTrackers.isEmpty {
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
    
    // Добавления трекера в категорию - функция входит в NewHabitOrEventViewControllerDelegate
    func addTracker(_ tracker: Tracker, to category: TrackerCategory) {
        
        if let categoryIndex = viewCategories.firstIndex(where: { $0.title == category.title }) {
            //            var updatedTrackers = category.trackers
            //            updatedTrackers.append(tracker)
            //            let updatedCategory = TrackerCategory(title: category.title, trackers: updatedTrackers)
            //            categories[categoryIndex] = updatedCategory
            var updatedTrackers = viewCategories[categoryIndex].trackers
            updatedTrackers.append(tracker)
            var updatedCategory = viewCategories[categoryIndex]
            updatedCategory = TrackerCategory(title: updatedCategory.title, trackers: updatedTrackers)
            viewCategories[categoryIndex] = updatedCategory
            
            trackers.append(tracker)
            print("Трекер добавлен: \(tracker.title) в категорию \(category.title)")
            showContentOrPlaceholder()
            collectionView.reloadData()
        } else {
            //            print("Категория с таким названием не найдена!")
            // Если категория не найдена, добавляем трекер в категорию "Default"
            let defaultCategory = viewCategories.first { $0.title == "Default" }!
            var updatedTrackers = defaultCategory.trackers
            updatedTrackers.append(tracker)
            
            let updatedCategory = TrackerCategory(title: defaultCategory.title, trackers: updatedTrackers)
            
            if let index = viewCategories.firstIndex(where: { $0.title == "Default" }) {
                viewCategories[index] = updatedCategory
            }
            
            trackers.append(tracker)
            print("Трекер добавлен в категорию Default: \(tracker.title)")
            showContentOrPlaceholder()
            collectionView.reloadData()
        }
    }
    
//    private func filterTrackersBySelectedDay() {
//        let selectedDay = Calendar.current.component(.weekday, from: selectedDate)
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "dd.MM.yyyy"
//        let selectedDayString = dateFormatter.string(from: selectedDate)
//        
//        // Фильтруем трекеры по расписанию
//        filteredTrackers = trackers.filter { tracker in
//            // Проверяем, есть ли в расписании трекера выбранный день
//            return tracker.schedule.contains  { $0?.rawValue.lowercased() == selectedDayString.lowercased() }
//        }
//        
//        // Обновляем отображение
//        showContentOrPlaceholder()
//        collectionView.reloadData()
//    }

    
    // MARK: - Actions
    
    @objc
    private func didTapPlusButton() {
        let viewController = TrackerTypeViewController()
        viewController.delegate = self
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
//        selectedDate = sender.date  // Обновляем выбранную дату
//        print("Выбранная дата: \(selectedDate)")
//        
//        // Фильтруем трекеры по выбранному дню недели
//        filterTrackersBySelectedDay()
    }
}

extension TrackersViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    // количество секций в коллекционном представлении UICollectionView
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return trackers.count
                let count = viewCategories[section].trackers.count
                    print("Количество трекеров в категории: \(count)")
                    return count
//        return filteredTrackers.count // Возвращаем количество отфильтрованных трекеров
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? TrackerCell else { return UICollectionViewCell() }
        
        cell.contentView.backgroundColor = .ypWhite
        let tracker = trackers[indexPath.row]
//        let tracker = filteredTrackers[indexPath.row]
        cell.emoji.text = tracker.emoji
        cell.titleLabel.text = tracker.title
        cell.configure(with: tracker.title, date: datePicker.date) { date in
            print("Трекер выполнен для даты: \(date)")
        }
        return cell
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
